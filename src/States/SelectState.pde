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

      // Seleciona o segmento em questão se for o mouse LEFT
      PVector closestPoint = new PVector();
      PVector q = new PVector(context.mouse.x, context.mouse.y);
      int selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);

      //int closestControlPointIndex  = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));
      PVector closestControlPoint = context.curve.getControlPoint(selectedSegment);

      float distance = q.dist(closestPoint);

      if(distance < 10 && !(stateContext.getState() instanceof OverSketchState) && !(stateContext.getState() instanceof EditingState)){
        stateContext.setStateName("edit");
      }
      
      if(selectedSegment == context.curve.getNumberControlPoints() - 1 && distance < 10){
          stateContext.setStateName("draw");
      }
    }
    
    public void mouseReleased(PVector mouse) 
    {

    }
    
    public void mouseDragged()
    {
        //stateContext.setState(new DrawningState(context));
        //stateContext.mouseDragged();
    }

    public void keyPressed(){
      
    }

    public void draw()
    {

    }
}
