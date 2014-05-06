static class Utils{
  
  static void printArrayPVector(PVector[] p)
  {
    for (int i=0;i<p.length-1;i++)
      println(i+" "+p[i]);
  }

  static boolean mouseOverRect(PVector mouse, int x, int y, int w, int h) {
  	return (mouse.x >= x && mouse.x <= x+w && mouse.y >= y && mouse.y <= y+h);
  }

  static void pvectorArrayCopy(PVector[] src, PVector[] dest){
  	for (int i = 0; i<src.length; i++){
  		dest[i] = src[i];
  	}
  }

  static void print_r(int[] array){
    for (int i = 0; i<array.length; i++){
      println(array[i]);
    }
  }
}

void my_assert (boolean p) {
  if (!p) println ("my_assertion failed");
}

/**
 AnimationApp.pde
 Author: Guilherme Herzog e João Carvalho
 Created on: May 13
 **/

// State Context
StateContext stateContext;

// Context
Context context;

// Colours
color mainColor = #0066C8;
color secondaryColor = #FF9700;
color thirdColor = #3990E3;

// Canvas Size
int width,height;

public void setup() 
{
  try {
    
  width = 800;
  height = 600;
  size(width, height);

  smooth();

  context = new Context();
  update();
  stateContext = new StateContext(context);
  stateContext.setContext(context);
  } catch (Exception e) {
    console.log(e);  
  }
}

Context getContext(){
  return context;
}

stateContext getStateContext(){
  return stateContext;
}
// TODO Mudar isso para um interface só usando o mouse
void keyPressed() 
{ 
  try {
    update();
    stateContext.keyPressed();
  } catch (Exception e) {
    console.log(e);  
  }
}

// Mouse press callback
void mousePressed() 
{
  try {
    update();
    stateContext.mousePressed();
  } catch (Exception e) {
    console.log(e);  
  }
}
    
void mouseReleased()
{
  try {
    update();
    stateContext.mouseReleased();
  } catch (Exception e) {
    console.log(e);
  }
}

// Mouse drag callback
void mouseDragged () 
{
  try {
    update();
    stateContext.mouseDragged();
  } catch (Exception e) {
    console.log(e);
  }
}


void draw() 
{
  try {
    update();
    stateContext.draw();
  } catch (Exception e) {
    println("Falha no Draw \ne.toString(): "+e.toString());
    e.printStackTrace();
  }
}

void update(){
  context.updateContext(
    new PVector(mouseX, mouseY),
    new PVector(pmouseX, pmouseY), 
    mouseButton,
    keyCode, 
    key);
}



class Context{
	PVector mouse;
	PVector pMouse;
	int mouseButton;
	int keyCode;
	char key;
	CurveCat curve;
	PVector mouseInit;
	PVector mouseFinal;
	int[] selectedSegments;
	int mouseCount;
	boolean playing;
	ArrayList<SceneElement> sceneElements;
	SceneElement selectedElement;
	float time;

	Context(){
		selectedSegments = new int[0];
		this.curve = new CurveCat();
		this.curve.setTolerance(7);

		playing = false;
		t = 0;

		sceneElements = new ArrayList<SceneElement>();
		selectedElement = null;
	}

	void updateContext(PVector mouse, PVector pmouse, int _mouseButton, int keyCode, char key){
		this.mouse = mouse;
		this.pMouse = pmouse;
		this.keyCode = keyCode;
		this.key = key;
		this.mouseButton = _mouseButton;
		
	}

	void setMouseCount(int _mouseCount){
		this.mouseCount = _mouseCount;
	}


	void print(){
		println("Context[");
		println("this.mouse: "+this.mouse+",");
		println("this.pMouse: "+this.pMouse+",");
		println("this.keyCode: "+this.keyCode+",");
		println("this.key: "+this.key+",");
		Utils.print_r(selectedSegments);
		println("elements"+sceneElements);
	}

	void diselect(){
		this.selectedSegments = new int[0];
	}

	boolean isPlayed(){
		return playing;
	}

	void play(){
		frameCount = 0;

		playing = true;
		refreshInterpolator();
	}

	void togglePlay(){
		playing = !playing;

		frameCount = 0;
		refreshInterpolator();
	}

	void refreshInterpolator(){

		if(!this.isPlayed()){
			return;
		}

		PVector p;

		for (SceneElement o : sceneElements) {
			o.pos.clear();

			for (int i = 0; i< o.curve.getNumberControlPoints(); i++){
				p = o.curve.getControlPoint(i);

				o.pos.set(p.z, p);
			}
		}

		play = true;
	}

	void stop(){
		playing = false;
	}

	void addElement(SceneElement e)
	{
		sceneElements.add(e);
	}

	void draw(float t){
		if(t == 0){
			t = this.time;
		}

		for (SceneElement o : sceneElements) {
			if(o == selectedElement){
				o.c = color(255,0,0);
				o.curveColor = color(0,0,0);
			}else{
				o.c = color(0,0,0);
				o.curveColor = color(200,200,200);
			}
			o.drawCurve();
			o.draw(t);
		}

		fill(0);
		stroke(0);
		text("Tempo: "+t, 20, height - 20);
	}

	float lastTime(){
		float lastTime = 0;
		float lastTimeElement = 0;
		for (SceneElement o : sceneElements) {
			lastTimeElement = o.lastTime();
			if(lastTimeElement > lastTime){
				lastTime = lastTimeElement;
			}
		}

		return lastTime;
	}

	void setSelectedElement(SceneElement element){
		selectedElement = null;
		selectedElement = element;
        if(selectedElement != null){
		  curve = selectedElement.curve;
        }
	}

	SceneElement getSelectedElement(){
		return selectedElement;
	}

	void deleteSelectedElement(){
		for (int i = 0; i < sceneElements.size(); ++i) {
			SceneElement o = sceneElements.get(i);
			if(o == selectedElement){
				sceneElements.remove(i);
				this.curve = new CurveCat();
				return;
			}
		}

		selectedElement = null;
		stateContext.setStateName("select");
	}

	void alignTimes(float t){
		this.time = t;
	}

	void setSelectionBox(PVector mouseInit, PVector mouseFinal){
		this.mouseInit = mouseInit;
		this.mouseFinal = mouseFinal;
	}
	PVector getpMouse()
	{
		return this.pMouse;
	}
}

public class StateContext {

    private State myState;
    private Context context;
    
    // Selection Box
    PVector mouseInit;
    PVector mouseFinal;


        /**
         * Standard constructor
         */
    StateContext(Context _context) 
    {
        setState(new SelectState(_context));
        this.context = _context;
        mouseInit = new PVector(0,0);
        mouseFinal = new PVector(0,0);
    }

    public void setContext(Context _context){
        this.context = _context;
    }

    public void setStateName(String nameState){
        switch (nameState) {
            case 'circle' :
                myState = new CircleState(this.context);
            break;   

            case 'select' :
                 myState = new SelectState(this.context);
             break;   

            case 'draw' :
                  myState = new DrawningState(this.context);
              break;  

            case 'time' :
                  myState = new TimeEditingState(this.context);
              break;          

            default :
                myState = new DrawningState(this.context);
            break;    
        }
    }

    /**
     * Setter method for the state.
     * Normally only called by classes implementing the State interface.
     * 
     * Devemos criar um método setState pra cada Estado
     * @param NEW_STATE
     */
    public void setState(final State NEW_STATE) {
        myState = NEW_STATE;
    }
 
    /**
     * Mouse Actions Methods
     * @param  PVector mouse
     */
    void mousePressed()
    {
        // Inicializa os ponteiros para o retangulo de seleção.
        mouseInit.set(mouseX, mouseY);
        mouseFinal.set(mouseX, mouseY);
        // Seleciona o segmento em questão se for o mouse LEFT
        PVector closestPoint = new PVector();
        PVector q = new PVector(context.mouse.x, context.mouse.y);
        int selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);

        //int closestControlPointIndex  = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));
        PVector closestControlPoint = context.curve.getControlPoint(selectedSegment);

        float distance = q.dist(closestPoint);

        if(distance < 10 && !(myState instanceof OverSketchState) && !(myState instanceof EditingState)){
          myState = new EditingState(this.context);
        }
        
        //console.log("Numero de Pontos de Controle:"+context.curve.getNumberControlPoints());
        //console.log("Pontos Selecionados"+selectedSegment);
        
        if(selectedSegment == context.curve.getNumberControlPoints() - 1 && distance < 10){
            myState = new DrawningState(this.context);
        }

        myState.mousePressed();
    }
    
    void mouseDragged()
    {
        // Cria a caixa de seleção independente do State da aplicação
        mouseFinal.set(mouseX, mouseY);
        context.setSelectionBox(mouseInit, mouseFinal);
        myState.mouseDragged();
    }
    void mouseReleased()
    {
        
        // Resets dragged rectangle
        mouseInit.set(0,0);
        mouseFinal.set(0,0);
        
        myState.mouseReleased();

    }

    void keyPressed(){
        switch (context.key){
            case 'z' :
                this.context.curve.undo();
            break;         

            case 'r' :
                this.context.curve.redo();
            break;    

            // Essa tecla é específica para cada estado, entao devemos implementá-la nas classes de State
            case DELETE :
              myState.keyPressed();
            break;
        }

        myState.keyPressed();
    }
    
    void draw()
    {
        background (255);
        noFill();
        
        myState.draw();

        if(context.isPlayed()){
            context.refreshInterpolator();
            float lastTime = context.lastTime();

            if(lastTime == 0){
                context.stop();
            }else{
                float t = frameCount%int(lastTime);
                context.draw(t);
            }


        }else{
            context.draw(0.0);
        }
    }
}

class Circle extends SceneElement{

	float width, height;
	boolean active;

	Circle(float _width, float _height)
	{
		super(context.mouse);
		this.name = "Circle";
		this.width = _width;
		this.height = _height;
		active = true;
	}

	void draw(float t)
	{
		if(pos.nKeys() < 1){
			return;
		}

		if(t >= pos.keyTime(pos.nKeys()-1)){
			t = pos.keyTime(pos.nKeys()-1);
		}

		PVector position;
		if(!active){
			position = pos.get(0);
		}else{
			position = pos.get(t);
		}

		fill(c);
		stroke(0);
		ellipse(position.x, position.y, this.width, this.height);
	}

	void setWidth(float x){
		this.width = x;
	}

	void setHeight(float x){
		this.height = x;
	}

	float lastTime()
	{
		if(pos.nKeys() < 1)
			return 0;

		return pos.interp.time.get(pos.nKeys()-1);
	}

	boolean isOver(PVector mouse){
                PVector position = pos.get(0);
                float radious = this.width;
		return (mouse.x - position.x)*(mouse.x - position.x) + (mouse.y - position.y)*(mouse.y - position.y) <= radious;
	}
}

//
// Classe que representa uma curva Catmull-Rom
//
class CurveCat
{
  // Control points
  private ArrayList<Property> controlPoints;

  // History of the curve
  private ArrayList<ArrayList<Property>> history;
  private int historyIndex = -1;

  // If it can be decimed
  private boolean decimable;
  private float tolerance;

  // Number of points that the curve can be show
  private int numberDivisions = 100; 

  // Min Ditance wich can be in the curve
  private float minDistance = 5;
  private color strokeColor = color(0);

  CurveCat() 
  {
    controlPoints = new ArrayList<Property>();
    decimable = true;
    tolerance = 10;

    history = new ArrayList<ArrayList<Property>>();
  }

  void clear()
  {
    saveCurve();
    decimable = true;
    controlPoints = new ArrayList<Property>();
  }

  void removeElement(int index){
    saveCurve();
    if (controlPoints.size()>1)
      controlPoints.remove(index);
  }

  Segment getSegment(ArrayList<PVector> pAux, int i)
  { 
         PVector a = i >= 1 ? pAux.get(i-1) : pAux.get(0);
         PVector b = pAux.get(i);
         PVector c = pAux.get(i+1);
         PVector d = i+2 < pAux.size() ? pAux.get(i+2) : pAux.get(i+1);
         return new Segment(a,b,c,d);
  }

  Segment getSegment(int i)
  { 
         return getSegment(controlPoints,i);
  }

 // Método que retorna os principais controlPoints que são essenciais para a curva
 // Passamos como paramêtros os indices do vetor, e o vetor.
  ArrayList<int> DouglasPeuckerReducingInt(ArrayList<Property> cpoints,int index, int end, float epsilon){
    float maxDistance = 0, distance = 0;
    ArrayList<int> result;

    for (int i = 2; i < end - 1; ++i) {
      distance = shortestDistanceToSegment(cpoints.get(i), cpoints.get(1), cpoints.get(end - 1));
      if( distance > maxDistance){
        maxDistance = distance;
        index = i;
      }
    }

    println("maxDistance: "+maxDistance);
    println("epsilon: "+epsilon);
    if(maxDistance > epsilon){
      ArrayList<int> results1, results2;

      // Subdivide os calculos e passa apenas os indices, poupando trabalho para criar vetor auxiliar.
      results1 = DouglasPeuckerReducingInt(cpoints,index,end-1, epsilon);

      results2 = DouglasPeuckerReducingInt(cpoints,1,index, epsilon);

      // Concatenando dois arrays, por que tinha que ser tão difícil ? Custava retornar o array novo ?
      results1.addAll(results2);
      result = (ArrayList<int>) results1.clone();
    }
    else{
      result = cpoints;
    }

    return result;
  }

  // Método que retorna os principais controlPoints que são essenciais para a curva
  ArrayList<Property> DouglasPeuckerReducing(ArrayList<Property> cpoints, float epsilon){
    float maxDistance = 0, distance = 0;
    int index = 0;
    int end = cpoints.size();
    ArrayList<Property> result;

    for (int i = 2; i < end - 1; ++i) {
      distance = shortestDistanceToSegment(cpoints.get(i), cpoints.get(0), cpoints.get(end - 1));
      if( distance > maxDistance){
        maxDistance = distance;
        index = i;
      }
    }
    if(maxDistance > epsilon){
      ArrayList<Property> results1, results2;

      // Fiz isso aqui porque não posso modificar o cpoints
      ArrayList<Property> tmp = new ArrayList<Property>();
      for (int i = index; i < end - 1; ++i) {
          tmp.add(cpoints.get(i));
      }
      results1 = DouglasPeuckerReducing(tmp, epsilon);

      // Fiz isso aqui porque não posso modificar o cpoints
      tmp = new ArrayList<Property>();
      console.log(tmp);
      for (int i = 1; i < index; ++i) {
          tmp.add(cpoints.get(i));
      }
      results2 = DouglasPeuckerReducing(tmp, epsilon);

      // Concatenando dois arrays, por que tinha que ser tão difícil ? Custava retornar o array novo ?
      results1.addAll(results2);
      result = (ArrayList<Property>) results1.clone();
    }else{
      result = cpoints;
    }

    return result;
  }

  // Método para percorrer um segmento de reta que começa em segBegin e terminar em segEnd vendo qual menor distancia para o vetor cpoint
  float shortestDistanceToSegment(Property cpoint, Property segBegin, Property segEnd){
    Property tmp = (Property) segEnd.clone();
    tmp.sub(segBegin);

    int numberDivisions = this.numberDivisions;
    float delta = tmp.mag()/numberDivisions;

    float distance = 9999;

    for (int i = 0; i < numberDivisions; ++i) {
        tmp = (Property) segEnd.clone();
        tmp.mult(i*delta);
        tmp = tmp.adc(segBegin);
        if(tmp.dist(cpoint) < distance){
          distance = tmp.dist(cpoint);
        }
    }

    return distance;
  }


  // Remove pontos de controle de uma curva criada pela lista p que possuam distancia menor que a tolerancia em relação aos pontos da nova curva.
  void decimeCurve(float tolerance)
  {
      Property a = new Property();
      Property b = new Property();
      Property c = new Property();
      Property d = new Property();
      
      Property a2 = new Property();
      Property b2 = new Property();
      Property c2 = new Property();
      Property d2 = new Property();
      
      boolean remove;
     
      int size = controlPoints.size() - 1;
      
      Segment segAux;
      Segment segP;
      ArrayList<Property> pAux;

      boolean wasDecimed = false;

      // Pega o tempo inicial
      int t0 = millis();
      // Pego os vetores essenciais para a curva
      // ArrayList<int> essentialsIndex = DouglasPeuckerReducingInt(controlPoints,0,size, 0.1);
      // ArrayList<Property> essentials = new ArrayList<Property>;
      // // Pega a lista de indices essenciais e depois cria um vetor com esse indices.
      // for (int i = 0; i < essentialsIndex.size();i++)
      //   essentials.add(controlPoints.get(essentialsIndex.get(i)));
      ArrayList<Property> essentials = DouglasPeuckerReducing(controlPoints,100);
      
      // Pega o tempo final
      int t1Douglas = millis();

      int totalTimeDouglas = t1Douglas - t0;
      // Exibe o tempo total gasto em Douglas Peucker
      println("Tempo de processamento Douglas Peucker: "+totalTimeDouglas+" ms");

      // Array que vai conter os vetores a serem testados
      ArrayList<Property> testableControlPoints = (ArrayList<Property>) controlPoints.clone();

      t0 = millis();
      // Removendo os pontos essenciais dos testáveis
      for (int i = 0; i < essentials.size(); ++i) {
        testableControlPoints.remove(essentials.get(i));
      }
      
      println("essentials.size(): "+essentials.size());
      // Adiciona os essenciais no final da lista de testáveis em ordem de prioridade do menos importante pro mais importante.
      for (int i = essentials.size(); i >= 0; --i)
      {
        testableControlPoints.add(essentials.get(i));
      }

      // Percorre os testáveis removendo e verificando com a tolerância.
      for(int i = 0; i < testableControlPoints.size() - 1; i++){

         pAux = new ArrayList<PVector>(controlPoints.size());
         pAux = (ArrayList<PVector>) controlPoints.clone();

         // Pega o vetor e procura qual o indice dele nos controlPoints
         int index = controlPoints.indexOf( testableControlPoints.get(i) );
         pAux.remove(index);
         segAux = getSegment(pAux,index-1);
         remove = true;
         
         for (int j=0; j<=numberDivisions; j++) 
         {
            float t = (float)(j) / (float)(numberDivisions);
            float tAux;
            if (t < 0.5)
            {
                 segP = getSegment(controlPoints,index-1);
                 tAux = t*2;     
            } 
            else 
            {
                segP = getSegment(controlPoints,index);
                tAux = t*2 - 1;
            }
            
            println("segAux: "+typeof(segAux));
            float x1 = curvePoint(segAux.a.get(0), segAux.b.get(0), segAux.c.get(0), segAux.d.get(0), t);
            float y1 = curvePoint(segAux.a.get(1), segAux.b.get(1), segAux.c.get(1), segAux.d.get(1), t);
            PVector v1 = new PVector(x1,y1);

            float x2 = curvePoint(segP.a.get(0), segP.b.get(0), segP.c.get(0), segP.d.get(0), tAux);
            float y2 = curvePoint(segP.a.get(1), segP.b.get(1), segP.c.get(1), segP.d.get(1), tAux);
            PVector v2 = new PVector(x2,y2);

            float distance = v1.dist(v2);
            if(distance >= tolerance){
               remove = false;
            }
         }
         
         if(remove){
           this.controlPoints.remove(index);
           wasDecimed = true;
         }
         
      }

      // Calculating the time of processing of the decime
      int totalTimeDecime = millis() - t0;
      println("Tempo de processamento do decimeCurve: "+totalTimeDecime+" ms");
      this.decimable = wasDecimed;
  }

  // Returns the estimated tangent (a unit vector) at point t
  PVector getTangent (i) {
    Segment segAux = getSegment(i);
    float x = curvePoint(segAux.a.get(0), segAux.b.get(0), segAux.c.get(0), segAux.d.get(0), 0);
    float y = curvePoint(segAux.a.get(1), segAux.b.get(1), segAux.c.get(1), segAux.d.get(1), 0);
    PVector v1 = new PVector(x,y);

    x = curvePoint(segAux.a.get(0), segAux.b.get(0), segAux.c.get(0), segAux.d.get(0), 0.001);
    y = curvePoint(segAux.a.get(1), segAux.b.get(1), segAux.c.get(1), segAux.d.get(1), 0.001);
    PVector v2 = new PVector(x,y);

    tan = PVector.sub(v2, v1);

    //tan.normalize();
    return tan;
  }

  void decimeAll(){
    saveCurve();
    while(this.canBeDecimed()){
      this.decimeCurve(this.tolerance);
    }  
  }

  void setTolerance(float t){
    this.tolerance = t;
  }
  

  boolean canBeDecimed(){
    return this.decimable;
  }

  int getNumberControlPoints () { 
      return controlPoints.size();
  } 

  // Insere o ponto q entre index-1 e index
  void insertPoint(Property q, int index){
    saveCurve();
    controlPoints.add(index,q);
    this.decimable = true;
  }

  void insertPoint(Property q){
    saveCurve();
    controlPoints.add(q);
    this.decimable = true;
  }

  // Altera o valor do elemento index da lista p para q
  void setPoint(PVector q, int index)
  {
    try {
      controlPoints.set(index,q); 
    } catch (Exception e) {
        println("e.toString(): "+e.toString());
        print("Erro ao setar ponto de controle");
    }
  }

  // Retorna as coordenadas (X,Y) para de uma lista de PVectors p dado o index.
  PVector getControlPoint(int index)
  {
    if (controlPoints.size() > index && index >-1)
      return controlPoints.get(index);
    else
      return new PVector(0,0);
  }
  
  // Retorna o indice do ponto de controle mais próximo de q. Caso
  // este não esteja a uma distancia minima especificada por minDistance,
  // retorna -1
  int findControlPoint(PVector q)
  {
    int op=-1;
    float bestDist = 100000;
    for (int i = 0; i < getNumberControlPoints(); i++) 
    {
      float d = controlPoints.get(i).dist(q);
      if (d < minDistance && d < bestDist) 
      { 
        bestDist = d;
        op = i;
      }
    }
    return op;
  }

  // Outra interface para findControlPoint, passando as coordenadas
  // do ponto na lista de argumentos
  int findControlPoint (float x, float y) {
    return findControlPoint (new PVector (x, y));
  }

  // Outra interface para findControlPoint, passando as coordenadas do mouse
  int findControlPoint () {
    return findControlPoint (new PVector (mouseX, mouseY));
  }

  //
  // Retorna o indice do segmento da curva onde o ponto mais proximo de q foi 
  // encontrado. As coordenadas do ponto mais proximo são guardadas em r
  // 
  int findClosestPoint (ArrayList<Property> cps, PVector q, PVector r) {

    // Inicia com -1 para saber se deu certo
    int bestSegment = -1;

    // Melhor distancia é máxima inicialmente
    float bestDistance = 10000000;

    // Melhor distancia do segmento maxima
    float bestSegmentDistance = 100000;

    // Etc...
    float timeBestSegment = 0;
    
    // Para cada ponto de controle
    for (int i = 0; i < cps.size()-1; i++) {
      // Pego o segmento
      Segment seg = getSegment(i);

      // Criando vetor de resultado
      Property result = new Property();
      result.setDimension(3);

      // Para o número de divisões faça
      for (int j=0; j<=numberDivisions; j++) 
      {
        // Calcula o t
        float t = (float)(j) / (float)(numberDivisions);

        //Pega o x e y
        float x = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
        float y = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);

        // Calcula distancia entre o vetor q e o x e y
        float distance = dist(x, y, q.get(0), q.get(1));

        // Se for o primeiro coloca como melhor distancia
        if (j == 0 || distance < bestSegmentDistance) {
          bestSegmentDistance = distance;
          result.set(0, x);
          result.set(1, y);
          result.set(2, 0);
          timeBestSegment = t;
        }
      }
      if (bestSegmentDistance < bestDistance) {
        r.set (result.get(0), result.get(1), 0);
        if(timeBestSegment < 0.5)
          bestSegment = i;
        else
          bestSegment = i + 1;

        if(bestSegment >= controlPoints.size())
            bestSegment = controlPoints.size() - 4;

        bestDistance = bestSegmentDistance;
      }
    }
    return bestSegment;
  }

  int[] getControlPointsBetween(Property init, Property pFinal){
    Property aux;
    println("getControlPointsBetween()");
    ArrayList<Integer> result = new ArrayList<Integer>();
    for (int i = 0; i<controlPoints.size() ; i++){
      Property controlPoint = controlPoints.get(i);

      float dist1 = controlPoint.dist(init);
      float dist2 = controlPoint.dist(pFinal);

      if(pow(dist1,2) + pow(dist2,2) <= pow(init.dist(pFinal),2)){
        result.add(i);
      }
    }

    int[] r = new int[result.size()];

    for (int i = 0; i<result.size(); i++){
        r[i] = result.get(i);
    }

    return r;
  }

  /** FIM DOS MÉTODOS DE EDIÇÃO E CRIAÇÃO **/

  /** MÉTODOS PARA PARAMETRIZAÇÃO DE UMA CURVA **/

  // Retorna o tamanho de uma curva dados uma lista de pontos de controle
  float curveLength()
  {
    return curveLengthBetweenControlPoints(0,getNumberControlPoints()-1);
  }

  float curveLengthBetweenControlPoints(int pBegin, int pEnd)
  {
    float curveLength = 0;
    for (int i = pBegin; i < pEnd; i++) {
      Segment seg = getSegment(i);

      for (int j=0; j<=numberDivisions; j++) 
      {
        float t = (float)(j) / (float)(numberDivisions);
        float x = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
        float y = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
        t = (float)(j+1) / (float)(numberDivisions);
        float x2 = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
        float y2 = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
        float distance = dist(x, y, x2, y2);
        curveLength += distance;
      }
    }
    return (float)curveLength;
  }

  void reAmostragem()
  {
    CurveCat aux = new CurveCat();
    int index = 0;
    for (int i = 0; i < getNumberControlPoints()-1; i++) {
      Segment seg = getSegment(i);

      for (int j=0; j<=numberDivisions; j++) 
      {
        float t = (float)(j) / (float)(numberDivisions);

        Property aux = new Property();
        aux.setDimension(seg.a.size());
        for (int i = 0; i < seg.a.size(); ++i) {
          aux.set(i, curvePoint(seg.a.get(i), seg.b.get(i), seg.c.get(i), seg.d.get(i), t))
        }

        aux.insertPoint(aux, index);
        index++;
      }
    }

    this.controlPoints = aux.controlPoints;

    this.decimable = true;
  }

  void decimeCurve(){
    this.decimeCurve(this.tolerance);
  }

  void saveCurve(){
    if(history.size() > 0){
      if(history.get(history.size() - 1).equals(controlPoints))
        return;
    }
    ArrayList<Property> branch = (ArrayList<Property>) controlPoints.clone();
    history.add(branch);
    historyIndex++;
  }

  void undo(){
    if(historyIndex == history.size() - 1){
      saveCurve();
    }
    historyIndex--;
    update();
  }

  void redo(){
    if(historyIndex + 1 < history.size() && historyIndex != -1){
      historyIndex++;
      update();
    }
  }

  void update(){
    if(historyIndex != -1 && historyIndex < history.size()){
      controlPoints = history.get(historyIndex);
    }
  }

  /**
   MÉTODOS DE DESENHAR
   **/
  // Desenha uma curva de acordo com a lista p de pontos de controle.
  void draw()
  { 
    stroke(this.strokeColor);
    strokeWeight(1.5);
    strokeCap(ROUND);
    for (int i = 0; i < getNumberControlPoints() - 1; i++) {
      Segment seg = getSegment(i);

      beginShape();
        curveVertex(seg.a.get(0), seg.a.get(1));
        curveVertex(seg.b.get(0), seg.b.get(1));
        curveVertex(seg.c.get(0), seg.c.get(1));
        curveVertex(seg.d.get(0), seg.d.get(1));
      endShape();

      beginShape();
        curveVertex(seg.a.get(0), seg.a.get(1));
        curveVertex(seg.b.get(0), seg.b.get(1));
        curveVertex(seg.c.get(0), seg.c.get(1));
        curveVertex(seg.d.get(0), seg.d.get(1));
      endShape();
    }
  }

  // Desenha elipses de acordo com os elementos do tipo PVector da lista p
  void drawControlPoints()
  {
    if ( !(getNumberControlPoints()<4) ){
      fill(secondaryColor);
      stroke(secondaryColor);
      for (int i = 0; i < getNumberControlPoints(); i++) 
      {
        ellipse (controlPoints.get(i).get(0), controlPoints.get(i).get(1), 7, 7);
        text("t: "+controlPoints.get(i).z, controlPoints.get(i).get(0) + 10, controlPoints.get(i).get(1) - 10);
      } 
      fill(255);
    }
  }

  void drawControlPoint(int i)
  {
    fill(mainColor);
    stroke(mainColor);
    if (controlPoints.size() > i && i>-1)
      ellipse(controlPoints.get(i).get(0), controlPoints.get(i).get(1), 10, 10);
  }

  CurveCat clone(){
    CurveCat aux = new CurveCat();
    aux.controlPoints = (ArrayList<Property>) controlPoints.clone();
    return aux;
  }

  String toString(){
    String curve = "Curve: { ControlPoints: [";
    for (int i = 0; i<this.getNumberControlPoints(); i++){
      Property aux = this.getControlPoint(i);
      curve += "(";
      for (int i = 0; i < aux.size(); ++i) {
        curve += aux.get(i)+", ";
      }
      curve += "),";
    }
    curve += "]";
    curve += "}";
    return curve;
  }
}


class Element{
	PVector position;
	CurveCat curve;

	Element(PVector _position){
		position = _position;
	}

	void drag(float dx, float dy)
	{
		position.x += dx;
		position.y += dy;
	}
}
class SceneElement
{
	String name;
	SmoothPositionInterpolator pos;
	color c, curveColor;
	CurveCat curve;

	SceneElement(PVector position)
	{
		c = color(0,0,0);
		curveColor = color(100,100,100);
		name = "Element";
		pos = new SmoothPositionInterpolator(new SmoothInterpolator());
		pos.set(0,position);

		this.curve = new CurveCat();
		this.curve.setTolerance(15);
	}

	void draw(float t){}
	void drawCurve(){
		curve.strokeColor = curveColor;
		noFill();
		if(curve.getNumberControlPoints() >= 4)
			this.curve.draw();


		stroke(0);
	}
	void load(){}
	void update(){}
	float lastTime(){
		return pos.keyTime(pos.nKeys()-1);
	}

	boolean isOver(PVector mouse){
		return true;
	}
}

class Segment{
   public Property a,b,c,d;
  
   Segment(Property _a, Property _b, Property _c, Property _d){
      this.a = _a;
      this.b = _b;
      this.c = _c;
      this.d = _d;
   } 

}

class Text extends Element{
	PFont font;
	String text;
	color c;

	Text(String fontName, float size, PVector _position, String text, color c)
	{
		super(_position);
		font = this.loadFont(fontName, size);
		this.text = text;
		this.c = c;
	}

	void draw()
	{
		pushMatrix();
			fill(this.c);
			textFont(font);
			text(text, position.x, position.y);
		popMatrix();
	}

	private PFont loadFont(String fontName, float size)
	{
		return createFont(fontName, size);
	}

	void setText(String _text)
	{
		this.text = _text;
	}

	String getText()
	{
		return this.text;
	}
}
// Linearly interpolates properties for a specific
// time, given values of these properties at 
// known times (keyframes)
class Interpolator {
  ArrayList<Float> time;
  ArrayList<Property> prop;
 
  // Constructor
  Interpolator() {
    time = new ArrayList<Float>();
    prop = new ArrayList<Property>();
  }
  
  // Returns the number of keyframes
  int nKeys () {
    return time.size();
  }

  // Return the time for keyframe i
  float keyTime(int i) {
    return time.get(i);
  }

  // Return the property for keyframe i
  Property keyProp (int i) {
    return prop.get(i);
  }

  // Returns the greatest index of time which contains a 
  // value smaller or equal to t. If no such value exists, 
  // returns -1.
  int locateTime(float t) {
    int i = -1;
    while (i+1 < time.size() && time.get(i+1) <= t) i++;
    return i;
  }

  // Sets the property p for time t
  void set (float t, Property p) {
    int i = locateTime(t);
    if (i >=0 && time.get(i) == t) {
      prop.set(i,p);
    }
    else {
      time.add(i+1,t);
      prop.add(i+1,p);
    }
  }

  // Gets the (linearly) interpolated property for time t 
  Property get(float t) {
    int i = locateTime(t);
    if (i >=0) {
      if (time.get(i) == t) {
        return prop.get(i);
      }
      else if (i+1 < time.size()) {
        float s = norm (t, time.get(i), time.get(i+1));
        Property p = new Property(), a = prop.get(i), b = prop.get(i+1);
        int n = max (a.size(), b.size());
        for (int k = 0; k < n; k++) {
          p.set(k, lerp(a.get(k), b.get(k), s));
        }
        return p;
      }
      else return prop.get(i);
    }
    else {
      my_assert (time.size() > 0);
      return prop.get(0);
    }
  }

  void clear(){
    time = new ArrayList<Float>();
    prop = new ArrayList<Property>();
  }

};


// A property is an array of floats representing a
// multidimensional point
class Property {
  
  ArrayList<Float> prop = new ArrayList<Float>();
  
  // An empty property
  Property() {
  }

  // Make sure this property has room for storing n floats
  void setDimension (int n) {
    while (size() < n) add(0.0);
  }

  // Returns the number of floats defined for the property
  int size() {
    return prop.size();
  }
  
  // Adds another float to the property
  void add (Float f) {
    prop.add(f);
  }
  
  // A one-float property
  Property (float a) {
    super();
    setDimension (1);
    set (0,a);
  }

  // A two-float property
  Property (float a, float b) {
    super();
    setDimension (2);
    set (0,a);
    set (1,b);
  }

  // A three-float property
  Property (float a, float b, float c) {
    super();
    setDimension (3);
    set (0,a);
    set (1,b);
    set (2,c);
  }

  // Sets the i'th dimension of the property
  // to value v
  void set(int i, float v) {
     my_assert(i>=0);
     while (i >= size()) add(0.0);
     prop.set(i,v);
  }

  // Returns the i'th dimension of the property.
  // Returns 0.0 if that dimension was never set
  Float get(int i) {
    my_assert (i>=0);
    if (i >= size()) return 0.0;
    return prop.get(i);
  }

  Property sub(Property operand){
    // if( this.size() != operand.size())
    //   throw new Exception("Property with diferents dimensions.");

    Property result = new Property();
    result.setDimension(this.size());
    for (int i = 0; i < this.size(); ++i) {
      result.set(i, this.get(i) - operand.get(i));
    }

    return result;
  }

  float mag(){
    float result = 0;
    for (int i = 0; i < this.size(); ++i) {
      result += pow(get(i), 2);
    }

    return sqrt(result);
  }

  Property adc(Property operand){
    // if( this.size() != operand.size())
    //   throw new Exception("Property with diferents dimensions.");

    Property result = new Property();
    result.setDimension(this.size());
    for (int i = 0; i < this.size(); ++i) {
      result.set(i, this.get(i) + operand.get(i));
    }

    return result;
  }

  void mult(float constant){
    for (int i = 0; i < this.size(); ++i) {
      this.set(i, this.get(i)*constant);
    }
  }

  Property clone(){
    Property result = new Property();
    result.setDimension(this.size());
    for (int i = 0; i < this.size(); ++i) {
      result.set(i, this.get(i));
    }

    return result;
  }

  float dist(Property operand){
    return (operand.sub(this)).mag();
  }


};


// Smooth (Cubic) interpolation of properties
class SmoothInterpolator extends Interpolator {

  // Gets the Catmull-Rom interpolated property for time t 
  Property get(float t) {
    int i = locateTime(t);
    if (i >= 0) {
      if (time.get(i) == t) return prop.get(i);
      if (i+1 < time.size()) {
        // Compute the 4 points that will be used
        // to interpolate the property 
        Property a,b,c,d;
        a = b = prop.get(i); 
        c = d = prop.get(i+1); 
        if (i > 0) a = prop.get(i-1); 
        if (i+2 < time.size()) d = prop.get(i+2);
        // Interpolate the parameter
        float s = norm (t, time.get(i), time.get(i+1)); 
        // Now interpolate the property dimensions
        Property p = new Property(); 
        int n = max (a.size(), b.size());
        for (int k = 0; k < n; k++) {
          p.set(k, curvePoint(a.get(k), b.get(k), c.get(k), d.get(k), s));
        }
        return p;
      }
      else return prop.get(i);
    }
    else {
      my_assert (time.size() > 0);
      return prop.get(0);
    }
  }

};


// Wraps a interpolator class so that 
// methods return PVectors representing positions rather 
// than generic properties
class SmoothPositionInterpolator {
  
  // The interpolator being wrapped
  Interpolator interp;
  
  // Constructor
  SmoothPositionInterpolator (interpolator interp) {
    this.interp = interp;
  }

  // Converts a property to a PVector
  PVector toPVector (Property p) {
    return new PVector(p.get(0), p.get(1), p.get(2));
  }
  
  // Returns the number of keyframes
  int nKeys () {
    return interp.time.size();
  }

  // Return the time for keyframe i
  float keyTime(int i) {
    return interp.time.get(i);
  }

  // Return the property for keyframe i
  PVector keyPos (int i) {
    return toPVector(interp.prop.get(i));
  }

  // Sets the position for time t
  void set (float t, PVector p) { 
    interp.set(t, new Property (p.x, p.y, p.z));
  }
  
  // Gets the position at time t
  PVector get (float t) {
    return toPVector (interp.get(t));
  }
  
  // Returns the estimated tangent (a unit vector) at point t
  PVector getTangent (float t) {
    PVector tan = (t < 0.01) ?
                   PVector.sub(get(t+0.01),get(t)) :
                   PVector.sub(get(t),get(t-0.01));
    tan.normalize();
    return tan;
  }
  
  // Draws key frames as circles and the curve 
  // as n segments equally spaced in time
  void draw(int n) {
    pushStyle();
    noFill();
    float tickSize = 5;
    float tMax = keyTime(nKeys()-1);
    PVector p0 = get(0);
    for (int i = 0; i < n; i++) {
      float t = (float) i * tMax / (n-1);
      PVector p = get(t);
      PVector tan = getTangent(t);
      tan.mult(tickSize);
      line(p0.x,p0.y,p.x,p.y);
      line(p.x-tan.y, p.y+tan.x,p.x+tan.y, p.y-tan.x);
      p0 = p;
    }
    popStyle();
    for (int i = 0; i < interp.nKeys(); i++) {
      Property p = interp.keyProp(i);
      ellipse(p.get(0), p.get(1), 10, 10);
    }
  }

  void clear(){
    interp.clear();
  }
}


class CircleState extends State {

    CircleState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
        Circle c = new Circle(20,20);
        println("Instanciando Circle...");
        console.log("Instanciando Circle...");
        context.addElement(c);  
        context.setSelectedElement(c);
    }

    public void mouseDragged(){
        Circle c = context.getSelectedElement();
        PVector pos = c.pos.get(0);

        PVector pMouse = context.getpMouse();
        float dx = abs(pMouse.x - pos.x);
        float dy = abs(pMouse.y - pos.y);

        c.setWidth(dx);
        c.setHeight(dx);
    }
    
    public void mouseReleased() 
    {
        stateContext.setStateName("draw");
    }

    public void keyPressed(){
      
    }

    public void draw()
    {

  	}
}
class DrawningState extends State {

    float distanceToSelect = 5;
    private boolean canSketch;
    float t, ms;

    DrawningState(Context _context){
      super(_context);

      context.curve.decimeAll();
      // Adding a comentary
    }

    public void mousePressed() 
    {
      t = 0;
      ms = frameCount;
      // Então seleciona o mais próximo
      int selectedSegment = context.curve.findControlPoint(context.mouse);
      // Verifica se o local clicado é proximo do final da curva;
      if (selectedSegment == context.curve.getNumberControlPoints()-1){ canSketch = true; }
      else { canSketch = false; }
        
      if (canSketch){
        this.context.curve.insertPoint(new Property(this.context.mouse.x, this.context.mouse.y));
      }
    }
    
    public void mouseReleased(PVector mouse) 
    {
        super.mouseReleased();
    	  // Retorna o estado de poder desenhar para FALSE
        //canSketch = false;

        context.refreshInterpolator();
    }
    public void mouseDragged()
    {	
      float elapsed = 0;
      if(frameCount != ms){
        elapsed = frameCount - ms;
      }
      ms = frameCount;
      t = t + elapsed;

      if (canSketch){
        context.mouse.add(new PVector(0,0,t));
  		  context.curve.insertPoint( new Property(context.mouse.x, context.mouse.y, context.mouse.z), context.curve.getNumberControlPoints());
      }
    }

    public void keyPressed(){
      context.curve.clear(); 
      context.selectedSegments = new int[0];
    }

    public void draw()
    {
    	
  	}
}
class EditingState extends State {

    int cpsMovimenteds = 5;
    PVector originalPositionDragged;
    
    EditingState(Context context){
      super(context);
    }

    public void mousePressed() 
    {

        if(context.mouseButton == RIGHT){

            // Verfica se tem nenhum element selecionado
            if(context.selectedSegments.length == 0)
            {
              // Create a variable for the closestpoint
              PVector closestPoint = new PVector();

              //Vector that
              PVector q = new PVector(context.mouse.x, context.mouse.y);

              // Context finde the closest point gives the selectedSegment
              int selectedSegment = context.curve.findClosestPoint(context.curve.controlPoints, q, closestPoint);

              float distance = q.dist(closestPoint);
              if (distance < distanceToSelect)
              {
               context.selectedSegments = new int[1];
               context.selectedSegments[0] = selectedSegment;
              }
            }

            // Remove todos os segmentos selecionados
            for (int i = context.selectedSegments.length - 1; i>=0; i--){
              context.curve.removeElement(context.selectedSegments[i]);
            }

            // Remove a seleção
            context.diselect();
      }
      else
      {
        // Seleciona o segmento em questão se for o mouse LEFT
        PVector closestPoint = new PVector();
        PVector q = new PVector(context.mouse.x, context.mouse.y,0);
        int selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
        //int closestControlPointIndex  = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));
        PVector closestControlPoint = context.curve.getControlPoint(selectedSegment);

        float distanceControlPoint = q.dist(closestControlPoint);
        float distance = q.dist(closestPoint);

        // Verifica se a distancia é maior do que o limite para selecionar
        if(distance > distanceToSelect)
        {
              context.diselect();
              this.context.selectedSegments = new int[0];
        }
        else
        {
          boolean selected = false;
          
          for (int i = 0; i<context.selectedSegments.length; i++){
            if(selectedSegment == context.selectedSegments[i]){
              selected = true;
              selectedSegment = i;
              break;
            }
          }

          if(!selected){
            context.selectedSegments = new int[1];
            context.selectedSegments[0] = selectedSegment;
            float myTime = context.curve.getControlPoint(selectedSegment).z;
            context.alignTimes(myTime);
            selectedSegment = 0;
          }

          if(distanceControlPoint > 50){
              SceneElement e = context.getSelectedElement(); 
              PVector d1 = context.curve.getControlPoint(selectedSegment);
              context.curve.insertPoint(q, context.selectedSegments[selectedSegment]);
              context.selectedSegments[selectedSegment]++;
          }
        }  
      }
    }

    public void mouseReleased() 
    {
        if(context.selectedSegments.length == 0)
        {
            context.selectedSegments = context.curve.getControlPointsBetween(context.mouseInit, context.mouseFinal);
        }

        context.refreshInterpolator();
        
    }

    public void mouseDragged()
    {
        context.stop();

        if (context.mouseButton == LEFT)
        {
          // Se tiver selecionado vários mantém a mesma movimentação
          if (context.selectedSegments.length > 1)
          {
            // Pega a variação de x e de y
            float dx = context.mouse.x - context.pMouse.x;
            float dy = context.mouse.y - context.pMouse.y;

            // Soma aos elementos selecionados
            for (int i = 0; i<context.selectedSegments.length; i++){
              PVector controlPoint = context.curve.getControlPoint(context.selectedSegments[i]);
              context.curve.setPoint(new PVector(controlPoint.x + dx, controlPoint.y + dy, controlPoint.z), context.selectedSegments[i]);
            }
          }else if(context.selectedSegments.length == 1){

            // Pega a variação de x e de y
            float dx = context.mouse.x - context.pMouse.x;
            float dy = context.mouse.y - context.pMouse.y;

            // Soma aos elementos selecionados
            for (int i = -this.cpsMovimenteds; i< this.cpsMovimenteds; i++){

              if(context.selectedSegments[0] + i < 0){
                continue;
              }

              if(context.selectedSegments[0] + i >= context.curve.getNumberControlPoints()){
                return;
              }

              float tdx;
              float tdy;
              if( i != 0){
                tdx = dx/(2*abs(i));
                tdy = dy/(2*abs(i));
              }else{
                tdx = dx;
                tdy = dy;
              }

              PVector controlPoint = context.curve.getControlPoint(context.selectedSegments[0] + i);
              context.curve.setPoint( new PVector(controlPoint.x + tdx, controlPoint.y + tdy, controlPoint.z) , context.selectedSegments[0] + i);
            }

          }
        }
    }

    public void keyPressed(){
      if(context.selectedSegments.length != 0){
        for (int i = context.selectedSegments.length - 1; i>=0; i--){
          context.curve.removeElement(context.selectedSegments[i]);
        }

        context.diselect();  
      }
    }

    public void draw()
    {
        if(context.selectedSegments.length == 0)
        {
            // Desenha caixa de seleção com Alpha 50
            fill(mainColor, 50);
            stroke(mainColor, 50);
            rect(context.mouseInit.x, 
            context.mouseInit.y, 
            context.mouseFinal.x - context.mouseInit.x, 
            context.mouseFinal.y - context.mouseInit.y);
        }

        // Draw control points if have a curve;
        context.curve.drawControlPoints();
        
    }
}
class FontState extends State {

    Text text = null;

    FontState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
      if(text == null)
        text = new Text("visitor1.ttf", 
          20, 
          new PVector(context.mouse.x, context.mouse.y), 
          "", 
          color(0,0,0));
    }
    
    public void mouseReleased(PVector mouse) 
    {

    }
    public void mouseDragged()
    {	
      float dx = context.mouse.x - context.pMouse.x;
      float dy = context.mouse.y - context.pMouse.y;

      text.drag(dx, dy);
    }

    public void keyPressed(){
      String text = this.text.getText();
      text = text + key; 
      this.text.setText(text);
    }

    public void draw()
    {
      if(this.text != null){
        this.text.draw();
      }
  	}
}
class OverSketchState extends State {

    CurveCat aux;

    OverSketchState(Context context){
      super(context);
      this.aux = new CurveCat();
    }

    public void mousePressed() 
    {
        if(this.context.mouseButton == LEFT){
            // Seleciona o segmento em questão se for o mouse LEFT
            int selectedSegment = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));

            PVector closestPoint = new PVector();
            PVector q = new PVector(context.mouse.x, context.mouse.y);
            selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
            float distance = q.dist(closestPoint);

            if(distance > distanceToSelect){
                  context.diselect();
            }

            context.curve.insertPoint(q, selectedSegment + 1);
            selectedSegment++;

            context.selectedSegments = new int[1];
            context.selectedSegments[0] = selectedSegment;

            this.aux = new CurveCat();
            this.aux.strokeColor = color(0,0,0,50);

            for (int i = 0; i<selectedSegment; i++){
                q = context.curve.getControlPoint(i);
                this.aux.insertPoint(q, i);
            }

            mouseInit.set(0, 0);
            mouseFinal.set(0, 0);
        }
    }

    public void mouseReleased() 
    {
        if(this.aux.getNumberControlPoints() == 0){
            return;
        }
        int selectedSegment = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));

        PVector closestPoint = new PVector();
        PVector q = new PVector(context.mouse.x, context.mouse.y);
        selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
        float distance = q.dist(closestPoint);

        if(distance > distanceToSelect){
              context.diselect();
        }

        context.selectedSegments = new int[1];
        context.selectedSegments[0] = selectedSegment;

        context.curve.insertPoint(q, selectedSegment + 1);
        selectedSegment++;

        for (int i = selectedSegment; i<context.curve.getNumberControlPoints(); i++){
            q = context.curve.getControlPoint(i);
            this.aux.insertPoint(q, this.aux.getNumberControlPoints());
        }

        context.curve = null;
        context.curve = aux;

        context.curve.strokeColor = color(0);

        super.mouseReleased();
    }

    public void mouseDragged()
    {
        if(context.mouseButton == LEFT){
            this.aux.insertPoint(context.mouse, this.aux.getNumberControlPoints());
        }
    }

    public void keyPressed(){

    }

    public void draw()
    {
        if (this.aux.getNumberControlPoints() >=4) 
            this.aux.draw();

        //context.curve.drawControlPoints();
        if(context.selectedSegments.length == 0)
        {
            // Desenha caixa de seleção com Alpha 50
            fill(mainColor, 50);
            stroke(mainColor, 50);
            rect(context.mouseInit.x, 
              context.mouseInit.y, 
              context.mouseFinal.x - context.mouseInit.x, 
              context.mouseFinal.y - context.mouseInit.y);
        }

        // Draw control points;
        if(context.selectedSegments.length > 0)
        {
            for (int i = 0; i<context.selectedSegments.length; i++)
            {
                //context.curve.drawControlPoint(context.selectedSegments[i]);
            }
        }
    }
}

class SelectState extends State
{
	SelectState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
    	for (SceneElement o : context.sceneElements) {
    		if(o.isOver(context.mouse)){
    			context.setSelectedElement(o);
                        return;
    		}
    	}
    }
    
    public void mouseReleased(PVector mouse) 
    {

    }
    
    public void mouseDragged()
    {
        //stateContext.setState(new DrawningState(context));
        //stateContext.mouseDragged();
    }

    public void keyPressed(){
      
    }

    public void draw()
    {

    }
}

class State
{
	Context context;
    // Constants
    final float distanceToSelect = 30;

     // Variaveis de Curvas
    int selectedSegment;
    PVector closestPoint;
    PVector q;

	State(Context _context){
		context = _context;
	}

	State(){
		context = new Context();
  	}

	void mousePressed(){
	};
	void mouseDragged(){

	};
	void mouseReleased(){
		context.curve.decimeAll();
	};

	void keyPressed(){

	};
	void draw(){};
}
	
class TimeEditingState extends State {

    float timeSpacing = 2;
    SceneElement element;
    
    TimeEditingState(Context context){
      super(context);
      element = context.getSelectedElement();
    }

    public void mousePressed() 
    {

    }

    public void mouseReleased() 
    {

    }

    public void mouseDragged()
    {

    }

    public void keyPressed(){

    }

    public void draw()
    {
      for (int i = 0; i < element.lastTime(); ++i) {
        if(i % timeSpacing == 0){
          println("test");
          PVector pos = element.pos.get(i);
          println("pos: "+pos);
          fill(mainColor);
          stroke(mainColor);
          //ellipse(pos.x, pos.y, 10, 10);
        }
      }
    }
}