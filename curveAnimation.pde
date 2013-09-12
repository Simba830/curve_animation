/**
 AnimationApp.pde
 Author: Guilherme Herzog
 Created on: May 13
 
 **/

 import java.awt.event.*;

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
final StateContext stateContext = new StateContext();

// Colours
color mainColor = #0066C8;
color secondaryColor = #FF9700;
color thirdColor = #3990E3;

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
  curveT = 0;
  distanceToSelect = 5;

  // PVectors used to create the selection box
  mouseInit = new PVector(0,0);
  mouseFinal = new PVector(0,0);

  // Add a listener to the mouseWheel
  /*addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }});*/ 

  curveTightness(curveT);

  // State context;


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
  switch (key){
    case '1' :
      selectedSegments = new int[0];
      stateContext.setState(new DrawningState());
    break;  

    case '2' :
        stateContext.setState(new EditingState());
    break;  

    case 'd' :
      debug = !debug;
    break;  

    // Essa tecla é específica para cada estado, entao devemos implementá-la nas classes de State
    case DELETE :
      if (state == DRAWING)
      {
        curve.clear(); 
        stateContext.setState(new DrawningState());
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
void mousePressed() 
{
  
  stateContext.mousePressed(new PVector(mouseX,mouseY));

  mouseInit.set(mouseX, mouseY);
  mouseFinal.set(mouseX, mouseY);

  // Então seleciona o mais próximo
  selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));
  closestPoint = new PVector();
  
  if(Utils.mouseOverRect(new PVector(mouseX, mouseY), width-80-130, height-20-20, 110,30)){
    
    return;
  }

  if(Utils.mouseOverRect(new PVector(mouseX, mouseY),width/2 + 60,height-40, 110, 30)){
    curve.clear();
    stateContext.setState(new DrawningState());
    selectedSegments = new int[0];
    selectedSegment = -1;
    return;
  }

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
        stateContext.setState(new EditingState());
        canSketch = false;
    }
  }
}
    
void mouseReleased()
{
  
  stateContext.mouseReleased(new PVector(mouseX,mouseY));
  

  while(curve.canBeDecimed()){
    curve.decimeCurve(tolerance);
  }

  
  // Retorna o estado de poder desenhar para FALSE
  canSketch = false;

  // Resets dragged rectangle
  mouseInit.set(0,0);
  mouseFinal.set(0,0);
}

// Mouse drag callback
void mouseDragged () 
{
  stateContext.mouseDragged(new PVector(mouseX,mouseY),mouseFinal);
  mouseFinal.set(mouseX, mouseY);
}


void draw() 
{
  stateContext.draw();
  drawInterface();
}

void drawInterface() 
{

  stateContext.drawInterface();


  // Todo esse código pode ser colocado no método generalizado da classe StateContext. 
  fill(96);
  textFont(font);

  int textx = 5, texty = height-100;
  if (curve.getNumberControlPoints() < 4)
    text("Click 4 times to define control points", textx, texty+=15);
  text("Key '1' set state to CREATING", textx, texty+=15);
  text("Key '2' set state to EDITING", textx, texty+=15);
  text("Key 'DEL' create a new Curve", textx, texty+=15);

  // If debug is actived
  if(debug){
      fill(255,0,0);
      stroke(255,0,0);
      text("Curve Length:"+curve.curveLength()+" px", 10, height-20);
      text("Curve Tightness:"+curveT, 10, 20);
      text("Tolerance:"+tolerance, 10, 40);
  }
  
  int posX = width-80;
  int posY = height-20;
  stroke(thirdColor);
  fill(thirdColor);
  rect(posX-130, posY-20, 110, 30);

  stroke(255);
  fill(255);
  text("OverSkecthing", posX-125, posY);

  stroke(thirdColor);
  fill(thirdColor);
  rect(width/2 + 60, height-40, 110, 30);

  stroke(255);
  fill(255);
  text("Clear", width/2 + 70, height-20);
}


