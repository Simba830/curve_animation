class TimeEditingState extends State {

    private float timeSpacing = 1;
    private SceneElement element;
    private Property selectedProperty;
    private int selectedSegment;
    private CurveCat elementCurve;
    private ArrayList<Property> controlPoints;
    private CurveCat auxCurve;
    private float dx;

    private float distanceToSelect = 20;
    
    TimeEditingState(Context context){
      super(context);
      dx = 0;
      selectedProperty = null;
      element = context.getSelectedElement();
      elementCurve = element.getCurve();
      controlPoints = elementCurve.getControlPointsClone();
      elementCurve.draw = function(){
        color from = color(#FF0000);
        color to = color(#00FF00);

        if(vertexs.size() >= 4){
          beginShape(QUAD_STRIP);
          for (int i = 0; i < vertexs.size() - 1; i++) {
            PVector vi = vertexs.get(i);
            noStroke();
            fill(0,0,0);
            fill(lerpColor(from, to, (float)j/segmentlength));

            vertex(vi.x, vi.y);
          }
          
          endShape();
        }
      }
    }

    public void mousePressed() 
    {
      Property p;
      for (int i = 0; i < controlPoints.size(); i++) {
        p = controlPoints.get(i);
        if(dist(p.getX(), p.getY(), context.getMouse().x, context.getMouse().y) < 20){
          selectedProperty = p;
          selectedSegment = i;
          dx = 0;
        }
      }
    }

    public void mouseReleased() 
    {

    }

    public void mouseDragged()
    {
      if(selectedProperty){
        dx += context.mouse.x - context.pMouse.x;
        if(dx != 0){
          Property p = elementCurve.getPropertyByDif(selectedSegment, dx);
          p.setT(selectedProperty.getT());
          controlPoints.set(selectedSegment, p);
          selectedProperty = p;
        }
      }
    }

    public void keyPressed(){

    }

    public void draw()
    {
      Property p;
      stroke(mainColor, 200);

      for (int i = 0; i < controlPoints.size() - 1; ++i) {
          p = controlPoints.get(i);

          if(p == selectedProperty){
            fill(secondaryColor, 200);
          }else{
            fill(mainColor, 200);
          }
          
          ellipse(p.getX(), p.getY(), 10, 10);
          text("t: "+ ( (int) p.getT()), p.getX() + 10, p.getY() + 10);
      }
    }
}