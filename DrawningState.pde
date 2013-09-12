class DrawningState implements interfaceState {
    /* 
     * 
     */
    @Override
    public void mousePressed(PVector mouse) 
    {
    	if (canSketch)
        	curve.insertPoint(new PVector(mouseX, mouseY), curve.getNumberControlPoints());
    }
    public void mouseReleased(PVector mouse) 
    {
    	
    }
    public void mouseDragged(PVector mouse, PVector pmouse)
    {	
    	if (mouseButton == LEFT)
    		if (canSketch)
        		curve.insertPoint(new PVector(mouseX, mouseY), curve.getNumberControlPoints());
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