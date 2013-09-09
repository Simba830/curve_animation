import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.event.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class curveAnimation extends PApplet {

/**
 AnimationApp.pde
 Author: Guilherme Herzog
 Created on: May 13
 
 **/

 

// States 
final int DRAWING = 1;
final int EDITING = 2;

boolean debug = false;

// Variaveis de Curvas
int state;
int selectedSegment; // Selected Segment of curve
int[] selectedSegments;
PVector closestPoint;
float tolerance;
boolean canSketch;

PFont font; // it's a font
float curveT = 0;

// Curve
CurveCat curve;
CurveCat decimedCurve;

// Selection Box
PVector mouseInit;
PVector mouseFinal;

// Colours
int mainColor = 0xff0066C8;
int secondaryColor = 0xffFF9700;
int thirdColor = 0xff3990E3;

public void setup() 
{
  size(800, 600);
  smooth();
  state = DRAWING; // First state

  // Empty array of selectedSegments 
  selectedSegments = new int[0];
  font = createFont("", 14);
  curve = new CurveCat();
  canSketch = true;
  closestPoint = new PVector();
  tolerance = 7;

  // PVectors used to create the selection box
  mouseInit = new PVector(0,0);
  mouseFinal = new PVector(0,0);

  // Add a listener to the mouseWheel
  /*addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }});*/ 

  curveTightness(curveT);
}

// TODO Pensar em como portar isso para o Javascript
public void mouseWheel(float delta) {
  curveT += delta/10;
  curveT = constrain(curveT, -1.0f, 1.0f);

  curveTightness(curveT); 
}

// TODO Mudar isso para um interface s\u00f3 usando o mouse
public void keyPressed() 
{ 
  switch (key){
    case '1' :
      state = DRAWING;
      selectedSegments = new int[0];
    break;  

    case '2' :
        state = EDITING;
    break;  

    case 'd' :
      debug = !debug;
    break;  

    case DELETE :
      if (state == DRAWING)
      {
        curve.clear(); 
        state = DRAWING; // Set state Draw
        selectedSegments = new int[0];
      }
      else if (state == EDITING && selectedSegments.length != 0)
      {
        for (int i = selectedSegments.length - 1; i>=0; i--){
              curve.removeElement(selectedSegments[i]);
        }

        selectedSegments = new int[0];
      }
    break;
  }
}

// Mouse press callback
public void mousePressed() 
{
  mouseInit.set(mouseX, mouseY);
  mouseFinal.set(mouseX, mouseY);
  selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));
  
  if(Utils.mouseOverRect(new PVector(mouseX, mouseY), width-80-130, height-20-20, 110,30)){
    
    return;
  }
  // Verifica se o local clicado \u00e9 proximo do final da curva;
  if (selectedSegment == curve.getNumberControlPoints()-1)
  {
     canSketch = true;
  } else if (selectedSegment == -1)
  {
      state = EDITING;    
  }
  if (state == DRAWING)
  { 
    if (canSketch)
        curve.insertPoint(new PVector(mouseX, mouseY), curve.getNumberControlPoints());
  }
  if (state == EDITING)
  {
      if(mouseButton == RIGHT){

            // Verfica se tem nenhum element selecionado
            if(selectedSegments.length == 0){

              // Ent\u00e3o seleciona o mais pr\u00f3ximo
              selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));

              closestPoint = new PVector();
              PVector q = new PVector(mouseX, mouseY);
              selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
              float distance = q.dist(closestPoint);

              selectedSegments = new int[1];
              selectedSegments[0] = selectedSegment;
            }

            // Remove todos os segmentos selecionados
            for (int i = selectedSegments.length - 1; i>=0; i--){
              curve.removeElement(selectedSegments[i]);
            }

            // Remove a sele\u00e7\u00e3o
            selectedSegments = new int[0];
      }else{

        // Seleciona o segmento em quest\u00e3o se for o mouse LEFT
        selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));

        closestPoint = new PVector();
        PVector q = new PVector(mouseX, mouseY);
        selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
        float distance = q.dist(closestPoint);

        boolean selected = false;
        // Se o segmento mais pr\u00f3ximo j\u00e1 estiver selecionado sa\u00ed da fun\u00e7\u00e3o

        if(distance > 20){
              selectedSegments = new int[0];
        }else{
          for (int i = 0; i<selectedSegments.length; i++){
            if(selectedSegment == selectedSegments[i]){
              selected = true;
              selectedSegment = i;
            }
          }
        }

        if(!selected){
          selectedSegments = new int[1];
          selectedSegments[0] = selectedSegment;
          selectedSegment = 0;
        }

        if (mouseEvent.getClickCount()==2){
          curve.insertPoint(q, selectedSegments[selectedSegment] + 1);

          selectedSegments[selectedSegment]++;

          mouseInit.set(0, 0);
          mouseFinal.set(0, 0);
        }else if(distance > 20){
          selectedSegments = new int[0];
        } 
      }
  }
}
    
public void mouseReleased()
{
  while(curve.canBeDecimed()){
    curve.decimeCurve(tolerance);
  }

  if(state == EDITING && selectedSegments.length == 0){
    selectedSegments = curve.getControlPointsBetween(mouseInit, mouseFinal);
  }

  // Retorna o estado de poder desenhar para FALSE
  canSketch = false;

  mouseInit.set(0,0);
  mouseFinal.set(0,0);
}

// Mouse drag callback
public void mouseDragged () 
{
  mouseFinal.set(mouseX, mouseY);
  if (state == DRAWING && mouseButton == LEFT)
  {
    if (canSketch)
        curve.insertPoint(new PVector(mouseX, mouseY), curve.getNumberControlPoints());
  }
  if (state == EDITING) // Editing
  {
    if (mouseButton == LEFT)
    {

      if (selectedSegments.length != 0)
      {
        // Pega a varia\u00e7\u00e3o de x e de y
        float dx = mouseX - pmouseX;
        float dy = mouseY - pmouseY;

        // Soma aos elementos selecionados
        for (int i = 0; i<selectedSegments.length; i++){
          PVector controlPoint = curve.getControlPoint(selectedSegments[i]);
          curve.setPoint(new PVector(controlPoint.x + dx, controlPoint.y + dy), selectedSegments[i]);
        }
      }
    }
  }
}


public void draw() 
{
  background (255);
  noFill();

  if (curve.getNumberControlPoints() >=4) { 
    curve.draw();
  }
  if (state == EDITING || curve.getNumberControlPoints() < 4) { 
    curve.drawControlPoints();
  }

  if(selectedSegments.length > 0){
    for (int i = 0; i<selectedSegments.length; i++){
      curve.drawControlPoint(selectedSegments[i]);
    }
  }

  drawInterface();
  if(state == EDITING && selectedSegments.length == 0){

    // Desenha caixa de sele\u00e7\u00e3o com Alpha 50
    fill(mainColor, 50);
    stroke(mainColor, 50);
    rect(mouseInit.x, mouseInit.y, mouseFinal.x - mouseInit.x, mouseFinal.y - mouseInit.y);
  }
}

public void drawInterface() 
{
         
  fill(96);
  textFont(font);
  int textx = 5, texty = height-100;
  if (curve.getNumberControlPoints() < 4)
    text("Click 4 times to define control points", textx, texty+=15);
  text("Key '1' set state to CREATING", textx, texty+=15);
  text("Key '2' set state to EDITING", textx, texty+=15);
  text("Key 'DEL' create a new Curve", textx, texty+=15);
  
  int posX = width-80;
  int posY = height-20;
  switch (state){
    case DRAWING :
      fill(mainColor);
      stroke(mainColor);
      rect(posX-10,posY-20,80,30);
      fill(255);
      text("Creating", posX, posY);
    break;  
    case EDITING :
      fill(secondaryColor);
      stroke(secondaryColor);
      rect(posX-10,posY-20,80,30);
      fill(255);
      text("Editing", posX, posY);

      stroke(thirdColor);
      fill(thirdColor);
      rect(posX-130, posY-20, 110, 30);

      stroke(255);
      fill(255);
      text("OverSkecthing", posX-125, posY);
    break;
  }

  // If debug is actived
  if(debug){
      fill(255,0,0);
      stroke(255,0,0);
      text("Curve Length:"+curve.curveLength()+" px", 10, height-20);
      text("Curve Tightness:"+curveT, 10, 20);
      text("Tolerance:"+tolerance, 10, 40);
  }
}


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

  public void clear()
  {
    decimable = true;
    controlPoints = new PVector[0];
  }

  // Remove o elemento que est\u00e1 no index de uma lista pTmp
  public PVector[] removeElementFromArray(PVector[] pTmp, int index)
  { 
    //assert(index != -1);
    for (int i=0; i < pTmp.length-1; i++)
      if (i >= index)
        pTmp[i] = pTmp[i+1];
    pTmp = (PVector[])shorten(pTmp);
    return pTmp;
  }

  public void removeElement(int index){
    for (int i=0; i < controlPoints.length-1; i++){
      if (i >= index)
        controlPoints[i] = controlPoints[i+1];
    }
    controlPoints = (PVector[])shorten(controlPoints);
  }

  public Segment getSegment(PVector[] pAux, int i)
  { 
         //printArray(pAux);
         PVector a = i >= 1 ? pAux[i-1] : pAux[0];
         PVector b = pAux[i];
         PVector c = pAux[i+1];
         PVector d = i+2 < pAux.length ? pAux[i+2] : pAux[i+1];
         return new Segment(a,b,c,d);
  }

  public Segment getSegment(int i)
  { 
         //printArray(pAux);
         PVector a = i >= 1 ? controlPoints[i-1] : controlPoints[0];
         PVector b = controlPoints[i];
         PVector c = controlPoints[i+1];
         PVector d = i+2 < controlPoints.length ? controlPoints[i+2] : controlPoints[i+1];
         return new Segment(a,b,c,d);
  }
  // Remove pontos de controle de uma curva criada pela lista p que possuam distancia menor que a tolerancia em rela\u00e7\u00e3o aos pontos da nova curva.
  public void decimeCurve(float tolerance)
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
         Utils.pvectorArrayCopy(controlPoints, pAux );
         pAux = removeElementFromArray(pAux, i);
         segAux = getSegment(pAux,i-1);
         remove = true;
         
         for (int j=0; j<=numberDivisions; j++) 
         {
            float t = (float)(j) / (float)(numberDivisions);
            float tAux;
            if (t < 0.5f)
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

  public boolean canBeDecimed(){
    return this.decimable;
  }

  public int getNumberControlPoints () { 
    if (controlPoints != null) { 
      return controlPoints.length;
    } 
    else { 
      return 0;
    }
  } 

  // Insere o ponto q entre index-1 e index
  public void insertPoint(PVector q, int index){
    controlPoints = (PVector[]) append(controlPoints, q);
    for (int i = controlPoints.length-1; i > index; i--) {
      controlPoints[i] = controlPoints[i-1];
    }
    controlPoints [index] = q;
    this.decimable = true;
  }

  // Altera o valor do elemento index da lista p para q
  public void setPoint(PVector q, int index)
  {
    controlPoints[index].set(q);
  }

  // Retorna as coordenadas (X,Y) para de uma lista de PVectors p dado o index.
  public PVector getControlPoint(int index)
  {
    return controlPoints[index];
  }
  
  // Retorna o indice do ponto de controle mais pr\u00f3ximo de q. Caso
  // este n\u00e3o esteja a uma distancia minima especificada por minDistance,
  // retorna -1
  public int findControlPoint(PVector q)
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
  public int findControlPoint (float x, float y) {
    return findControlPoint (new PVector (x, y));
  }

  // Outra interface para findControlPoint, passando as coordenadas do mouse
  public int findControlPoint () {
    return findControlPoint (mouseX, mouseY);
  }

  //
  // Retorna o indice do segmento da curva onde o ponto mais proximo de q foi 
  // encontrado. As coordenadas do ponto mais proximo s\u00e3o guardadas em r
  // 
  public int findClosestPoint (PVector[] cps, PVector q, PVector r) {

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

  public int[] getControlPointsBetween(PVector init, PVector pFinal){
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

  /** FIM DOS M\u00c9TODOS DE EDI\u00c7\u00c3O E CRIA\u00c7\u00c3O **/

  /** M\u00c9TODOS PARA PARAMETRIZA\u00c7\u00c3O DE UMA CURVA **/

  // Retorna o tamanho de uma curva dados uma lista de pontos de controle
  public float curveLength()
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
   M\u00c9TODOS DE DESENHAR
   **/
  // Desenha uma curva de acordo com a lista p de pontos de controle.
  public void draw()
  { 
    stroke(0);
    strokeWeight(1.5f);
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
  public void drawControlPoints()
  {
    fill(secondaryColor);
    stroke(secondaryColor);
    for (int i = 0; i < getNumberControlPoints(); i++) 
    {
      ellipse (controlPoints[i].x, controlPoints[i].y, 7, 7);
    }
    fill(255);
  }
  public void drawControlPoint(int index)
  {
    fill(mainColor);
    stroke(mainColor);
    ellipse(controlPoints[index].x, controlPoints[index].y, 10, 10);
  }

  public CurveCat clone(){
    CurveCat aux = new CurveCat();
    aux.controlPoints = new PVector[controlPoints.length];
    Utils.pvectorArrayCopy(controlPoints, aux.controlPoints);
    return aux;
  }
}

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
static class Utils{
  
  public static void printArrayPVector(PVector[] p)
  {
    for (int i=0;i<p.length-1;i++)
      println(i+" "+p[i]);
  }

  public static boolean mouseOverRect(PVector mouse, int x, int y, int w, int h) {
  	return (mouse.x >= x && mouse.x <= x+w && mouse.y >= y && mouse.y <= y+h);
  }

  public static void pvectorArrayCopy(PVector[] src, PVector[] dest){
  	for (int i = 0; i<src.length; i++){
  		dest[i] = src[i];
  	}
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "curveAnimation" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
