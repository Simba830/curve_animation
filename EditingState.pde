class EditingState extends State {
    

    EditingState(Context context){
      super(context);

    }

    public void mousePressed() 
    {
        if(context.mouseButton == RIGHT){

            // Verfica se tem nenhum element selecionado
            if(context.selectedSegments.length == 0)
            {

              // Então seleciona o mais próximo
              PVector closestPoint = new PVector();
              PVector q = new PVector(context.mouse.x, context.mouse.y);
              int selectedSegment = context.curve.findClosestPoint(context.curve.controlPoints, q, closestPoint);
              float distance = q.dist(closestPoint);

              context.selectedSegments = new int[1];
              context.selectedSegments[0] = selectedSegment;
            }

            // Remove todos os segmentos selecionados
            for (int i = context.selectedSegments.length - 1; i>=0; i--){
              context.curve.removeElement(context.selectedSegments[i]);
            }

            // Remove a seleção
            context.diselect();
      }
      else
      {

        // Seleciona o segmento em questão se for o mouse LEFT
        int selectedSegment = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));

        PVector closestPoint = new PVector();
        PVector q = new PVector(context.mouse.x, context.mouse.y);
        selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
        float distance = q.dist(closestPoint);

        boolean selected = false;
        // Se o segmento mais próximo já estiver selecionado saí da função

        if(distance > distanceToSelect){
              context.diselect();
        }else{
          for (int i = 0; i<context.selectedSegments.length; i++){
            if(selectedSegment == context.selectedSegments[i]){
              selected = true;
              selectedSegment = i;
            }
          }
        }

        if(!selected){
          context.selectedSegments = new int[1];
          context.selectedSegments[0] = selectedSegment;
          selectedSegment = 0;
        }

        if (mouseEvent.getClickCount()==2){
          context.curve.insertPoint(q, context.selectedSegments[selectedSegment] + 1);

          context.selectedSegments[selectedSegment]++;

          mouseInit.set(0, 0);
          mouseFinal.set(0, 0);

        }else if(distance > this.distanceToSelect){
          context.diselect();
        } 
      }

    }
    @Override
    public void mouseReleased() 
    {
        if(context.selectedSegments.length == 0)
        {
            context.selectedSegments = context.curve.getControlPointsBetween(context.mouseInit, context.mouseFinal);
        }
    }
    @Override
    public void mouseDragged()
    {
        if (context.mouseButton == LEFT)
        {

          if (context.selectedSegments.length != 0)
          {
            // Pega a variação de x e de y
            float dx = context.mouse.x - context.pMouse.x;
            float dy = context.mouse.y - context.pMouse.y;

            // Soma aos elementos selecionados
            for (int i = 0; i<context.selectedSegments.length; i++){
              PVector controlPoint = context.curve.getControlPoint(context.selectedSegments[i]);
              context.curve.setPoint(new PVector(controlPoint.x + dx, controlPoint.y + dy), context.selectedSegments[i]);
            }
          }
        }
    }

    public void keyPressed(){
      if(context.selectedSegments.length != 0){
        for (int i = context.selectedSegments.length - 1; i>=0; i--){
          context.curve.removeElement(context.selectedSegments[i]);
        }

        context.diselect();  
      }
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