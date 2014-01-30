public class StateContext {

    private State myState;
    private Context context;
    private HorizontalMenu menu;
    private VerticalMenu listElements;

    private boolean debug;
        /**
         * Standard constructor
         */
    StateContext(Context _context) 
    {
        debug = false;
        setState(new CircleState(_context));
        this.context = _context;

        createInterface();
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
        menu.mousePressed(context, this);

        if(menu.isOver(context.mouse)){
            return;
        }

        listElements.mousePressed(context, this);

        if(listElements.isOver(context.mouse)){
            return;
        }

        // Seleciona o segmento em questão se for o mouse LEFT
        PVector closestPoint = new PVector();
        PVector q = new PVector(context.mouse.x, context.mouse.y);
        int selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
        //int closestControlPointIndex  = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));
        PVector closestControlPoint = context.curve.getControlPoint(selectedSegment);

        float distance = q.dist(closestPoint);

        if(distance < 10 && !(myState instanceof OverSketchState) && !(myState instanceof EditingState)){
          myState = new EditingState(this.context);
        }

        if(selectedSegment == context.curve.getNumberControlPoints() - 2 && distance < 10){
            myState = new DrawningState(this.context);
        }

        myState.mousePressed();
    }
    void mouseDragged()
    {
        if(menu.isOver(context.mouse)){
            return;
        }

        myState.mouseDragged();
    }
    void mouseReleased()
    {
        if(menu.isOver(context.mouse)){
            return;
        }

        myState.mouseReleased();
    }

    void keyPressed(){
        switch (context.key){
            case 'd' :
              this.debug();
            break;  

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
        //if (context.curve.getNumberControlPoints() >=4) 
        //    context.curve.draw();
        
        myState.draw();

        if(context.isPlayed()){
            float lastTime = context.lastTime();
            float t = frameCount%int(lastTime);

            context.draw(t);
        }else{
            context.draw(0.0);
        }

        drawInterface();
        updateInterface();
    }

    void drawInterface()
    {
        menu.draw();
        listElements.draw();
        myState.drawInterface();
    }

    void updateInterface(){
        listElements = new VerticalMenu(new PVector(width - 150, 20));
        for (SceneElement o : context.sceneElements) {
            listElements.addElement(o);
        }
    }

    void createInterface()
    {   
        listElements = new VerticalMenu(new PVector(width - 150, 20));

        menu = new HorizontalMenu(new PVector(0,height - 100));
        menu.createButton(new Button("Play"){
            public void onMouseClick(){
                if(context.isPlayed())
                {
                    this.name = "Play";
                    context.stop();
                }
                else
                {
                    this.name = "Stop";
                    context.play(); 
                }

                return;
            }
        });

        menu.createButton(new Button("Clear"){
            public void onMouseClick(){
                context.curve.clear();
                //context.pos.clear();
                context.stop();
                stateContext.setState(new DrawningState(context));
                context.selectedSegments = new int[0];
            }
        });

        menu.createButton(new Button("OverSketch"){
            public void onMouseClick(){
                if(stateContext.myState instanceof OverSketchState){
                    stateContext.setState(new EditingState(context));
                    return;
                }

                stateContext.setState(new OverSketchState(context));
                context.selectedSegments = new int[0];
                }
        });

        menu.createButton(new Button("Edit"){
            public void onMouseClick(){

                if(!(stateContext.myState instanceof EditingState))
                {
                    stateContext.setState(new EditingState(context));
                    name = "Draw";
                }
                else
                {
                    stateContext.setState(new DrawningState(context));
                    name = "Edit";
                }
            }
        });

        menu.createButton(new Button("Text"){
            public void onMouseClick(){
                if(!(stateContext.myState instanceof FontState))
                    stateContext.setState(new FontState(context));
            }
        });

        menu.createButton(new Button("Circle"){
            public void onMouseClick(){
                if(!(stateContext.myState instanceof CircleState))
                    stateContext.setState(new CircleState(context));
            }
        });

        menu.updatePositions();
    }
}