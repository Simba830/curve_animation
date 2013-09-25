public class StateContext {

    private State myState;
    private Context context;
    private boolean debug;

        /**
         * Standard constructor
         */
    StateContext(Context _context) 
    {
        debug = false;
        setState(new DrawningState(_context));
        
    }

    public void setContext(Context _context){
        this.context = _context;
    }

    public void debug(){
        debug = !debug;
    }
 
    /**
     * Setter method for the state.
     * Normally only called by classes implementing the State interface.
     * 
     * Devemos criar um método setState pra cada Estado
     * @param NEW_STATE
     */
    public void setState(final State NEW_STATE) {
        myState = NEW_STATE;
    }
 
    /**
     * Mouse Actions Methods
     * @param  PVector mouse
     */
    void mousePressed()
    {
        // Verifica se clicou no botão "Clear";
        if(Utils.mouseOverRect(new PVector(mouseX, mouseY),width/2 + 60,height-40, 110, 30)){
            context.curve.clear();
            this.setState(new DrawningState(context));
            context.selectedSegments = new int[0];
            return;
        }

        if(Utils.mouseOverRect(new PVector(mouseX, mouseY),width-80-130, height-20-20, 110, 30)){

            if(this.myState instanceof OverSketchState){
                this.setState(new EditingState(context));
                return;
            }

            this.setState(new OverSketchState(context));
            context.selectedSegments = new int[0];
            return;
        }

        myState.mousePressed();
    }
    void mouseDragged()
    {
        myState.mouseDragged();
    }
    void mouseReleased()
    {
        myState.mouseReleased();
    }

    void keyPressed(){
        switch (context.key){
            case '1' :
              this.setState(new DrawningState(this.context));
            break;  

            case '2' :
                this.setState(new EditingState(this.context));
            break;  

            case 'd' :
              this.debug();
            break;  

            // Essa tecla é específica para cada estado, entao devemos implementá-la nas classes de State
            case DELETE :
              myState.keyPressed();
            break;
        }
    }
    void draw()
    {
        background (255);
        noFill();
        if (context.curve.getNumberControlPoints() >=4) 
            context.curve.draw();
        myState.draw();
    }
    void drawInterface()
    {
        int posX = width-80;
        int posY = height-20;
        stroke(thirdColor);
        fill(thirdColor);
        rect(width-80-130, height-20-20, 110, 30);

        stroke(255);
        fill(255);
        text("OverSkecthing", posX-125, posY);

        stroke(thirdColor);
        fill(thirdColor);
        rect(width/2 + 60, height-40, 110, 30);

        stroke(255);
        fill(255);
        text("Clear", width/2 + 70, height-20);

        myState.drawInterface();

        if(debug){
          fill(255,0,0);
          stroke(255,0,0);
          text("Curve Length:"+context.curve.curveLength()+" px", 10, height-20);
          text("Curve Tightness:"+curveT, 10, 20);
          text("Tolerance:"+context.tolerance, 10, 40);
        }
    }
}