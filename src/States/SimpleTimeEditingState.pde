class SimpleTimeEditingState extends State {

    private SceneElement element;
    private CurveCat elementCurve;

    private float distanceToSelect = 20;
    private Property selectedProperty;
    private int selectedSegment;
    
    SimpleTimeEditingState(Context context){
      super(context);
      element = context.getSelectedElement();
      elementCurve = element.getCurve();
      selectedProperty = null;
      selectedSegment = null;
    }

    public void mousePressed() 
    {
      // Create a variable for the closestpoint
      PVector closestPoint = new PVector();

      //Vector that
      PVector q = new PVector(context.mouse.x, context.mouse.y);

      // Context finde the closest point gives the selectedSegment
      selectedSegment = context.curve.findClosestPoint(context.curve.controlPoints, q, closestPoint);

      float distance = q.dist(closestPoint);
      if (distance < distanceToSelect)
      {
       selectedProperty = elementCurve.getControlPoint(selectedSegment);
      }else{
        selectedProperty = null;
      }
    }

    public void mouseReleased() 
    {

    }

    public void mouseDragged()
    {
      if(selectedSegment != null){
        int dx = context.mouse.x - context.pMouse.x;
        Property previousProperty = elementCurve.getControlPoint(selectedSegment - 1);
        Property nextProperty = elementCurve.getControlPoint(selectedSegment + 1);
        if( previousProperty.getT() < selectedProperty.getT() + dx && nextProperty.getT() > selectedProperty.getT() + dx){ 
          selectedProperty.setT( selectedProperty.getT() + dx);
        }
      }
    }

    public void keyPressed(){

    }

    public void draw()
    {
      for (Property p : elementCurve.getControlPoints() ) {
        pushMatrix();

        if(selectedProperty == p){
          fill(0,0,255);
        }else{
          fill(0);
        }
        translate(p.getX(), p.getY());
        text(p.getT(), 0 , -10);
        ellipse(0, 0, p.getWidth(), p.getHeight());

        popMatrix();

      }
    }
}