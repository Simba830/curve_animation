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

  Segment getSegment(ArrayList<Property> pAux, int i)
  { 
         //console.log(i);
         Property a = i >= 1 ? pAux.get(i-1) : pAux.get(0);
         Property b = pAux.get(i);
         //console.log(b);
         Property c = pAux.get(i+1);
         Property d = i+2 < pAux.size() ? pAux.get(i+2) : pAux.get(i+1);
         return new Segment(a,b,c,d);
  }

  Segment getSegment(int i)
  { 
         return getSegment(controlPoints,i);
  }

  // Método que retorna os principais controlPoints que são essenciais para a curva
  ArrayList<Property> DouglasPeuckerReducing(ArrayList<Property> pList, float epsilon){
    float maxDistance = 0, distance = 0;
    int index = 0;
    int end = pList.size();
    console.log(end);
    ArrayList<Property> result;

    for (int i = 2; i <= end - 1; ++i) {
      distance = shortestDistanceToSegment(pList.get(i), pList.get(0), pList.get(end - 1));
      if( distance > maxDistance){
        maxDistance = distance;
        index = i;
      }
    }
    if(maxDistance > epsilon){
      ArrayList<Property> results1, results2;

      // Fiz isso aqui porque não posso modificar o pList
      ArrayList<Property> tmp = new ArrayList<Property>();
      for (int i = 1; i <= index; ++i) {
          tmp.add(pList.get(i));
      }
      results1 = DouglasPeuckerReducing(tmp, epsilon);

      // Fiz isso aqui porque não posso modificar o pList
      tmp = new ArrayList<Property>();
      //console.log(tmp);
      for (int i = index; i <= end; ++i) {
          tmp.add(pList.get(i));
      }
      results2 = DouglasPeuckerReducing(tmp, epsilon);

      // Concatenando dois arrays, por que tinha que ser tão difícil ? Custava retornar o array novo ?
      results1.addAll(results2);
      result = (ArrayList<Property>) results1.clone();
    }else{
      //console.log(pList.toArray());
      result = pList;
    }

    return result;
  }

    // Método que retorna os principais controlPoints que são essenciais para a curva
  ArrayList<Property> DouglasPeuckerReducing(ArrayList<Property> pList, float epsilon){
    Property firstPoint = pList.get(0);
    Property lastPoint = pList.get(pList.size()-1);
    ArrayList<Property> result;
    
    if (pList.size() < 3)
        return pList;
    
    int index = -1;
    float maxDistance = 0, distance = 0;
    
    for (int i = 1; i <= pList.size() - 1; ++i) {
      distance = shortestDistanceToSegment(pList.get(i), firstPoint, lastPoint);
      if( distance > maxDistance){
        maxDistance = distance;
        index = i;
      }
    }
    if(maxDistance > epsilon){
      ArrayList<Property> results1, results2;

      // Fiz isso aqui porque não posso modificar o pList
      ArrayList<Property> tmp = new ArrayList<Property>();
      for (int i = 1; i <= index; ++i) {
          tmp.add(pList.get(i));
      }
      results1 = DouglasPeuckerReducing(tmp, epsilon);

      // Fiz isso aqui porque não posso modificar o pList
      tmp = new ArrayList<Property>();
      //console.log(tmp);
      for (int i = index; i <= end; ++i) {
          tmp.add(pList.get(i));
      }
      results2 = DouglasPeuckerReducing(tmp, epsilon);

      // Concatenando dois arrays, por que tinha que ser tão difícil ? Custava retornar o array novo ?
      results1.addAll(results2);
      result = (ArrayList<Property>) results1.clone();
    }else{
      //console.log(pList.toArray());
      result = pList;
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
      ArrayList<Property> essentials = DouglasPeuckerReducing(controlPoints,1);
      
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
      /*for (int i = essentials.size(); i >= 0; --i)
      {
        testableControlPoints.add(essentials.get(i));
      }*/

      // Percorre os testáveis removendo e verificando com a tolerância.
      for(int i = 0; i < testableControlPoints.size() - 1; i++){

         pAux = new ArrayList<Property>(controlPoints.size());

         pAux = (ArrayList<Property>) controlPoints.clone();

         // Pega o vetor e procura qual o indice dele nos controlPoints
         int index = controlPoints.indexOf( testableControlPoints.get(i) );
         pAux.remove(index);

         //console.log(index);
         segAux = getSegment(pAux,index-1);
         console.log(segAux);
         console.log(i);
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

