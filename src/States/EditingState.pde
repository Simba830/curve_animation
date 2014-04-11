class EditingState extends State {

    int cpsMovimenteds = 5;

    PVector originalPositionDragged;
    
    EditingState(Context context){
      super(context);
    }

    public void mousePressed() 
    {
        if(context.mouseButton == RIGHT){

            // Verfica se tem nenhum element selecionado
            if(context.selectedSegments.length == 0)
            {
              // Create a variable for the closestpoint
              PVector closestPoint = new PVector();

              //Vector that
              PVector q = new PVector(context.mouse.x, context.mouse.y);

              // Context finde the closest point gives the selectedSegment
              int selectedSegment = context.curve.findClosestPoint(context.curve.controlPoints, q, closestPoint);

              float distance = q.dist(closestPoint);
              if (distance < distanceToSelect)
              {
               context.selectedSegments = new int[1];
               context.selectedSegments[0] = selectedSegment;
              }
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
        PVector closestPoint = new PVector();
        PVector q = new PVector(context.mouse.x, context.mouse.y,0);
        int selectedSegment = context.curve.findClosestPoint (context.curve.controlPoints, q, closestPoint);
        //int closestControlPointIndex  = context.curve.findControlPoint(new PVector(context.mouse.x, context.mouse.y));
        PVector closestControlPoint = context.curve.getControlPoint(selectedSegment);

        float distanceControlPoint = q.dist(closestControlPoint);
        float distance = q.dist(closestPoint);

        // Verifica se a distancia é maior do que o limite para selecionar
        if(distance > distanceToSelect)
        {
              context.diselect();
              this.context.selectedSegments = new int[0];
        }
        else
        {
          boolean selected = false;
          
          for (int i = 0; i<context.selectedSegments.length; i++){
            if(selectedSegment == context.selectedSegments[i]){
              selected = true;
              selectedSegment = i;
              break;
            }
          }

          if(!selected){
            context.selectedSegments = new int[1];
            context.selectedSegments[0] = selectedSegment;
            float myTime = context.curve.getControlPoint(selectedSegment).z;
            context.alignTimes(myTime);
            selectedSegment = 0;
          }

          println("distanceControlPoint: "+distanceControlPoint);
          if(distanceControlPoint > 50){
              //PVector d1 = context.curve.getControlPoint(selectedSegment);
              //context.curve.insertPoint(q, context.selectedSegments[selectedSegment]);
              // context.selectedSegments[selectedSegment]++;
          }
        }  
      }
    }

    public void mouseReleased() 
    {
        if(context.selectedSegments.length == 0)
        {
            context.selectedSegments = context.curve.getControlPointsBetween(context.mouseInit, context.mouseFinal);
        }

        context.refreshInterpolator();
    }

    public void mouseDragged()
    {
        context.stop();

        if (context.mouseButton == LEFT)
        {
          // Se tiver selecionado vários mantém a mesma movimentação
          if (context.selectedSegments.length > 1)
          {
            // Pega a variação de x e de y
            float dx = context.mouse.x - context.pMouse.x;
            float dy = context.mouse.y - context.pMouse.y;

            // Soma aos elementos selecionados
            for (int i = 0; i<context.selectedSegments.length; i++){
              PVector controlPoint = context.curve.getControlPoint(context.selectedSegments[i]);
              context.curve.setPoint(new PVector(controlPoint.x + dx, controlPoint.y + dy, controlPoint.z), context.selectedSegments[i]);
            }
          }else if(context.selectedSegments.length == 1){

            // Pega a variação de x e de y
            float dx = context.mouse.x - context.pMouse.x;
            float dy = context.mouse.y - context.pMouse.y;

            // Soma aos elementos selecionados
            for (int i = -this.cpsMovimenteds; i< this.cpsMovimenteds; i++){
              float tdx;
              float tdy;
              if( i != 0){
                tdx = dx/(5*abs(i));
                tdy = dy/(5*abs(i));
              }else{
                tdx = dx;
                tdy = dy;
              }

              PVector controlPoint = context.curve.getControlPoint(context.selectedSegments[0] + i);
              context.curve.setPoint(new PVector(controlPoint.x + tdx, controlPoint.y + tdy, controlPoint.z), context.selectedSegments[0] + i);
            }

          }
        }

        context.refreshInterpolator();
    }

    public void keyPressed(){
      if(context.selectedSegments.length != 0){
        for (int i = context.selectedSegments.length - 1; i>=0; i--){
          context.curve.removeElement(context.selectedSegments[i]);
        }

        context.diselect();  
      }
    }

    public void draw()
    {
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

        // Draw control points if have a curve;
        context.curve.drawControlPoints();
        
    }

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