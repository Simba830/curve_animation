class SizeEditingState extends State {

    private float timeSpacing = 1;
    private SceneElement element;
    private Property selectedProperty;
    private int selectedSegment;
    private CurveCat elementCurve;
    private ArrayList<Property> controlPoints;
    private CurveCat auxCurve;
    private float dx;

    private float distanceToSelect = 20;
    
    SizeEditingState(Context context){
      super(context);
      dx = 0;
      selectedProperty = null;
      element = context.getSelectedElement();
      elementCurve = element.getCurve();
      controlPoints = elementCurve.getControlPoints();
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
      if(selectedProperty != null){
        int dx = context.mouse.x - context.pMouse.x;
        selectedProperty.setSize( selectedProperty.getSize() + (dx/100));
        elementCurve.updateRender();
      }
    }

    public void keyPressed(){

    }

    public void draw()
    {
      controlPoints = elementCurve.getControlPoints();
      Property p;

      if(context.isPlayed())
        return;

      for (int i = 0; i < controlPoints.size(); ++i) {
          p = controlPoints.get(i);
          pushMatrix();

          if(p == selectedProperty){
            fill(secondaryColor, 200);
            stroke(secondaryColor, 200);
          }else{
            fill(mainColor, 200);
            stroke(mainColor, 200);
          }
          

          translate(p.getX(), p.getY(), 10);
          sphere(10);
          ellipse(0, 0, 10, 10);
          text("t: "+ ( (int) p.getT()), 10, 10);

          text('Size: '+ (p.getSize()) , 10, 20);
          popMatrix();
      }
    }
}