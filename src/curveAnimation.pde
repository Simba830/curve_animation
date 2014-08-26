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
  try {
    
  width = 800;
  height = 600;
  size(width, height);

  smooth();

  context = new Context();
  update();
  stateContext = new StateContext(context);
  stateContext.setContext(context);
  } catch (Exception e) {
    console.log(e);  
  }
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
  try {
    update();
    stateContext.keyPressed();
  } catch (Exception e) {
    console.log(e);  
  }
}

// Mouse press callback
void mousePressed() 
{
  try {
    update();
    stateContext.mousePressed();
  } catch (Exception e) {
    console.log(e);  
  }
}
    
void mouseReleased()
{
  try {
    update();
    stateContext.mouseReleased();
  } catch (Exception e) {
    console.log(e);
  }
}

// Mouse drag callback
void mouseDragged () 
{
  try {
    update();
    stateContext.mouseDragged();
  } catch (Exception e) {
    console.log(e);
  }
}


void draw() 
{
  try {
    update();
    stateContext.draw();
  } catch (Exception e) {
    console.log("Falha no Draw \ne.toString(): "+e.toString());
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


