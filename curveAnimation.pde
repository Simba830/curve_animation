/**
 AnimationApp.pde
 Author: Guilherme Herzog
 Created on: May 13
 
 **/

 import java.awt.event.*;

// States 
final int DRAWING = 1;
final int EDITING = 2;

// Variaveis de Curvas
int selectedSegment;
PVector closestPoint;
float tolerance;
boolean canSketch;
PVector q;
float distance;
float distanceToSelect;

PFont font; // it's a font
float curveT;

// Curve
CurveCat curve;
CurveCat decimedCurve;

// Selection Box
PVector mouseInit;
PVector mouseFinal;

// State Context
StateContext stateContext;

// Context
Context context;

// Colours
color mainColor = #0066C8;
color secondaryColor = #FF9700;
color thirdColor = #3990E3;

public void setup() 
{
  size(800, 600);
  smooth();

  font = createFont("", 14);
  curve = new CurveCat();
  canSketch = true;
  closestPoint = new PVector();
  tolerance = 7;
  curveT = 0;
  distanceToSelect = 5;

  // PVectors used to create the selection box
  mouseInit = new PVector(0,0);
  mouseFinal = new PVector(0,0);

  // Add a listener to the mouseWheel
  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }}); 

  curveTightness(curveT);

  context = new Context();
  update();
  context.setSelectionBox(mouseInit, mouseFinal);

  stateContext = new StateContext(context);
  stateContext.setContext(context);
}

// TODO Pensar em como portar isso para o Javascript
void mouseWheel(float delta) {
  curveT += delta/10;
  curveT = constrain(curveT, -1.0, 1.0);

  curveTightness(curveT); 
}

// TODO Mudar isso para um interface só usando o mouse
public void keyPressed() 
{ 
  update();
  stateContext.keyPressed();
}

// Mouse press callback
void mousePressed() 
{
  mouseInit.set(mouseX, mouseY);
  mouseFinal.set(mouseX, mouseY);

  // Então seleciona o mais próximo
  selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));
  closestPoint = new PVector();

  // Verifica se o local clicado é proximo do final da curva;
  if (selectedSegment == curve.getNumberControlPoints()-1)
  {
     canSketch = true;
  }
  else // Caso nao seja, verifica se foi proximo da curva, caso tenha sido, alterna para o modo EDITING;
  {
    q = new PVector(mouseX, mouseY);
    selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
    distance = q.dist(closestPoint);
    if (distance <= distanceToSelect)
    {
        stateContext.setState(new EditingState(context));
        canSketch = false;
    }
  }

  update();
  stateContext.mousePressed();
}
    
void mouseReleased()
{
  while(curve.canBeDecimed()){
    curve.decimeCurve(tolerance);
  }
  
  // Retorna o estado de poder desenhar para FALSE
  canSketch = false;

  update();
  stateContext.mouseReleased();

  // Resets dragged rectangle
  mouseInit.set(0,0);
  mouseFinal.set(0,0);
  update();
}

// Mouse drag callback
void mouseDragged () 
{
  update();
  mouseFinal.set(mouseX, mouseY);
  stateContext.mouseDragged();
}


void draw() 
{
  update();
  stateContext.draw();
  stateContext.drawInterface();
}

void update(){
  context.updateContext(
    curve, 
    new PVector(mouseX, mouseY),
    new PVector(pmouseX, pmouseY), 
    mouseButton,
    keyCode, 
    key,
    mouseInit,
    mouseFinal);

    try{
      context.setMouseCount(mouseEvent.getClickCount());
    }catch(NullPointerException e){
      context.setMouseCount(0);
    }
}


