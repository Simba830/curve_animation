public class StateContext {

    private interfaceState myState;
        /**
         * Standard constructor
         */
    StateContext() 
    {
        setState(new DrawningState());
    }
 
    /**
     * Setter method for the state.
     * Normally only called by classes implementing the State interface.
     * 
     * Devemos criar um método setState pra cada Estado
     * @param NEW_STATE
     */
    public void setState(final interfaceState NEW_STATE) {
        myState = NEW_STATE;
    }
 
    /**
     * Mouse Actions Methods
     * @param  PVector mouse
     */
    void mousePressed(PVector mouse)
    {
        myState.mousePressed(mouse);
    }
    void mouseDragged(PVector mouse, PVector pmouse)
    {
        myState.mouseDragged(mouse, pmouse);
    }
    void mouseReleased(PVector mouse)
    {
        myState.mouseReleased(mouse);
    }
    void draw()
    {
        background (255);
        noFill();
        if (curve.getNumberControlPoints() >=4) 
            curve.draw();
        myState.draw();
    }
    void drawInterface()
    {
        myState.drawInterface();
    }
}