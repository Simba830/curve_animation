//
// Classe que representa uma curva Catmull-Rom
//
class CurveCat
{
  // Control points
  PVector[] controlPoints;

  // If it can be decimed
  boolean decimable;

  // Number of points that the curve can be show
  int numberDivisions = 2000; 

  // Min Ditance wich can be in the curve
  float minDistance = 5;

  CurveCat() 
  {
    controlPoints = new PVector [0];
    decimable = true;
  }

  void clear()
  {
    decimable = true;
    controlPoints = new PVector[0];
  }

  // Remove o elemento que está no index de uma lista pTmp
  PVector[] removeElementFromArray(PVector[] pTmp, int index)
  { 
    //assert(index != -1);
    for (int i=0; i < pTmp.length-1; i++)
      if (i >= index)
        pTmp[i] = pTmp[i+1];
    pTmp = (PVector[])shorten(pTmp);
    return pTmp;
  }

  void removeElement(int index){
    for (int i=0; i < controlPoints.length-1; i++){
      if (i >= index)
        controlPoints[i] = controlPoints[i+1];
    }
    controlPoints = (PVector[])shorten(controlPoints);
  }

  Segment getSegment(PVector[] pAux, int i)
  { 
         //printArray(pAux);
         PVector a = i >= 1 ? pAux[i-1] : pAux[0];
         PVector b = pAux[i];
         PVector c = pAux[i+1];
         PVector d = i+2 < pAux.length ? pAux[i+2] : pAux[i+1];
         return new Segment(a,b,c,d);
  }

  Segment getSegment(int i)
  { 
         //printArray(pAux);
         PVector a = i >= 1 ? controlPoints[i-1] : controlPoints[0];
         PVector b = controlPoints[i];
         PVector c = controlPoints[i+1];
         PVector d = i+2 < controlPoints.length ? controlPoints[i+2] : controlPoints[i+1];
         return new Segment(a,b,c,d);
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
     
      int size = controlPoints.length -1;
      
      Segment segAux;
      Segment segP;
      PVector[] pAux;

      boolean wasDecimed = false;

      for(int i = 1; i < size; i++){
         pAux = new PVector[controlPoints.length];
         arraycopy(controlPoints, pAux );
         pAux = removeElementFromArray(pAux, i);
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

  boolean canBeDecimed(){
    return this.decimable;
  }

  int getNumberControlPoints () { 
    if (controlPoints != null) { 
      return controlPoints.length;
    } 
    else { 
      return 0;
    }
  } 

  // Insere o ponto q entre index-1 e index
  void insertPoint(PVector q, int index){
    controlPoints = (PVector[]) append(controlPoints, q);
    for (int i = controlPoints.length-1; i > index; i--) {
      controlPoints[i] = controlPoints[i-1];
    }
    controlPoints [index] = q;
    this.decimable = true;
  }

  // Altera o valor do elemento index da lista p para q
  void setPoint(PVector q, int index)
  {
    controlPoints[index].set(q);
  }

  // Retorna as coordenadas (X,Y) para de uma lista de PVectors p dado o index.
  PVector getControlPoint(int index)
  {
    return controlPoints[index];
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
      float d = controlPoints[i].dist(q);
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
  int findClosestPoint (PVector[] cps, PVector q, PVector r) {

    int bestSegment = -1;
    float bestDistance = 10000000;
    float bestSegmentDistance = 100000;
    
    for (int i = 0; i < cps.length-1; i++) {
      PVector a = i >= 1 ? cps[i-1] : cps[0];
      PVector b = cps[i];
      PVector c = cps[i+1];
      PVector d = i+2 < cps.length ? cps[i+2] : cps[i+1];

      PVector result = new PVector();
      for (int j=0; j<=numberDivisions/2; j++) 
      {
        float t = (float)(j) / (float)(numberDivisions);
        float x = curvePoint(a.x, b.x, c.x, d.x, t);
        float y = curvePoint(a.y, b.y, c.y, d.y, t);
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
    for (int i = 0; i<controlPoints.length; i++){
      PVector controlPoint = controlPoints[i];

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
      PVector a = i >= 1 ? controlPoints[i-1] : controlPoints[0];
      PVector b = controlPoints[i];
      PVector c = controlPoints[i+1];
      PVector d = i+2 < getNumberControlPoints() ? controlPoints[i+2] : controlPoints[i+1];

      for (int j=0; j<=numberDivisions; j++) 
      {
        float t = (float)(j) / (float)(numberDivisions);
        float x = curvePoint(a.x, b.x, c.x, d.x, t);
        float y = curvePoint(a.y, b.y, c.y, d.y, t);
        t = (float)(j+1) / (float)(numberDivisions);
        float x2 = curvePoint(a.x, b.x, c.x, d.x, t);
        float y2 = curvePoint(a.y, b.y, c.y, d.y, t);
        float dist = dist (x, y, x2, y2);
        curveLength += dist;
      }
    }
    return (float)curveLength;
  }



  /**
   MÉTODOS DE DESENHAR
   **/
  // Desenha uma curva de acordo com a lista p de pontos de controle.
  void draw()
  { 
    stroke(0);
    strokeWeight(1.5);
    strokeCap(ROUND);
    for (int i = 0; i < getNumberControlPoints() - 1; i++) {
      PVector a = i >= 1 ? controlPoints[i-1] : controlPoints[0];
      PVector b = controlPoints[i];
      PVector c = controlPoints[i+1];
      PVector d = i+2 < getNumberControlPoints() ? controlPoints[i+2] : controlPoints[i+1];
      curve (a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y);
    }
    stroke(0);
  }

  // Desenha elipses de acordo com os elementos do tipo PVector da lista p
  void drawControlPoints()
  {
    fill(secondaryColor);
    stroke(secondaryColor);
    for (int i = 0; i < getNumberControlPoints(); i++) 
    {
      ellipse (controlPoints[i].x, controlPoints[i].y, 7, 7);
    }
    fill(255);
  }
  void drawControlPoint(int index)
  {
    fill(mainColor);
    stroke(mainColor);
    ellipse(controlPoints[index].x, controlPoints[index].y, 10, 10);
  }

  CurveCat clone(){
    CurveCat aux = new CurveCat();
    aux.controlPoints = new PVector[controlPoints.length];
    arrayCopy(controlPoints, aux.controlPoints);
    return aux;
  }
}

