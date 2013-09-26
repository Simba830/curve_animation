class DrawningState extends State {

    float distanceToSelect = 5;
    private boolean canSketch;

    DrawningState(Context _context){
      super(_context);
    }

    public void mousePressed() 
    {
      // Então seleciona o mais próximo
      int selectedSegment = context.curve.findControlPoint(context.mouse);
      // Verifica se o local clicado é proximo do final da curva;
      if (selectedSegment == context.curve.getNumberControlPoints()-1){ canSketch = true; }
      else { canSketch = false; }
        
      if (canSketch){
        this.context.curve.insertPoint(this.context.mouse);
      }
      
    }
    
    public void mouseReleased(PVector mouse) 
    {
    	  // Retorna o estado de poder desenhar para FALSE
        canSketch = false;
    }
    public void mouseDragged()
    {	
      if (canSketch)
  		  context.curve.insertPoint(context.mouse, context.curve.getNumberControlPoints());
    }

    public void keyPressed(){
      context.curve.clear(); 
      context.selectedSegments = new int[0];
    }

    public void draw()
    {
    	
  	}

    public void drawInterface()
    {
      int posX = width-80;
	    int posY = height-20;
      fill(mainColor);
      stroke(mainColor);
      rect(posX-10,posY-20,80,30);
      fill(255);
      text("Creating", posX, posY);
    }
 
}