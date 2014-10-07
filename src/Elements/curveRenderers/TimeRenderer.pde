class TimeRenderer extends Renderer{
  private boolean wasEdited;
  private ArrayList<float> speeds;
  private ArrayList<float> widths;
  private float minSpeed;
  private float maxSpeed;

  private float minDistance = 5;
  private color strokeColor = color(0);
  private float curveWeight = 5;

  private ArrayList<PVector> vertexs;
  private ArrayList<PVector> points;
  private color from = color(#07123A);
  private color to = color(#9BCBEE);

  TimeRenderer(){
    vertexs = new ArrayList<PVector>();
    speeds = new ArrayList<Float>();
    widths = new ArrayList<Float>();
    maxSpeed = sqrt( (width*width) + (height*height) )/2;
    minSpeed = 0;
  }

  // Desenha a curva
  void render(){
    fill(0);
    noStroke();

    if(vertexs.size() >= 4){
      beginShape(QUAD_STRIP);
      smooth();
      // strokeCap(ROUND);
      // strokeJoin(ROUND);

      for (int i = 0; i < vertexs.size() - 1; i++) {
        if(i % 2 == 0){
          fill(vertexs.get(i).z, this.alphaValue);
        }

        vertex(vertexs.get(i).x, vertexs.get(i).y, 1);
      }
      
      endShape();
    }
  }

  // Calcula os vertexs com base nos pontos de controle da curva guardados em properties
  // Preenche o array vertexs da classe TimeRenderer
  void update(ArrayList<Property> properties){
    vertexs = new ArrayList<PVector>();
    speeds = new ArrayList<Float>();
    widths = new ArrayList<Float>();
    points = new ArrayList<PVector>();

    boolean first = true;

    for (int i = 0; i < properties.size() - 1; i++) {
      Property p = properties.get(i);
      Property pNext = properties.get(i + 1);
      Segment seg = getSegment(properties,i);

      float segmentlength = seg.b.dist(seg.c)/2; 

      for (int j=0; j<=segmentlength; j++) 
      {
        if(first){

          float t = 0;
          float t = (float)(j) / (float)(segmentlength);
          float x = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
          float y = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
          float t1 = p.getT() + t;
          PVector p1 = new PVector(x,y,t1);

          points.add(p1);

          t = (float)(j+1) / (float)(segmentlength);
          float x2 = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
          float y2 = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
          float t2 = p.getT() + t;
          PVector p2 = new PVector(x2,y2,t2);

          points.add(p2);

      }else{
        t = (float)(j+1) / (float)(segmentlength);
        float x2 = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
        float y2 = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
        float t2 = p.getT() + t;
        PVector p2 = new PVector(x2,y2,t2);

        points.add(p2);
      }

      PVector bP = PVector.sub( points.get(points.size() - 1), points.get(points.size() - 2));
      PVector ortogonal1 = new PVector(-bP.y, bP.x);
      float speed = ( bP.mag() )/(t2 - t1);
      speeds.add(speed);

      ortogonal1.normalize();

      float mySize = curvePoint(p.getSize(), p.getSize(), pNext.getSize(), pNext.getSize(), t);
      if(mySize > 0){
        ortogonal1.mult(5*(mySize));
      }else{
        ortogonal1.mult(0);
      }
      
      float parameter = norm( speed , minSpeed, maxSpeed);
      parameter = abs(parameter);
      color c = lerpColor(from, to, parameter)

      vertexs.add(new PVector(x + ortogonal1.x, y + ortogonal1.y, c));
      vertexs.add(new PVector(x - ortogonal1.x, y - ortogonal1.y, c));
      }
    }
  }
}