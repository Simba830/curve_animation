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
                        return;
    		}
    	}
    }
    
    public void mouseReleased(PVector mouse) 
    {

    }
    
    public void mouseDragged()
    {
        stateContext.setState(new DrawningState(context));
        stateContext.mouseDragged();
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
