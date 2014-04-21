/**
 AnimationApp.pde
 Author: Guilherme Herzog
 Created on: May 13
 **/

float curveT;

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

// Canvas Size
int width,height;

Context getContext(){
  return context;
}

stateContext getStateContext(){
  return stateContext;
}

public void setup() 
{
  width = 800;
  height = 600;
  size(width, height);

  smooth();

  curveT = 0;

  // PVectors used to create the selection box
  mouseInit = new PVector(0,0);
  mouseFinal = new PVector(0,0);

  curveTightness(curveT);

  context = new Context();
  update();
  context.setSelectionBox(mouseInit, mouseFinal);

  stateContext = new StateContext(context);
  stateContext.setContext(context);
}

// TODO Mudar isso para um interface só usando o mouse
void keyPressed() 
{ 
  update();
  stateContext.keyPressed();
}

// Mouse press callback
void mousePressed() 
{
  mouseInit.set(mouseX, mouseY);
  mouseFinal.set(mouseX, mouseY);
  update();
  stateContext.mousePressed();
}
    
void mouseReleased()
{

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
  try {
    stateContext.draw();
  } catch (Exception e) {
    println("e.toString(): "+e.toString());
    e.printStackTrace();
  }
}

void update(){
  context.updateContext(
    new PVector(mouseX, mouseY),
    new PVector(pmouseX, pmouseY), 
    mouseButton,
    keyCode, 
    key,
    mouseInit,
    mouseFinal);
}


