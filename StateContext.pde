public class StateContext {

    private State myState;
    private Context context;
    private boolean debug;
    private Menu menu;

        /**
         * Standard constructor
         */
    StateContext(Context _context) 
    {
        debug = false;
        setState(new DrawningState(_context));

        menu = new Menu(new PVector(0,height - 100));
        menu.createButton(new Button("Play"){
            void onMouseClick(){
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
            void onMouseClick(){
                context.curve.clear();
                context.pos.clear();
                context.stop();
                stateContext.setState(new DrawningState(context));
                context.selectedSegments = new int[0];
            }
        });

        menu.createButton(new Button("OverSketch"){
            void onMouseClick(){
                if(stateContext.myState instanceof OverSketchState){
                    stateContext.setState(new EditingState(context));
                    return;
                }

                stateContext.setState(new OverSketchState(context));
                context.selectedSegments = new int[0];
                }
        });

        menu.createButton(new Button("Edit"){
            void onMouseClick(){
                if(!(stateContext.myState instanceof EditingState))
                    stateContext.setState(new EditingState(context));
            }
        });

        menu.createButton(new Button("Text"){
            void onMouseClick(){
                if(!(stateContext.myState instanceof FontState))
                    stateContext.setState(new FontState(context));
            }
        });

        menu.updatePositions();
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
        if (context.curve.getNumberControlPoints() >=4) 
            context.curve.draw();
        
        myState.draw();

        if(context.isPlayed()){
            float lastTime = context.pos.keyTime(context.pos.nKeys()-1);
            float t = frameCount%int(lastTime);

            // Essa parte faria parar no final da animação
            // if(t == 0)
            //     context.stop();
            
            PVector p = context.pos.get(t);

            PVector tan = context.pos.getTangent(t);
            stroke(100,100,100);
            context.pos.draw (100);
            float ang = atan2(tan.y,tan.x);

            pushMatrix();
            translate (p.x,p.y);
            rotate (ang);
            noStroke();
            fill(mainColor);
            ellipse(0,0, 20, 20);
            popMatrix();
        }
    }

    void drawInterface()
    {
        menu.draw();
        myState.drawInterface();

        if(debug){
          fill(255,0,0);
          stroke(255,0,0);
          text("Curve Length:"+context.curve.curveLength()+" px", 10, height-20);
          text("Curve Tightness:"+curveT, 10, 20);
          text("Tolerance:"+context.curve.tolerance, 10, 40);
        }
    }
}