class TimeEditingState extends State {

    private float timeSpacing = 1;
    private SceneElement element;
    private ArrayList<Property> timeControlPoints;
    
    TimeEditingState(Context context){
      super(context);
      element = context.getSelectedElement();
      context.refreshInterpolator();
      timeControlPoints = new ArrayList<Property>();

      Property p;
      for (int i = 0; i < element.lastTime(); ++i) {
        if(i % timeSpacing == 0){
          p = element.pos.getProperty(i);
          p.setT(i);
          timeControlPoints.add(p);
        }
      }

      console.log(timeControlPoints.toArray());
    }

    public void mousePressed() 
    {

    }

    public void mouseReleased() 
    {

    }

    public void mouseDragged()
    {

    }

    public void keyPressed(){

    }

    public void draw()
    {
      Property p;
      for (int i = 0; i < timeControlPoints.size(); ++i) {
          p = timeControlPoints.get(i);
          fill(mainColor);
          stroke(mainColor);
          ellipse(p.getX(), p.getY(), 10, 10);
          text("t: "+p.getT(), p.getX() + 10, p.getY() + 10);
      }
    }
}