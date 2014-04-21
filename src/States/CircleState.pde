class CircleState extends State {

    CircleState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
    	Circle c = new Circle(20,20);
    	context.addElement(c);	
        context.setSelectedElement(c);
    }

    public void mouseDragged(){
        Circle c = context.getSelectedElement();
        PVector pos = c.pos.get(0);

        float dx = abs(context.pMouse.x - pos.x);
        float dy = abs(context.pMouse.y - pos.y);

        c.setWidth(dx);
        c.setHeight(dx);
    }
    
    public void mouseReleased() 
    {
        stateContext.setStateName("draw");
    }

    public void keyPressed(){
      
    }

    public void draw()
    {

  	}
}