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
    size(screen.width*0.8, screen.height*0.7, P2D);
    width = screen.width*0.8;
    height = screen.height*0.7;

    smooth();

    frameRate(60);
    context = new Context();
    update();
    stateContext = new StateContext(context);
    hint(DISABLE_DEPTH_TEST)
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
  
  fill(255,0,0);

  text('FPS: '+(int)frameRate, 20, 20);
}

void update(){
  context.updateContext(
    new PVector(mouseX, mouseY),
    new PVector(pmouseX, pmouseY), 
    mouseButton,
    keyCode, 
    key);
}


