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
      // Pega a variação de x e de y
      float dx = context.mouse.x - context.pMouse.x;
      float dy = context.mouse.y - context.pMouse.y;

      SceneElement selected = context.getSelectedElement();
      PVector ini = selected.getInitialPosition();

      selected.setInitialPosition( new PVector(ini.x + dx, ini.y + dy) );
    }

    public void keyPressed(){
      
    }

    public void draw()
    {

    }
}
