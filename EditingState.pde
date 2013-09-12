class EditingState implements interfaceState {
    /* 
     * 
     */
    @Override
    public void mousePressed(PVector mouse) 
    {
        if(mouseButton == RIGHT){

            // Verfica se tem nenhum element selecionado
            if(selectedSegments.length == 0)
            {

              // Então seleciona o mais próximo
              closestPoint = new PVector();
              q = new PVector(mouseX, mouseY);
              selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
              distance = q.dist(closestPoint);

              selectedSegments = new int[1];
              selectedSegments[0] = selectedSegment;
            }

            // Remove todos os segmentos selecionados
            for (int i = selectedSegments.length - 1; i>=0; i--){
              curve.removeElement(selectedSegments[i]);
            }

            // Remove a seleção
            selectedSegments = new int[0];
      }
      else
      {

        // Seleciona o segmento em questão se for o mouse LEFT
        selectedSegment = curve.findControlPoint(new PVector(mouseX, mouseY));

        closestPoint = new PVector();
        q = new PVector(mouseX, mouseY);
        selectedSegment = curve.findClosestPoint (curve.controlPoints, q, closestPoint);
        distance = q.dist(closestPoint);

        boolean selected = false;
        // Se o segmento mais próximo já estiver selecionado saí da função

        if(distance > distanceToSelect){
              selectedSegments = new int[0];
        }else{
          for (int i = 0; i<selectedSegments.length; i++){
            if(selectedSegment == selectedSegments[i]){
              selected = true;
              selectedSegment = i;
            }
          }
        }

        if(!selected){
          selectedSegments = new int[1];
          selectedSegments[0] = selectedSegment;
          selectedSegment = 0;
        }

        if (mouseEvent.getClickCount()==2){
          curve.insertPoint(q, selectedSegments[selectedSegment] + 1);

          selectedSegments[selectedSegment]++;

          mouseInit.set(0, 0);
          mouseFinal.set(0, 0);

        }else if(distance > distanceToSelect){
          selectedSegments = new int[0];
        } 
      }

    }
    @Override
    public void mouseReleased(PVector mouse) 
    {
        if(selectedSegments.length == 0)
        {
            selectedSegments = curve.getControlPointsBetween(mouseInit, mouseFinal);
        }
    }
    @Override
    public void mouseDragged(PVector mouse, PVector pmouse)
    {
        if (mouseButton == LEFT)
        {

          if (selectedSegments.length != 0)
          {
            // Pega a variação de x e de y
            float dx = mouseX - pmouseX;
            float dy = mouseY - pmouseY;

            // Soma aos elementos selecionados
            for (int i = 0; i<selectedSegments.length; i++){
              PVector controlPoint = curve.getControlPoint(selectedSegments[i]);
              curve.setPoint(new PVector(controlPoint.x + dx, controlPoint.y + dy), selectedSegments[i]);
            }
          }
        }
    }
    @Override
    public void draw()
    {
        curve.drawControlPoints();
        if(selectedSegments.length == 0)
        {
            // Desenha caixa de seleção com Alpha 50
            fill(mainColor, 50);
            stroke(mainColor, 50);
            rect(mouseInit.x, mouseInit.y, mouseFinal.x - mouseInit.x, mouseFinal.y - mouseInit.y);
        }

        // Draw control points;
        if(selectedSegments.length > 0)
        {
            for (int i = 0; i<selectedSegments.length; i++)
            {
                curve.drawControlPoint(selectedSegments[i]);
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