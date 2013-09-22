class OverSketchState extends EditingState {

    OverSketchState(Context context){
      super(context);
    }

    public void mousePressed() 
    {
        

    }

    @Override
    public void mouseReleased() 
    {

    }

    @Override
    public void mouseDragged()
    {

    }

    public void keyPressed(){

    }

    @Override
    public void draw()
    {
        context.curve.drawControlPoints();
        if(context.selectedSegments.length == 0)
        {
            // Desenha caixa de seleção com Alpha 50
            fill(mainColor, 50);
            stroke(mainColor, 50);
            rect(context.mouseInit.x, 
              context.mouseInit.y, 
              context.mouseFinal.x - context.mouseInit.x, 
              context.mouseFinal.y - context.mouseInit.y);
        }

        // Draw control points;
        if(context.selectedSegments.length > 0)
        {
            for (int i = 0; i<context.selectedSegments.length; i++)
            {
                context.curve.drawControlPoint(context.selectedSegments[i]);
            }
        }
    }
    @Override
    public void drawInterface()
    {
        int posX = width-80;
        int posY = height-20;

        fill(secondaryColor);
        stroke(secondaryColor);
        rect(posX-10,posY-20,80,30);
        fill(255);
        text("Editing", posX, posY);
    }
 
}