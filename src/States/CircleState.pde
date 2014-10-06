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

        PVector pMouse = context.getpMouse();
        float dx = abs(pMouse.x - pos.x);
        float dy = abs(pMouse.y - pos.y);

        c.setWidth(dx);
        c.setHeight(dy);
    }
    
    public void mouseReleased() 
    {
        stateContext.setStateName("select");
    }

    public void keyPressed(){
      
    }

    public void draw()
    {

  	}
}