class DrawningState extends State {

    float distanceToSelect = 5;
    private boolean canSketch;
    float t, ms;

    DrawningState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {

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
      
      
      // if(selectedSegment == context.curve.getNumberControlPoints() - 1 && distance < 10){
      //     stateContext.setStateName("draw");
      // }

      // Lógica específica do Drawning
      t = 0;
      ms = frameCount;

      // Então seleciona o mais próximo
      int selectedSegment = context.curve.findControlPoint(context.mouse);
      // Verifica se o local clicado é proximo do final da curva;
      if (selectedSegment == context.curve.getNumberControlPoints()-1){ canSketch = true; }
      else { canSketch = false; }
        
      if (canSketch){
        Property myPoint = new Property(this.context.mouse.x, this.context.mouse.y, 0);
        myPoint.setSize(1);
        this.context.curve.insertPoint(myPoint);
      }
    }
    
    public void mouseReleased(PVector mouse) 
    {
        // super.mouseReleased();
    	  // Retorna o estado de poder desenhar para FALSE
        //canSketch = false;

        // context.refreshInterpolator();
    }
    public void mouseDragged()
    {	
      float elapsed = 0;
      if(frameCount != ms){
        elapsed = frameCount - ms;
      }
      ms = frameCount;
      t = t + elapsed;

      if (canSketch){
        Property myPoint = new Property(context.mouse.x, context.mouse.y, t);
        myPoint.setSize(1);
  		  context.curve.insertPoint( myPoint, context.curve.getNumberControlPoints());
      }
    }

    public void keyPressed(){
      context.curve.clear(); 
      context.selectedSegments = new int[0];
    }

    public void draw()
    {
      float elapsed = 0;
      if(frameCount != ms){
        elapsed = frameCount - ms;
      }
      ms = frameCount;
      t = t + elapsed;
      
      text('Time: '+t, width - 60, 20);
  	}
}