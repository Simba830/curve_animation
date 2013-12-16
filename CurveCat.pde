//
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

  ArrayList<PVector> DouglasPeuckerReducing(ArrayList<PVector> cpoints, float epsilon){
    float maxDistance = 0, distance = 0;
    int index = 0;
    int end = cpoints.size();
    ArrayList<PVector> result;

    for (int i = 2; i < end - 1; ++i) {
      distance = shortestDistanceToSegment(cpoints.get(i), cpoints.get(1), cpoints.get(end - 1));
      if( distance > maxDistance){
        maxDistance = distance;
        index = i;
      }
    }

    if(maxDistance > epsilon){
      ArrayList<PVector> results1, results2;
      ArrayList<PVector> tmp = new ArrayList<PVector>();
      for (int i = index; i < end - 1; ++i) {
          tmp.add(cpoints.get(i));
      }
      results1 = DouglasPeuckerReducing(tmp, epsilon);

      tmp = new ArrayList<PVector>();
      for (int i = 1; i < index; ++i) {
          tmp.add(cpoints.get(i));
      }
      results2 = DouglasPeuckerReducing(tmp, epsilon);

      results1.addAll(results2);
      result = (ArrayList<PVector>) results1.clone();
    }else{
      result = cpoints;
    }

    return result;
  }

  float shortestDistanceToSegment(PVector cpoint, PVector segBegin, PVector segEnd){
    PVector tmp = (PVector) segEnd.get();
    tmp.sub(segBegin);

    int numberDivisions = 100;
    float dX = tmp.mag()/numberDivisions;

    float distance = 99999;

    for (int i = 0; i < numberDivisions; ++i) {
        tmp = segEnd.get();
        tmp.mult(i*dX);
        tmp = PVector.add(segBegin, tmp);
        if(tmp.dist(cpoint) < distance){
          distance = tmp.dist(cpoint);
        }
    }

    return distance;
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
     
      int size = controlPoints.size() - 1;
      
      Segment segAux;
      Segment segP;
      ArrayList<PVector> pAux;

      boolean wasDecimed = false;

      ArrayList<PVector> essentials = DouglasPeuckerReducing(controlPoints, 0.5);
      ArrayList<PVector> testableControlPoints = (ArrayList<PVector>) controlPoints.clone();

      for (int i = 0; i < essentials.size(); ++i) {
        testableControlPoints.remove(essentials.get(i));
      }

      for(int i = 1; i < testableControlPoints.size() - 1; i++){

         pAux = new ArrayList<PVector>(controlPoints.size());
         pAux = (ArrayList<PVector>) controlPoints.clone();

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
           this.controlPoints.remove(index);
           wasDecimed = true;
         }
         
      }

      this.decimable = wasDecimed;
  }

  void decimeAll(){
    long tBegin = System.currentTimeMillis();
    while(this.canBeDecimed()){
      this.decimeCurve(this.tolerance);
    }  
    long tEnd = System.currentTimeMillis();
    long time = tEnd - tBegin;
    println("time: "+ time + "ms");
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

