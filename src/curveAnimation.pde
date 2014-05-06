/**
 AnimationApp.pde
 Author: Guilherme Herzog e João Carvalho
 Created on: May 13
 **/

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

public void setup() 
{
  width = 800;
  height = 600;
  size(width, height);

  smooth();

  context = new Context();
  update();
  stateContext = new StateContext(context);
  stateContext.setContext(context);
}

Context getContext(){
  return context;
}

stateContext getStateContext(){
  return stateContext;
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
  update();
  stateContext.mousePressed();
}
    
void mouseReleased()
{

  update();
  stateContext.mouseReleased();
}

// Mouse drag callback
void mouseDragged () 
{
  update();
  stateContext.mouseDragged();
}


void draw() 
{
  update();
  try {
    stateContext.draw();
  } catch (Exception e) {
    println("Falha no Draw \ne.toString(): "+e.toString());
    e.printStackTrace();
  }
}

void update(){
  context.updateContext(
    new PVector(mouseX, mouseY),
    new PVector(pmouseX, pmouseY), 
    mouseButton,
    keyCode, 
    key);
}


