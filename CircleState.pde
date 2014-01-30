class CircleState extends State {

    CircleState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
    	Circle c = new Circle(20,20);
    	context.addElement(c);	
    	println("test");
    }
    
    public void mouseReleased(PVector mouse) 
    {

    }

    public void keyPressed(){
      
    }

    public void draw()
    {

  	}

    public void drawInterface()
    {

    }
}