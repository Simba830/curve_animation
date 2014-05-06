class OverSketchState extends State {

    CurveCat aux;

    OverSketchState(Context context){
      super(context);
      this.aux = new CurveCat();
    }

    public void mousePressed() 
    {
        if(this.context.mouseButton == LEFT){
            // Seleciona o segmento em questão se for o mouse LEFT
            int selectedSegment = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));

            PVector closestPoint = new PVector();
            PVector q = new PVector(context.mouse.x, context.mouse.y);
            selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
            float distance = q.dist(closestPoint);

            if(distance > distanceToSelect){
                  context.diselect();
            }

            context.curve.insertPoint(q, selectedSegment + 1);
            selectedSegment++;

            context.selectedSegments = new int[1];
            context.selectedSegments[0] = selectedSegment;

            this.aux = new CurveCat();
            this.aux.strokeColor = color(0,0,0,50);

            for (int i = 0; i<selectedSegment; i++){
                q = context.curve.getControlPoint(i);
                this.aux.insertPoint(q, i);
            }

            mouseInit.set(0, 0);
            mouseFinal.set(0, 0);
        }
    }

    public void mouseReleased() 
    {
        if(this.aux.getNumberControlPoints() == 0){
            return;
        }
        int selectedSegment = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));

        PVector closestPoint = new PVector();
        PVector q = new PVector(context.mouse.x, context.mouse.y);
        selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
        float distance = q.dist(closestPoint);

        if(distance > distanceToSelect){
              context.diselect();
        }

        context.selectedSegments = new int[1];
        context.selectedSegments[0] = selectedSegment;

        context.curve.insertPoint(q, selectedSegment + 1);
        selectedSegment++;

        for (int i = selectedSegment; i<context.curve.getNumberControlPoints(); i++){
            q = context.curve.getControlPoint(i);
            this.aux.insertPoint(q, this.aux.getNumberControlPoints());
        }

        context.curve = null;
        context.curve = aux;

        context.curve.strokeColor = color(0);

        super.mouseReleased();
    }

    public void mouseDragged()
    {
        if(context.mouseButton == LEFT){
            this.aux.insertPoint(context.mouse, this.aux.getNumberControlPoints());
        }
    }

    public void keyPressed(){

    }

    public void draw()
    {
        if (this.aux.getNumberControlPoints() >=4) 
            this.aux.draw();

        //context.curve.drawControlPoints();
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
                //context.curve.drawControlPoint(context.selectedSegments[i]);
            }
        }
    }
}
