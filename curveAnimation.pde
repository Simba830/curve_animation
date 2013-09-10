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
void mousePressed() 
{
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
    state = DRAWING;
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
        state = EDITING;
        canSketch = false;  
    }
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
            if(selectedSegments.length == 0)
            {

              // Então seleciona o mais próximo
              selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));
              closestPoint = new PVector();
              q = new PVector(mouseX, mouseY);
              selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
              distance = q.dist(closestPoint);

              selectedSegments = new int[1];
              selectedSegments[0] = selectedSegment;
            }

            // Remove todos os segmentos selecionados
            for (int i = selectedSegments.length - 1; i>=0; i--){
              curve.removeElement(selectedSegments[i]);
            }

            // Remove a seleção
            selectedSegments = new int[0];
      }
      else
      {

        // Seleciona o segmento em questão se for o mouse LEFT
        selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));

        closestPoint = new PVector();
        q = new PVector(mouseX, mouseY);
        selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
        distance = q.dist(closestPoint);

        boolean selected = false;
        // Se o segmento mais próximo já estiver selecionado saí da função

        if(distance > distanceToSelect){
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
        }else if(distance > distanceToSelect){
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
  if (selectedSegments.length == 0)
    state = DRAWING;

  // Retorna o estado de poder desenhar para FALSE
  canSketch = false;

  mouseInit.set(0,0);
  mouseFinal.set(0,0);
}

// Mouse drag callback
void mouseDragged () 
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
        // Pega a variação de x e de y
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

    // Desenha caixa de seleção com Alpha 50
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
  }

  // If debug is actived
  if(debug){
      fill(255,0,0);
      stroke(255,0,0);
      text("Curve Length:"+curve.curveLength()+" px", 10, height-20);
      text("Curve Tightness:"+curveT, 10, 20);
      text("Tolerance:"+tolerance, 10, 40);
  }

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


