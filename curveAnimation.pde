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
	SmoothPositionInterpolator pos;
	boolean play;

	Context(){
		selectedSegments = new int[0];
		this.curve = new CurveCat();
		this.curve.setTolerance(7);

		pos = new SmoothPositionInterpolator();
		play = false;
	}

	void updateContext(PVector mouse, PVector pmouse, int _mouseButton, int keyCode, char key,
		PVector _mouseInit, PVector _mouseFinal){
		this.mouse = mouse;
		this.pMouse = pmouse;
		this.keyCode = keyCode;
		this.key = key;
		this.mouseButton = _mouseButton;
		this.mouseInit = _mouseInit;
		this.mouseFinal = _mouseFinal;
	}

	void setMouseCount(int _mouseCount){
		this.mouseCount = _mouseCount;
	}

	void setSelectionBox(PVector ini, PVector _final){
		this.mouseInit = ini;
		this.mouseFinal = _final;
	}

	void print(){
		println("Context[");
		println("this.mouse: "+this.mouse+",");
		println("this.pMouse: "+this.pMouse+",");
		println("this.keyCode: "+this.keyCode+",");
		println("this.key: "+this.key+",");
		Utils.print_r(selectedSegments);
	}

	void diselect(){
		this.selectedSegments = new int[0];
	}

	boolean isPlayed(){
		return play;
	}

	void play(){
		frameCount = 0;
		pos.clear();

		float length = curve.curveLength(), distance = 0, t = 0;
		float speed = length/500;

		for (int i = 0; i<curve.getNumberControlPoints() - 1; i++){
			PVector p = curve.getControlPoint(i);

			distance = curve.curveLengthBetweenControlPoints(i, i + 1);
			t += distance/speed;

			pos.set(t, p);
		}

		play = true;
	}

	void refreshInterpolator(){

		if(!this.isPlayed()){
			return;
		}

		pos.clear();

		float length = curve.curveLength(), distance = 0, t = 0;
		float speed = length/200;

		for (int i = 0; i<curve.getNumberControlPoints() - 1; i++){
			PVector p = curve.getControlPoint(i);
			
			distance = curve.curveLengthBetweenControlPoints(i, i + 1);
			t += distance/speed;

			pos.set(t, p);
		}

		play = true;
	}

	void stop(){
		play = false;
	}

}//
// Classe que representa uma curva Catmull-Rom
//
class CurveCat
{
  // Control points
  ArrayList<PVector> controlPoints;

  // If it can be decimed
  boolean decimable;
  float tolerance;

  // Number of points that the curve can be show
  int numberDivisions = 10; 

  // Min Ditance wich can be in the curve
  float minDistance = 5;
  color strokeColor = color(0);

  CurveCat() 
  {
    controlPoints = new ArrayList<PVector>();
    decimable = true;
    tolerance = 7;
  }

  void clear()
  {
    decimable = true;
    controlPoints = new ArrayList<PVector>();
  }

  void removeElement(int index){
    if (controlPoints.size()>1)
      controlPoints.remove(index);
  }

  Segment getSegment(ArrayList<PVector> pAux, int i)
  { 
         //printArray(pAux);
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

  // Remove pontos de controle de uma curva criada pela lista p que possuam distancia menor que a tolerancia em relação aos pontos da nova curva.
  void decimeCurve(float tolerance)
  {
      PVector a = new PVector();
      PVector b = new PVector();
      PVector c = new PVector();
      PVector d = new PVector();
      
      PVector a2 = new PVector();
      PVector b2 = new PVector();
      PVector c2 = new PVector();
      PVector d2 = new PVector();
      
      boolean remove;
     
      int size = controlPoints.size() -1;
      
      Segment segAux;
      Segment segP;
      ArrayList<PVector> pAux;

      boolean wasDecimed = false;

      for(int i = 1; i < size; i++){
         pAux = new ArrayList<PVector>(controlPoints.size());
         pAux = (ArrayList<PVector>) controlPoints.clone();
         pAux.remove(i);
         segAux = getSegment(pAux,i-1);
         remove = true;
         
         for (int j=0; j<=numberDivisions; j++) 
         {
            float t = (float)(j) / (float)(numberDivisions);
            float tAux;
            if (t < 0.5)
            {
                 segP = getSegment(controlPoints,i-1);
                 tAux = t*2;     
            } 
            else 
            {
                segP = getSegment(controlPoints,i);
                tAux = t*2 - 1;
            }
            
            float x = curvePoint(segAux.a.x, segAux.b.x, segAux.c.x, segAux.d.x, t);
            float y = curvePoint(segAux.a.y, segAux.b.y, segAux.c.y, segAux.d.y, t);
            float x2 = curvePoint(segP.a.x, segP.b.x, segP.c.x, segP.d.x, tAux);
            float y2 = curvePoint(segP.a.y, segP.b.y, segP.c.y, segP.d.y, tAux);
            float dist = dist (x, y, x2, y2);
            if(dist >= tolerance){
               remove = false;
            }
         }
         
         if(remove){
           this.removeElement(i);
           wasDecimed = true;
           i--;
           size--;
         }
         
      }

      this.decimable = wasDecimed;
  }

  void decimeAll(){
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
  void insertPoint(PVector q, int index){
    controlPoints.add(index,q);
    this.decimable = true;
  }

  void insertPoint(PVector q){
    controlPoints.add(q);
    this.decimable = true;
  }

  // Altera o valor do elemento index da lista p para q
  void setPoint(PVector q, int index)
  {
    try {
      controlPoints.set(index,q);    
    } catch (Exception e) {
        //print("Erro ao setar ponto de controle");
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
    return findControlPoint (mouseX, mouseY);
  }

  //
  // Retorna o indice do segmento da curva onde o ponto mais proximo de q foi 
  // encontrado. As coordenadas do ponto mais proximo são guardadas em r
  // 
  int findClosestPoint (ArrayList<PVector> cps, PVector q, PVector r) {

    int bestSegment = -1;
    float bestDistance = 10000000;
    float bestSegmentDistance = 100000;
    
    for (int i = 0; i < cps.size()-1; i++) {
      Segment seg = getSegment(i);

      PVector result = new PVector();
      for (int j=0; j<=numberDivisions/2; j++) 
      {
        float t = (float)(j) / (float)(numberDivisions);
        float x = curvePoint(seg.a.x, seg.b.x, seg.c.x, seg.d.x, t);
        float y = curvePoint(seg.a.y, seg.b.y, seg.c.y, seg.d.y, t);
        float dist = dist (x, y, q.x, q.y);

        if (j == 0 || dist < bestSegmentDistance) {
          bestSegmentDistance = dist;
          result.set(x, y, 0);
        }
      }
      if (bestSegmentDistance < bestDistance) {
        r.set (result.x, result.y, 0);
        bestSegment = i;
        bestDistance = bestSegmentDistance;
      }
    }
    return bestSegment;
  }

  int[] getControlPointsBetween(PVector init, PVector pFinal){
    PVector aux;

    ArrayList<Integer> result = new ArrayList<Integer>();
    for (int i = 0; i<controlPoints.size() ; i++){
      PVector controlPoint = controlPoints.get(i);

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
    float curveLength = 0;
    for (int i = 0; i < getNumberControlPoints()-1; i++) {
      Segment seg = getSegment(i);

      for (int j=0; j<=numberDivisions; j++) 
      {
        float t = (float)(j) / (float)(numberDivisions);
        float x = curvePoint(seg.a.x, seg.b.x, seg.c.x, seg.d.x, t);
        float y = curvePoint(seg.a.y, seg.b.y, seg.c.y, seg.d.y, t);
        t = (float)(j+1) / (float)(numberDivisions);
        float x2 = curvePoint(seg.a.x, seg.b.x, seg.c.x, seg.d.x, t);
        float y2 = curvePoint(seg.a.y, seg.b.y, seg.c.y, seg.d.y, t);
        float dist = dist (x, y, x2, y2);
        curveLength += dist;
      }
    }
    return (float)curveLength;
  }

  float curveLengthBetweenControlPoints(int pBegin, int pEnd)
  {
    float curveLength = 0;
    for (int i = pBegin; i < pEnd; i++) {
      Segment seg = getSegment(i);

      for (int j=0; j<=numberDivisions; j++) 
      {
        float t = (float)(j) / (float)(numberDivisions);
        float x = curvePoint(seg.a.x, seg.b.x, seg.c.x, seg.d.x, t);
        float y = curvePoint(seg.a.y, seg.b.y, seg.c.y, seg.d.y, t);
        t = (float)(j+1) / (float)(numberDivisions);
        float x2 = curvePoint(seg.a.x, seg.b.x, seg.c.x, seg.d.x, t);
        float y2 = curvePoint(seg.a.y, seg.b.y, seg.c.y, seg.d.y, t);
        float dist = dist (x, y, x2, y2);
        curveLength += dist;
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
        float x = curvePoint(seg.a.x, seg.b.x, seg.c.x, seg.d.x, t);
        float y = curvePoint(seg.a.y, seg.b.y, seg.c.y, seg.d.y, t);

        aux.insertPoint(new PVector(x,y), index);
        index++;
      }
    }

    this.controlPoints = aux.controlPoints;

    this.decimable = true;
  }

  void decimeCurve(){
    this.decimeCurve(this.tolerance);
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
      curve (seg.a.x, seg.a.y, seg.b.x, seg.b.y, seg.c.x, seg.c.y, seg.d.x, seg.d.y);
    }
  }

  // Desenha elipses de acordo com os elementos do tipo PVector da lista p
  void drawControlPoints()
  {
    fill(secondaryColor);
    stroke(secondaryColor);
    for (int i = 0; i < getNumberControlPoints(); i++) 
    {
      ellipse (controlPoints.get(i).x, controlPoints.get(i).y, 7, 7);
    }
    fill(255);
  }
  void drawControlPoint(int i)
  {
    fill(mainColor);
    stroke(mainColor);
    if (controlPoints.size() > i && i>-1)
      ellipse(controlPoints.get(i).x, controlPoints.get(i).y, 10, 10);
  }

  CurveCat clone(){
    CurveCat aux = new CurveCat();
    aux.controlPoints = (ArrayList<PVector>) controlPoints.clone();
    return aux;
  }

  String toString(){
    String curve = "Curve: { ControlPoints: [";
    for (int i = 0; i<this.getNumberControlPoints(); i++){
      PVector aux = this.getControlPoint(i);
      curve += "("+aux.x+", "+aux.y+"),";
    }
    curve += "]";
    curve += "}";
    return curve;
  }
}

class DrawningState extends State {

    float distanceToSelect = 5;
    private boolean canSketch;

    DrawningState(Context _context){
      super(_context);

      context.curve.decimeAll();
    }

    public void mousePressed() 
    {
      // Então seleciona o mais próximo
      int selectedSegment = context.curve.findControlPoint(context.mouse);
      // Verifica se o local clicado é proximo do final da curva;
      if (selectedSegment == context.curve.getNumberControlPoints()-1){ canSketch = true; }
      else { canSketch = false; }
        
      if (canSketch){
        this.context.curve.insertPoint(this.context.mouse);
      }
    }
    
    public void mouseReleased(PVector mouse) 
    {
        super.mouseReleased();
    	  // Retorna o estado de poder desenhar para FALSE
        canSketch = false;
    }
    public void mouseDragged()
    {	
      if (canSketch)
  		  context.curve.insertPoint(context.mouse, context.curve.getNumberControlPoints());
    }

    public void keyPressed(){
      context.curve.clear(); 
      context.selectedSegments = new int[0];
    }

    public void draw()
    {
    	
  	}

    public void drawInterface()
    {
      int posX = width-80;
	    int posY = height-20;
      fill(mainColor);
      stroke(mainColor);
      rect(posX-10,posY-20,80,30);
      fill(255);
      text("Creating", posX, posY);
    }
 
}class EditingState extends State {

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
              // Então seleciona o mais próximo
              PVector closestPoint = new PVector();
              PVector q = new PVector(context.mouse.x, context.mouse.y);
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
        PVector q = new PVector(context.mouse.x, context.mouse.y);
        int selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
        //int closestControlPointIndex  = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));
        PVector closestControlPoint = context.curve.getControlPoint(selectedSegment);

        float distanceControlPoint = q.dist(closestControlPoint);
        float distance = q.dist(closestPoint);

        // Verifica se a distancia é maior do que o limite para selecionar
        if(distance > distanceToSelect)
        {
              context.diselect();
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
            selectedSegment = 0;
          }

          if(distanceControlPoint > 10){
              context.curve.insertPoint(q, context.selectedSegments[selectedSegment] + 1);
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
              context.curve.setPoint(new PVector(controlPoint.x + dx, controlPoint.y + dy), context.selectedSegments[i]);
            }
          }else if(context.selectedSegments.length != 0){

            // Pega a variação de x e de y
            float dx = context.mouse.x - context.pMouse.x;
            float dy = context.mouse.y - context.pMouse.y;

            // Soma aos elementos selecionados
            for (int i = -this.cpsMovimenteds; i< this.cpsMovimenteds; i++){
              float tdx;
              float tdy;
              if( i != 0){
                tdx = dx/(5*abs(i));
                tdy = dy/(5*abs(i));
              }else{
                tdx = dx;
                tdy = dy;
              }

              PVector controlPoint = context.curve.getControlPoint(context.selectedSegments[0] + i);
              context.curve.setPoint(new PVector(controlPoint.x + tdx, controlPoint.y + tdy), context.selectedSegments[0] + i);
            }

          }
        }

        context.refreshInterpolator();
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
        context.curve.drawControlPoints();
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
                context.curve.drawControlPoint(context.selectedSegments[i]);
            }
        }
    }

    public void drawInterface()
    {
        int posX = width-80;
        int posY = height-20;

        fill(secondaryColor);
        stroke(secondaryColor);
        rect(posX-10,posY-20,80,30);
        fill(255);
        text("Editing", posX, posY);
    }
 
}// Linearly interpolates properties for a specific
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
      assert (time.size() > 0);
      return prop.get(0);
    }
  }

  void clear(){
    time = new ArrayList<Float>();
    prop = new ArrayList<Property>();    
  }
};

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
    @Override
    public void drawInterface()
    {
        int posX = width-80;
        int posY = height-20;

        fill(secondaryColor);
        stroke(secondaryColor);
        rect(posX-10,posY-20,80,30);
        fill(255);
        text("OverSketch", posX, posY);
    }
 
}// A property is an array of floats representing a
// multidimensional point
class Property extends ArrayList<Float> {
  
  // An empty property
  Property() {
    super();
  }

  // A one-float property
  Property (float a) {
    super();
    set (0,a);
  }

  // A two-float property
  Property (float a, float b) {
    super();
    set (0,a);
    set (1,b);
  }

  // A three-float property
  Property (float a, float b, float c) {
    super();
    set (0,a);
    set (1,b);
    set (2,c);
  }

  // Sets the i'th dimension of the property
  // to value v
  void set(int i, float v) {
     assert(i>=0);
     while (i >= size()) add(0.0);
     super.set(i,v);
  }

  // Returns the i'th dimension of the property.
  // Returns 0.0 if that dimension was never set
  Float get(int i) {
    assert (i>=0);
    if (i >= size()) return 0.0;
    return super.get(i);
  }
};
class Segment{
   PVector a,b,c,d;
  
   Segment(PVector _a, PVector _b, PVector _c, PVector _d){
      a = _a;
      b = _b;
      c = _c;
      d = _d;
   } 
   
   Segment(){
   
   }
  
}
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
      assert (time.size() > 0);
      return prop.get(0);
    }
  }

};

// Wraps a interpolator class so that 
// methods return PVectors representing positions rather 
// than generic properties
class SmoothPositionInterpolator {
  
  // The interpolator being wrapped
  SmoothInterpolator interp;
  
  // Constructor
  SmoothPositionInterpolator () {
    this.interp = new SmoothInterpolator();
  }

  // Converts a property to a PVector
  PVector toPVector (Property p) {
    return new PVector (p.get(0), p.get(1), p.get(2));
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
	void drawInterface(){};
}
	public class StateContext {

    private State myState;
    private Context context;
    private boolean debug;

        /**
         * Standard constructor
         */
    StateContext(Context _context) 
    {
        debug = false;
        setState(new DrawningState(_context));
        
    }

    public void setContext(Context _context){
        this.context = _context;
    }

    public void debug(){
        debug = !debug;
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
        // Verifica se clicou no botão "Clear";
        if(Utils.mouseOverRect(new PVector(mouseX, mouseY),width/2 + 60,height-40, 110, 30)){
            context.curve.clear();
            context.pos.clear();
            context.stop();
            this.setState(new DrawningState(context));
            context.selectedSegments = new int[0];
            return;
        }

        if(Utils.mouseOverRect(new PVector(mouseX, mouseY),width-80-130, height-20-20, 110, 30)){

            if(this.myState instanceof OverSketchState){
                this.setState(new EditingState(context));
                return;
            }

            this.setState(new OverSketchState(context));
            context.selectedSegments = new int[0];
            return;
        }

        if(Utils.mouseOverRect(new PVector(mouseX, mouseY),20, height-50, 50, 50)){
            if(context.isPlayed())
                context.stop();
            else
                context.play(); 

            return;
        }

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

        if(selectedSegment == context.curve.getNumberControlPoints() - 2 && distance < 10){
            myState = new DrawningState(this.context);
        }

        myState.mousePressed();
    }
    void mouseDragged()
    {
        myState.mouseDragged();
    }
    void mouseReleased()
    {
        myState.mouseReleased();
    }

    void keyPressed(){
        switch (context.key){
            case '1' :
              this.setState(new DrawningState(this.context));
            break;  

            case '2' :
                this.setState(new EditingState(this.context));
            break;  

            case 'd' :
              this.debug();
            break;  

            case 'r' :
                this.context.curve.reAmostragem();
            break;    

            case 's' :
                this.context.curve.decimeCurve();
            break;   

            case 'p' :
                if(context.isPlayed())
                    context.stop();
                else
                    context.play();
             break;     

            // Essa tecla é específica para cada estado, entao devemos implementá-la nas classes de State
            case DELETE :
              myState.keyPressed();
            break;
        }
    }
    void draw()
    {
        background (255);
        noFill();
        if (context.curve.getNumberControlPoints() >=4) 
            context.curve.draw();
        myState.draw();

          if(context.isPlayed()){
            float lastTime = context.pos.keyTime(context.pos.nKeys()-1);
            float t = frameCount%int(lastTime);
            PVector p = context.pos.get(t);
            PVector tan = context.pos.getTangent(t);
            stroke(100,100,100);
            context.pos.draw (100);
            float ang = atan2(tan.y,tan.x);

            pushMatrix();
            translate (p.x,p.y);
            rotate (ang);
            noStroke();
            fill(mainColor);
            ellipse(0,0, 20, 20);
            popMatrix();
          }
    }
    void drawInterface()
    {
        int posX = width-80;
        int posY = height-20;
        stroke(thirdColor);
        fill(thirdColor);
        rect(width-80-130, height-20-20, 110, 30);

        stroke(255);
        fill(255);
        text("OverSkecthing", posX-125, posY);

        stroke(thirdColor);
        fill(thirdColor);
        rect(width/2 + 60, height-40, 110, 30);

        stroke(255);
        fill(255);
        text("Clear", width/2 + 70, height-20);

        myState.drawInterface();

        if(debug){
          fill(255,0,0);
          stroke(255,0,0);
          text("Curve Length:"+context.curve.curveLength()+" px", 10, height-20);
          text("Curve Tightness:"+curveT, 10, 20);
          text("Tolerance:"+context.curve.tolerance, 10, 40);
        }

        pushMatrix();
        translate(20, height-50);
        image(img, 0, 0);
        popMatrix();
    }
}static class Utils{
  
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