class TimeEditingState extends State {

    float timeSpacing = 1;
    SceneElement element;
    
    TimeEditingState(Context context){
      super(context);
      element = context.getSelectedElement();
      context.refreshInterpolator();
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
      for (int i = 0; i < element.lastTime(); ++i) {
        if(i % timeSpacing == 0){
          PVector pos = element.pos.get(i);
          fill(mainColor);
          stroke(mainColor);
          ellipse(pos.x, pos.y, 10, 10);
        }
      }
    }
}