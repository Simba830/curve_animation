class TimeEditingState extends State {

    private float timeSpacing = 2;
    private SceneElement element;
    private Property selectedProperty;
    private int selectedSegment;
    private CurveCat elementCurve;

    private float distanceToSelect = 20;
    
    TimeEditingState(Context context){
      super(context);
      selectedProperty = null;
      element = context.getSelectedElement();
      elementCurve = element.getCurve();
      elementCurve.reAmostragemPorTempo(timeSpacing);
      context.refreshInterpolator();
    }

    public void mousePressed() 
    {
      PVector closestPoint = new PVector();

      //Vector that
      PVector q = new PVector(context.mouse.x, context.mouse.y);

      // Context finde the closest point gives the selectedSegment
      selectedSegment = elementCurve.findClosestPoint(context.curve.controlPoints, q, closestPoint);
      float distance = q.dist(closestPoint);
      if (distance < distanceToSelect)
      {
        selectedProperty = elementCurve.getControlPoint(selectedSegment);
      }

    }

    public void mouseReleased() 
    {

    }

    public void mouseDragged()
    {
      if(selectedProperty){
        float t1 = selectedProperty.getT();
        float dx = context.mouse.x - context.pMouse.x;
        Property p = elementCurve.getPropertyByDif(selectedSegment, dx);
        elementCurve.setPoint(p, selectedSegment);
        selectedProperty = p;
      }
    }

    public void keyPressed(){

    }

    public void draw()
    {
      if(context.isPlayed()){
        // return;
      }

      Property p;
      for (int i = 0; i < elementCurve.getNumberControlPoints() - 1; ++i) {
          p = elementCurve.getControlPoint(i);
          fill(mainColor, 200);
          stroke(mainColor, 200);
          if(p == selectedProperty){
            fill(secondaryColor, 200);
          }
          ellipse(p.getX(), p.getY(), 10, 10);
          text("t: "+ ( (int) p.getT()), p.getX() + 10, p.getY() + 10);
      }
    }
}