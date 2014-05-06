class DrawningState extends State {

    float distanceToSelect = 5;
    private boolean canSketch;
    float t, ms;

    DrawningState(Context _context){
      super(_context);

      context.curve.decimeAll();
      // Adding a comentary
    }

    public void mousePressed() 
    {
      t = 0;
      ms = frameCount;
      // Então seleciona o mais próximo
      int selectedSegment = context.curve.findControlPoint(context.mouse);
      // Verifica se o local clicado é proximo do final da curva;
      if (selectedSegment == context.curve.getNumberControlPoints()-1){ canSketch = true; }
      else { canSketch = false; }
        
      if (canSketch){
        this.context.curve.insertPoint(new Property(this.context.mouse.x, this.context.mouse.y));
      }
    }
    
    public void mouseReleased(PVector mouse) 
    {
        super.mouseReleased();
    	  // Retorna o estado de poder desenhar para FALSE
        //canSketch = false;

        context.refreshInterpolator();
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
        context.mouse.add(new PVector(0,0,t));
  		  context.curve.insertPoint( new Property(context.mouse.x, context.mouse.y, context.mouse.z), context.curve.getNumberControlPoints());
      }
    }

    public void keyPressed(){
      context.curve.clear(); 
      context.selectedSegments = new int[0];
    }

    public void draw()
    {
    	
  	}
}