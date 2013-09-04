/**
 AnimationApp.pde
 Author: Guilherme Herzog
 Created on: May 13
 
 **/

int state;// 1 - DRAW; 2- EDITING; 3- LENGTH
int segSel; // Corresponde a um Segmento de curva selecionado

PFont font; // it's a font

// Curve
CurveCat curve;
PVector closestPoint = new PVector();


public void setup() 
{
  size(800, 600);
  smooth();
  state = 1; // First state
  segSel = -1; 
  font = createFont("", 14);
  curve = new CurveCat();
}

// Key Press callback
public void keyPressed() 
{ 
  if (key=='1')
  {
    state = 1; // DRAW
  } 
  if (key=='2')
  {
    state = 2; // EDIT
  }
  if (key=='3')
    state = 3; // LENGTH
  if (key== DELETE)
  {
    if (state == 1)
    {
      curve.clear(); 
      state = 1; // Set state Draw
      segSel = -1; // Reset segment selected
    }
    else if (state == 2 && segSel != -1)
    {
      curve.p = curve.removeElement(curve.p, segSel);
      segSel--;
    }
  }
  if (key=='4')
  {
    curve.decimeCurve(10);
    segSel=-1;
  }
}
// Mouse press callback
void mousePressed() 
{
  if (state == 1)
  { 
    // Insert a new Control Point on Curve
    curve.insertPoint(new PVector(mouseX, mouseY), curve.ncps());
  }
  if (state == 2)
  {
    segSel = curve.findControlPoint(new PVector(mouseX, mouseY));
    fill(255, 0, 0);
    ellipse(mouseX, mouseY, 7, 7);
  }
}

// Mouse drag callback
void mouseDragged () 
{
  if (state == 1 && mouseButton == LEFT)
    curve.insertPoint(new PVector(mouseX, mouseY), curve.ncps());
  if (state == 2)
  {
    if (mouseButton == RIGHT) 
    {
      float t = map(mouseX, 0, width, -5, 5);
      curveTightness(t);
    }
    else if (mouseButton == LEFT)
    {
      if (segSel != -1)
      {
        curve.setPoint(new PVector(mouseX, mouseY), segSel);
      } 
      else
      {
        closestPoint = new PVector();
        PVector q = new PVector(mouseX, mouseY);
        segSel = curve.findClosestPoint (curve.p, q, closestPoint);
        float distance = q.dist(closestPoint);
        if (distance < 5)
        {
          curve.insertPoint(q, segSel);
        }
      }
    }
  }
}

void draw() 
{
  background (0);
  drawInterface();
  noFill();
  ellipse(closestPoint.x, closestPoint.y, 7, 7);

  if (curve.ncps() >=4) { 
    curve.drawGeometry();
  }
  if (state == 2 || curve.ncps() < 4) { 
    curve.drawControlPoints();
  }
  if (segSel != -1) { 
    curve.drawControlPoint(segSel);
  }

  fill(255, 0, 0);
}
void drawInterface() 
{
         
  fill(96);
  textFont(font);
  int textx = 5, texty = height-100;
  if (curve.ncps() < 4)
    text("Click 4 times to define control points", textx, texty+=15);
  text("Key '1' set state to CREATING", textx, texty+=15);
  text("Key '2' set state to EDITING", textx, texty+=15);
  text("Key 'DEL' create a new Curve", textx, texty+=15);
  drawStateLabel(width-80, height-20);
}
void drawStateLabel(int posX, int posY)
{
  if (state == 1)
  {
    fill(200,100,0);
    rect(posX-10,posY-20,80,30);
    fill(255);
    text("Creating", posX, posY);
  }
  if (state == 2)
  {
    fill(0,100,200);
    rect(posX-10,posY-20,80,30);
    fill(255);
    text("Editing", posX, posY);
  }
  if (state == 3)
  {
    fill(255);
    text("Curve Length:"+curve.curveLength()+" px", 10, height-20);
  }
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
    if (p != null) { 
      return p.length;
    } 
    else { 
      return 0;
    }
  } 
  // Numero de pontos com que cada segmento da curva será plotado
  int ndivs = 100; 

  // Distancia minima para considerar que um ponto está sobre a curva
  float distMin = 5;

  // Método construtor da classe
  CurveCat() {
  }

  /*
    MÉTODOS PARA EDIÇÃO DA CURVA
   */
  void clear()
  {
    p = new PVector[0];
  }
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
  PVector findClosestSegmentPoint(PVector q, PVector a, PVector b, PVector c, PVector d, int ndivs) {
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
        result.set(x, y, 0);
      }
    }
    return result;
  }

  // Remove o elemento que está no index de uma lista pTmp
  PVector[] removeElement(PVector[] pTmp, int index)
  { 
    //assert(index != -1);
    for (int i=0; i < pTmp.length-1; i++)
      if (i >= index)
        pTmp[i] = pTmp[i+1];
    pTmp = (PVector[])shorten(pTmp);
    return pTmp;
  }

  // Insere o ponto q entre index-1 e index
  void insertPoint (PVector q, int index) {
    p = (PVector[]) append(p, q);
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
  // Remove pontos de controle de uma curva criada pela lista p que possuam distancia menor que a tolerancia em relação aos pontos da nova curva.
  void decimeCurve(float tolerance)
  {
     PVector[] pTmp = new PVector[0];
     int[] toRemove = new int[0];
     arraycopy(p,pTmp);
     for (int i = 1; i<p.length-1;i++)
     {
       PVector a = p[i-1];
       PVector b = p[i+1];
       PVector c = p[i+2];
       PVector d = p[i+3];
       PVector[] pAux = { a, b, c, d};
       
     }
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

  // Retorna as coordenadas (X,Y) para de uma lista de PVectors p dado o index.
  PVector getControlPoint(PVector[] p, int index)
  {
    return p[index];
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

    for (int i = 0; i < cps.length-1; i++) {
      PVector a = i >= 1 ? cps[i-1] : cps[0];
      PVector b = cps[i];
      PVector c = cps[i+1];
      PVector d = i+2 < cps.length ? cps[i+2] : cps[i+1];
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
          result.set(x, y, 0);
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
  void drawControlPoint(int index)
  {
    fill(0, 100, 200);
    stroke(255);
    ellipse(p[index].x, p[index].y, 10, 10);
  }
  void printArray(PVector[] p)
  {
    for (int i=0;i<p.length-1;i++)
      println(i+" "+p[i]);
  }
}


