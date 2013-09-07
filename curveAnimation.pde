/**
 AnimationApp.pde
 Author: Guilherme Herzog
 Created on: May 13
 
 **/

 import java.awt.event.*;

// States 
final int DRAWING = 1;
final int EDITING = 2;
final int DEBUG = 3;

int state;
int selectedSegment; // Selected Segment of curve
int[] selectedSegments;
PVector closestPoint;
float tolerance;

PFont font; // it's a font
float curveT = 0;

// Curve
CurveCat curve;
CurveCat decimedCurve;

// Selection Box
PVector mouseInit;
PVector mouseFinal;

// Colours
color mainColor = #0066C8;
color secondaryColor = #FF9700;

public void setup() 
{
  size(800, 600);
  smooth();
  state = DRAWING; // First state
  selectedSegment = -1; 
  selectedSegments = new int[0];
  font = createFont("", 14);
  curve = new CurveCat();

  closestPoint = new PVector();
  tolerance = 5;

  mouseInit = new PVector(0,0);
  mouseFinal = new PVector(0,0);

  addMouseWheelListener(new MouseWheelListener() { 
    public void mouseWheelMoved(MouseWheelEvent mwe) { 
      mouseWheel(mwe.getWheelRotation());
  }}); 

  curveTightness(curveT);
}

void mouseWheel(float delta) {
  curveT += delta/10;
  curveT = constrain(curveT, -1.0, 1.0);

  curveTightness(curveT); 
}

// Key Press callback
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

    case '3' :
      state = DEBUG;
    break;  

    case DELETE :
      if (state == DRAWING)
      {
        curve.clear(); 
        state = DRAWING; // Set state Draw
        selectedSegment = -1; // Reset segment selected
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

  mouseInit.set(mouseX, mouseY);
  mouseFinal.set(mouseX, mouseY);

  if (state == DRAWING)
  { 
    curve.insertPoint(new PVector(mouseX, mouseY), curve.getNumberControlPoints());
  }
  if (state == EDITING)
  {
      if(mouseButton == RIGHT){

            if(selectedSegments.length == 0){
              selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));

              closestPoint = new PVector();
              PVector q = new PVector(mouseX, mouseY);
              selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
              float distance = q.dist(closestPoint);

              selectedSegments = new int[1];
              selectedSegments[0] = selectedSegment;
            }

            for (int i = selectedSegments.length - 1; i>=0; i--){
              curve.removeElement(selectedSegments[i]);
            }

            selectedSegments = new int[0];
      }else{
        selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));

        closestPoint = new PVector();
        PVector q = new PVector(mouseX, mouseY);
        selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
        float distance = q.dist(closestPoint);

        for (int i = 0; i<selectedSegments.length; i++){
          if(selectedSegment == selectedSegments[i]){
            if(distance > 20){
              selectedSegments = new int[0];
            } 
            return;
          }
        }

        selectedSegments = new int[1];
        selectedSegments[0] = selectedSegment;

        if (mouseEvent.getClickCount()==2){
          curve.insertPoint(q, selectedSegment + 1);

          selectedSegments[0]++;

          mouseInit.set(0, 0);
          mouseFinal.set(0, 0);
        }else if(distance > 20){
          selectedSegments = new int[0];
        } 
      }
  }
}
    
void mouseReleased()
{
  while(curve.canBeDecimed()){
    curve.decimeCurve(tolerance);
  }

  if(state == EDITING && selectedSegments.length == 0){
    selectedSegments = curve.getControlPointsBetween(mouseInit, mouseFinal);
  }

  mouseInit.set(0,0);
  mouseFinal.set(0,0);
}

// Mouse drag callback
void mouseDragged () 
{
  mouseFinal.set(mouseX, mouseY);
  if (state == DRAWING && mouseButton == LEFT)
    curve.insertPoint(new PVector(mouseX, mouseY), curve.getNumberControlPoints());
  if (state == EDITING) // Editing
  {
    if (mouseButton == LEFT)
    {

      if (selectedSegments.length != 0)
      {
        float dx = mouseX - pmouseX;
        float dy = mouseY - pmouseY;

        for (int i = 0; i<selectedSegments.length; i++){
          PVector controlPoint = curve.getControlPoint(selectedSegments[i]);
          curve.setPoint(new PVector(controlPoint.x + dx, controlPoint.y + dy), selectedSegments[i]);
        }
      }
    }
  }
}


void draw() 
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

    fill(mainColor, 50);
    stroke(mainColor, 50);
    rect(mouseInit.x, mouseInit.y, mouseFinal.x - mouseInit.x, mouseFinal.y - mouseInit.y);
  }
}

void drawInterface() 
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
    break;
    case DEBUG :
      fill(255);
      text("Curve Length:"+curve.curveLength()+" px", 10, height-20);
    break;  
  }

  text("Curve Length:"+curve.curveLength()+" px", 10, height-20);
}


