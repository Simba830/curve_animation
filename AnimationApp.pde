/**
 AnimationApp.pde
 Author: Guilherme Herzog
 Created on: May 13
 
 **/

// States 
final int  DRAWING = 1;
final int  EDITING = 2;
final int  DEBUG = 3;

int state;
int selectedSegment; // Selected Segment of curve
PVector closestPoint;
float tolerance;

PFont font; // it's a font

// Curve
CurveCat curve;
CurveCat decimedCurve;


public void setup() 
{
  size(800, 600);
  smooth();
  state = DRAWING; // First state
  selectedSegment = -1; 
  font = createFont("", 14);
  curve = new CurveCat();

  closestPoint = new PVector();
  tolerance = 5;
}

// Key Press callback
public void keyPressed() 
{ 
  switch (key){
    case '1' :
      state = DRAWING;
    break;  

    case '2' :
        state = EDITING;
    break;  

    case '3' :
      state = DEBUG;
    break;  

    case DELETE :
      if (state == 1)
      {
        curve.clear(); 
        state = DRAWING; // Set state Draw
        selectedSegment = -1; // Reset segment selected
      }
      else if (state == EDITING && selectedSegment != -1)
      {
        curve.controlPoints = curve.removeElement(curve.controlPoints, selectedSegment);
        selectedSegment--;
      }
    break;
  }
}
// Mouse press callback
void mousePressed() 
{
  if (state == DRAWING)
  { 
    curve.insertPoint(new PVector(mouseX, mouseY), curve.getNumberControlPoints());
  }
  if (state == EDITING)
  {
    selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));
  }
}
    
void mouseReleased()
{
  while(curve.canBeDecimed()){
    curve.decimeCurve(tolerance);
  }

  selectedSegment=-1;
}

// Mouse drag callback
void mouseDragged () 
{
  if (state == DRAWING && mouseButton == LEFT)
    curve.insertPoint(new PVector(mouseX, mouseY), curve.getNumberControlPoints());
  if (state == EDITING) // Editing
  {
    if (mouseButton == RIGHT) 
    {
      float t = map(mouseX, 0, width, -5, 5);
      curveTightness(t);
    }
    else if (mouseButton == LEFT)
    {
      if (selectedSegment != -1)
      {
        curve.setPoint(new PVector(mouseX, mouseY), selectedSegment);
      } 
      else
      {
        closestPoint = new PVector();
        PVector q = new PVector(mouseX, mouseY);
        selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
        float distance = q.dist(closestPoint);
        if (distance < 5)
        {
          curve.insertPoint(q, selectedSegment);
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

  if (curve.getNumberControlPoints() >=4) { 
    curve.draw();
  }
  if (state == EDITING || curve.getNumberControlPoints() < 4) { 
    curve.drawControlPoints();
  }
  if (selectedSegment != -1) { 
    curve.drawControlPoint(selectedSegment);
  }

  fill(255, 0, 0);
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
      fill(200,100,0);
      rect(posX-10,posY-20,80,30);
      fill(255);
      text("Creating", posX, posY);
    break;  
    case EDITING :
      fill(0,100,200);
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


