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
  private float controlPointAlpha = 200;

  // Interpolator
  private SmoothInterpolator interpolator;

  // Render
  private Renderer renderer;

  CurveCat() 
  {
    renderer = new TimeRenderer();
    wasEdited = false;
    controlPoints = new ArrayList<Property>();
    speeds = new ArrayList<float>();
    decimable = true;
    tolerance = 10;

    history = new ArrayList<ArrayList<Property>>();
    interpolator = new SmoothInterpolator();
  }

  void clear()
  {
    decimable = true;
    controlPoints = new ArrayList<Property>();
    saveCurve();
  }

  void removeElement(int index){
    saveCurve();
    if (controlPoints.size()>1)
      controlPoints.remove(index);
  }

  Segment getSegment(ArrayList<Property> pAux, int i)
  { 
         Property a = i >= 1 ? pAux.get(i-1) : pAux.get(0);
         Property b = pAux.get(i);
         Property c = pAux.get(i+1);
         Property d = i+2 < pAux.size() ? pAux.get(i+2) : pAux.get(i+1);
         return new Segment(a,b,c,d);
  }

  Segment getSegment(int i)
  { 
         return getSegment(controlPoints,i);
  }

  // Método que retorna os principais controlPoints que são essenciais para a curva
  ArrayList<Property> DouglasPeuckerReducingOld(ArrayList<Property> pList, float epsilon){
    float maxDistance = 0, distance = 0;
    int index = 0;
    int end = pList.size();
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
      for (int i = index; i <= end; ++i) {
          tmp.add(pList.get(i));
      }
      results2 = DouglasPeuckerReducing(tmp, epsilon);

      // Concatenando dois arrays, por que tinha que ser tão difícil ? Custava retornar o array novo ?
      results1.addAll(results2);
      result = (ArrayList<Property>) results1.clone();
    }else{
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
      distance = findPerpendicularDistance(pList.get(i), firstPoint, lastPoint);
      if( distance > maxDistance){
        maxDistance = distance;
        index = i;
      }
    }
    if(maxDistance > epsilon){
      ArrayList<Property> results1, results2;

      // Fiz isso aqui porque não posso modificar o pList
      ArrayList<Property> tmp = new ArrayList<Property>();
      for (int i = 1; i <= index+1; ++i) {
          tmp.add(pList.get(i));
      }
      results1 = DouglasPeuckerReducing(tmp, epsilon);

      // Fiz isso aqui porque não posso modificar o pList
      tmp = new ArrayList<Property>();
      for (int i = index; i <= pList.size() -1 ; ++i) {
          tmp.add(pList.get(i));
      }
      results2 = DouglasPeuckerReducing(tmp, epsilon);

      // Concatenando dois arrays, por que tinha que ser tão difícil ? Custava retornar o array novo ?
      results1.addAll(results2);
      result = (ArrayList<Property>) results1.clone();
    }else{
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

  void updateRender(){
    this.renderer.update(this.controlPoints);
  }

  float findPerpendicularDistance(p, p1,p2) {
    // if start and end point are on the same x the distance is the difference in X.
    float result;
    float slope;
    float intercept;
    if (p1.get(0) == p2.get(0)){
        result=abs(p.get(0)-p1.get(0));
    }else{
        slope = (p2.get(1) - p1.get(1)) / (p2.get(0) - p1.get(0));
        intercept = p1.get(1) - (slope * p1.get(0));
        result = abs(slope * p.get(0) - p.get(1) + intercept) / sqrt(pow(slope, 2) + 1);
    }
    return result;
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
      ArrayList<Property> essentials = DouglasPeuckerReducing(controlPoints,5);
      // Pega o tempo final
      int t1Douglas = millis();

      int totalTimeDouglas = t1Douglas - t0;
      // Exibe o tempo total gasto em Douglas Peucker

      // Array que vai conter os vetores a serem testados
      ArrayList<Property> testableControlPoints = (ArrayList<Property>) controlPoints.clone();

      t0 = millis();
      // Removendo os pontos essenciais dos testáveis
      // for (int i = 0; i < essentials.size(); ++i) {
      //   testableControlPoints.remove(essentials.get(i));
      // }
      
      // Adiciona os essenciais no final da lista de testáveis em ordem de prioridade do menos importante pro mais importante.
      /*for (int i = essentials.size(); i >= 0; --i)
      {
        testableControlPoints.add(essentials.get(i));
      }*/

      // Percorre os testáveis removendo e verificando com a tolerância.
      for(int i = 1; i < testableControlPoints.size() - 1; i++){

         pAux = new ArrayList<Property>(controlPoints.size());

         pAux = (ArrayList<Property>) controlPoints.clone();

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
           controlPoints.remove(index);
           wasDecimed = true;
         }
         
      }

      // Calculating the time of processing of the decime
      int totalTimeDecime = millis() - t0;
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

    console.log("Was decimed");

    renderer.update(this.controlPoints);
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
    this.decimeAll();
    console.log("Inserting point");
  }

  void insertPoint(Property q){
    controlPoints.add(q);
    this.decimable = true;
    this.decimeAll();
    console.log("Inserting point");
    // renderer.addPoint(controlPoints);
    saveCurve();
  }

  // Altera o valor do elemento index da lista p para q
  void setPoint(PVector q, int index)
  {
    try {
      controlPoints.set(index,q); 
    } catch (Exception e) {
        console.error("e.toString(): "+e.toString());
        console.error("Erro ao setar ponto de controle");
    }
    saveCurve();
  }

  // Retorna as coordenadas (X,Y) para de uma lista de PVectors p dado o index.
  Property getControlPoint(int index)
  {
    if (controlPoints.size() > index && index >-1)
      return controlPoints.get(index);
    else
      return new Property(0,0);
  }

  Property getPropertyByLocationAndTime(float x, float y, float t){
    return getControlPoint(findControlPoint(x,y));
  }
  
  // Retorna o indice do ponto de controle mais próximo de q. Caso
  // este não esteja a uma distancia minima especificada por minDistance,
  // retorna -1
  int findControlPoint(PVector q)
  {
    PVector p = new Property(q.x, q.y);
    int op=-1;
    float bestDist = 100000;
    for (int i = 0; i < getNumberControlPoints(); i++) 
    {
      float d = controlPoints.get(i).dist(p);
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
        float distance = dist(x, y, q.x, q.y);

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

  ArrayList<Property> getControlPointsClone(){
    return controlPoints.clone();
  }

  ArrayList<Property> getControlPoints(){
    return controlPoints;
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

    // this.decimeAll();
    renderer.update(this.controlPoints);
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
  void draw()
  { 
    renderer.render();
  }

  Renderer getRenderer(){
    return this.renderer;
  }

  // Desenha elipses de acordo com os elementos do tipo PVector da lista p
  void drawControlPoints()
  {
    if ( !(getNumberControlPoints()<4) ){
      fill(secondaryColor, controlPointAlpha);
      stroke(secondaryColor, controlPointAlpha);
      for (int i = 0; i < getNumberControlPoints(); i++) 
      {
        pushMatrix();
        translate(controlPoints.get(i).get(0), controlPoints.get(i).get(1), 10);
        
        sphere(5);
        ellipse(0, 0, 5, 5);
        text("t: "+controlPoints.get(i).get(2), 10, -10, 0);
        popMatrix();
      } 
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

  void refreshInterpolator(){
      Property p;
      for (int i = 0; i < controlPoints.size(); ++i) {
        p = controlPoints.get(i);
        this.interpolator.set(p.getT(), p);
      }
  }

  ArrayList<Property> reAmostragemPorTempo(float timeSpacing){
    ArrayList<Property> aux = new ArrayList<Property>();
    this.refreshInterpolator();
    for (int i = 0; i < interpolator.lastTime(); ++i) {
      if(i % timeSpacing == 0){
        aux.add(interpolator.get(i));
      }
    }

    aux.add(interpolator.get(interpolator.lastTime));

    return aux;
  }

  Property getPropertyByDif(int index, float dx){
    if( dx == 0 )
      return;

    float correction = 0;
    boolean found = false;
    int indexDiference = 0;

    // Se é negativa
    if(dx < 0){
      indexDiference = 1; 
      while(!found){

        if(index - indexDiference <= 0 )
          return getControlPoint(0);

        Property current = getControlPoint(index - indexDiference);
        Segment seg = getSegment(index - indexDiference);
        float curveLength = 0, totalCurveLength = 0;

        // Calcula o curveLength total do segmento
        for (int j=0; j<=numberDivisions; j++) 
        {
            float t = (float)(j) / (float)(numberDivisions);
            float x = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
            float y = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
            t = (float)(j+1) / (float)(numberDivisions);
            float x2 = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
            float y2 = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
            float distance = dist(x, y, x2, y2);
            totalCurveLength += distance;
        }

        // Calcula o curveLength até que o total menos ele seja igual ao dx
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
            if(!(curveLength >= totalCurveLength)){
              if(totalCurveLength - curveLength <= abs(dx)){
                return new Property(x2, y2, current.getT() + t);
              }
            }
        }

        dx += totalCurveLength;
        indexDiference++;
      }

    }else{
      indexDiference = 0;
      while(!found){

        if(index + indexDiference >= controlPoints.size()){
          return getControlPoint(controlPoints.size() - 1);
        }

        Property current = getControlPoint(index + indexDiference);
        Segment seg = getSegment(index + indexDiference);
        float curveLength = 0;
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
            if(curveLength >= dx){
              return new Property(x2, y2, current.getT() + t);
            }
          }
        dx -= curveLength;
        indexDiference++;
      }
    }
  }

}

