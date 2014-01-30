class FontState extends State {

    Text text = null;

    FontState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
      if(text == null)
        text = new Text("", 
          20, 
          new PVector(context.mouse.x, context.mouse.y), 
          "", 
          color(0,0,0));
    }
    
    public void mouseReleased(PVector mouse) 
    {

    }
    public void mouseDragged()
    {	
      float dx = context.mouse.x - context.pMouse.x;
      float dy = context.mouse.y - context.pMouse.y;
    }

    public void keyPressed(){
      String text = this.text.getText();
      text = text + key; 
      this.text.setText(text);
    }

    public void draw()
    {
      if(this.text != null){
        this.text.draw();
      }
  	}

    public void drawInterface()
    {

    }
}