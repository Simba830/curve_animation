class DrawningState extends State {

    DrawningState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
      this.context.curve.insertPoint(this.context.mouse);
    }
    
    public void mouseReleased(PVector mouse) 
    {
    	
    }
    public void mouseDragged()
    {	
  		context.curve.insertPoint(context.mouse, context.curve.getNumberControlPoints());
    }

    public void keyPressed(){
      context.curve.clear(); 
      context.selectedSegments = new int[0];
    }

    public void draw()
    {
    	
  	}

    public void drawInterface()
    {
      int posX = width-80;
	    int posY = height-20;
      fill(mainColor);
      stroke(mainColor);
      rect(posX-10,posY-20,80,30);
      fill(255);
      text("Creating", posX, posY);
    }
 
}