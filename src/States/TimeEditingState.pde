class TimeEditingState extends State {

    float timeSpacing = 2;
    SceneElement element;
    
    TimeEditingState(Context context){
      super(context);
      element = context.getSelectedElement();
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
          println("test");
          PVector pos = element.pos.get(i);
          println("pos: "+pos);
          fill(mainColor);
          stroke(mainColor);
          //ellipse(pos.x, pos.y, 10, 10);
        }
      }
    }
}