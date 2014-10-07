public class StateContext {

    private State myState;
    private Context context;
    
    // Selection Box
    PVector mouseInit;
    PVector mouseFinal;

    /**
     * Standard constructor
     */
    StateContext(Context _context) 
    {
        setState(new SelectState(_context));
        this.context = _context;
        mouseInit = new PVector(0,0);
        mouseFinal = new PVector(0,0);
    }

    public void setContext(Context _context){
        this.context = _context;
    }

    public void setStateName(String nameState){
        switch (nameState) {
            case 'circle' :
                myState = new CircleState(this.context);
            break;   

            case 'square' :
                myState = new SquareState(this.context);
            break;

            case 'select' :
                 myState = new SelectState(this.context);
             break;   

            case 'draw' :
                  myState = new DrawningState(this.context);
              break;  

            case 'edit' :
                  myState = new EditingState(this.context);
              break; 

            case 'size' :
                  myState = new SizeEditingState(this.context);
              break; 

            case 'time' :
                  myState = new SimpleTimeEditingState(this.context);
              break;       

            case 'image' :
                  myState = new ImageState(this.context);
              break;     

            default :
                myState = new DrawningState(this.context);
            break;    
        }
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

    public State getState() {
        return myState;
    }
 
    /**
     * Mouse Actions Methods
     * @param  PVector mouse
     */
    void mousePressed()
    {
        // // Inicializa os ponteiros para o retangulo de seleção.
        mouseInit.set(mouseX, mouseY);
        mouseFinal.set(mouseX, mouseY);

        myState.mousePressed();
    }
    
    void mouseDragged()
    {
        // Cria a caixa de seleção independente do State da aplicação
        mouseFinal.set(mouseX, mouseY);
        context.setSelectionBox(mouseInit, mouseFinal);
        myState.mouseDragged();
    }
    void mouseReleased()
    {
        // Resets dragged rectangle
        mouseInit.set(0,0);
        mouseFinal.set(0,0);
        
        myState.mouseReleased();
    }

    void keyPressed(){
        switch (context.key){
            case 'z' :
                this.context.curve.undo();
            break;         

            case 'r' :
                this.context.curve.redo();
            break;    

            // Essa tecla é específica para cada estado, entao devemos implementá-la nas classes de State
            case DELETE :
              myState.keyPressed();
            break;
        }

        myState.keyPressed();
    }
    
    void draw()
    {
        background (255);
        noFill();

        if(context.isPlayed()){
            float lastTime = context.lastTime();

            if(lastTime == 0){
                context.stop();
            }else{
                context.draw( (frameCount/5) % int(lastTime));
            }


        }else{
            context.draw(0.0);
            myState.draw();
        }
        
    }

    void is(State testState){
        return typeof(testState) == typeof(myState);
    }
}