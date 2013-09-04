/**
 * Returns the closest point on a catmull-rom curve relative to a search location.
 * This is only an approximation, by subdividing the curve a given number of times.
 * More subdivisions gives a better approximation but takes longer, and vice versa.
 * No concern is given to handling multiple equidistant points on the curve - the
 *   first encountered equidistant point on the subdivided curve is returned.
 *
 * @param a,b,c,d  Four control points of the curve
 * @param q        the search-from location
 * @param ndivs  how many segments to subdivide the curve into
 * @returns      PVector containing closest subdivided point on curve
 */
PVector findClosestPoint(PVector q, PVector a, PVector b, PVector c, PVector d, int ndivs) {
  PVector result = new PVector();
  float bestDistance = 100000;
  float bestT = 0;
  for (int i=0; i<=ndivs; i++) 
  {
    float t = (float)(i) / (float)(ndivs);
    float x = curvePoint(a.x, b.x, c.x, d.x, t);
    float y = curvePoint(a.y, b.y, c.y, d.y, t);
    float dist = dist (x, y, q.x, q.y);
    if (i == 0 || dist < bestDistance) {
      bestDistance = dist;
      bestT = t;
      result.set(x,y,0);
    }
  }
  return result;
}


//
// Classe que representa uma curva Catmull-Rom
//
class CurveCat
{
  // Cria os pontos de controle da curva.
  PVector[] p = new PVector [0];
  

  // Retorna o numero de pontos de controle
  int ncps () { 
    if (p != null) { return p.length; } else { return 0; }
  } 
  // Numero de pontos com que cada segmento da curva será plotado
  int ndivs = 100; 
  
  // Distancia minima para considerar que um ponto está sobre a curva
  float distMin = 5;
  
  // Método construtor da classe
  CurveCat()
  {    
  }

  /*
    MÉTODOS PARA EDIÇÃO DA CURVA
  */
  void clear()
  {
        p = new PVector[0];
  }
  
  // Insere o ponto q entre index-1 e index
  void insertPoint (PVector q, int index) {
    p = (PVector[]) append(p,q);
    for (int i = p.length-1; i > index; i--) {
      p[i] = p[i-1];
    }
    p [index] = q;
  }
  
  // Altera o valor do elemento index da lista p para q
  void setPoint(PVector q, int index)
  {
    p[index].set(q);
  }
  
  // Retorna o indice do ponto de controle mais próximo de q. Caso
  // este não esteja a uma distancia minima especificada por distMin,
  // retorna -1
  int findControlPoint(PVector q)
  {
    int op=-1;
    float bestDist = 100000;
    for (int i = 0; i < ncps(); i++) 
    {
        float d = p[i].dist(q);
        if (d < distMin && d < bestDist) 
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
  int findClosestPoint (PVector q, PVector r) {
    
    int bestSegment = -1;
    float bestDistance = 10000000;
    
    for (int i = 0; i < ncps()-1; i++) {
      PVector a = i >= 1 ? p[i-1] : p[0];
      PVector b = p[i];
      PVector c = p[i+1];
      PVector d = i+2 < ncps() ? p[i+2] : p[i+1];
      float bestSegmentDistance = 100000;
      float bestT = 0;
      PVector result = new PVector();
      for (int j=0; j<=ndivs; j++) 
      {
        float t = (float)(j) / (float)(ndivs);
        float x = curvePoint(a.x, b.x, c.x, d.x, t);
        float y = curvePoint(a.y, b.y, c.y, d.y, t);
        float dist = dist (x, y, q.x, q.y);
        if (j == 0 || dist < bestSegmentDistance) {
          bestSegmentDistance = dist;
          bestT = t;
          result.set(x,y,0);
        }
      }
      if (bestSegmentDistance < bestDistance) {
        r.set (result.x, result.y, 0);
        bestSegment = i+1;
        bestDistance = bestSegmentDistance;
      }
    }
    return bestSegment;
    
  }
  /** FIM DOS MÉTODOS DE EDIÇÃO E CRIAÇÃO **/
  
  /** MÉTODOS PARA PARAMETRIZAÇÃO DE UMA CURVA **/
  
  // Retorna o tamanho de uma curva dados uma lista de pontos de controle
  float curveLength()
  {
    float curveLength = 0;
    for (int i = 0; i < ncps()-1; i++) {
      PVector a = i >= 1 ? p[i-1] : p[0];
      PVector b = p[i];
      PVector c = p[i+1];
      PVector d = i+2 < ncps() ? p[i+2] : p[i+1];
      
      for (int j=0; j<=ndivs; j++) 
      {
        float t = (float)(j) / (float)(ndivs);
        float x = curvePoint(a.x, b.x, c.x, d.x, t);
        float y = curvePoint(a.y, b.y, c.y, d.y, t);
        t = (float)(j+1) / (float)(ndivs);
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
  void drawGeometry()
  { 
    assert (p.length >= 2);
    stroke(255);
    for (int i = 0; i < ncps() - 1; i++) {
      PVector a = i >= 1 ? p[i-1] : p[0];
      PVector b = p[i];
      PVector c = p[i+1];
      PVector d = i+2 < ncps() ? p[i+2] : p[i+1];
      curve (a.x, a.y, b.x, b.y, c.x, c.y, d.x, d.y);
    }
    stroke(0);
        
  }
  
  // Desenha elipses de acordo com os elementos do tipo PVector da lista p
  void drawControlPoints()
  {
    fill(255, 0, 0);
    for (int i = 0; i < ncps(); i++) 
    {
      ellipse (p[i].x, p[i].y, 7, 7);
    }
    fill(255);
  }
}

