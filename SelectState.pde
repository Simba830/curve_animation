class SelectState extends State
{
	SelectState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
    	for (SceneElement o : context.sceneElements) {
    		if(o.isOver(context.mouse)){
    			context.setSelectedElement(o);
    		}
    	}
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