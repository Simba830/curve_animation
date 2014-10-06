class SquareState extends State {

    SquareState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
        Square c = new Square(20,20);
        c.sizeInterpolator.set(0, new Property());
        context.addElement(c);  
        context.setSelectedElement(c);
    }

    public void mouseDragged(){
        Square c = context.getSelectedElement();
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