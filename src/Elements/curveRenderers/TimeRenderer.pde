class TimeRenderer extends Renderer{
  private boolean wasEdited;
  private ArrayList<float> speeds;
  private ArrayList<float> speeds;
  private float minSpeed;
  private float maxSpeed;

  private float minDistance = 5;
  private color strokeColor = color(0);
  private float controlPointAlpha = 200;
  private float curveWeight = 5;

  private SmoothPositionInterpolator interpolator;

  private ArrayList<PVector> vertexs;

  TimeRenderer(){
    vertexs = new ArrayList<PVector>();
    speeds = new ArrayList<Float>();
    interpolator = new SmoothPositionInterpolator(new SmoothInterpolator());
  }

  void render(){
    color from = color(#07123A);
    color to = color(#7A86AD);

    if(vertexs.size() >= 4){
      beginShape(QUAD_STRIP);
      strokeCap(ROUND);
      strokeJoin(ROUND);

      for (int i = 0; i < vertexs.size() - 1; i++) {
        if(i % 4 == 0){
          float p = norm( speeds.get( (int) (i / 4) ) , minSpeed, maxSpeed);
          p = abs(p);
          fill(lerpColor(from, to, p));
          stroke(lerpColor(from, to, p));
        }

        PVector vi = vertexs.get(i);

        vertex(vi.x, vi.y);
      }
      
      endShape();
    }
  }

  void update(ArrayList<Property> properties){
    maxSpeed = 0;
    minSpeed = 9999;

    // Updating the inpolator
    for (int i = 0; i< properties.size(); i++){
      p = properties.get(i);

      interpolator.set(p.getT(), new PVector(p.getX(), p.getY()));
    }

    vertexs = new ArrayList<PVector>();
    speeds = new ArrayList<PVector>();

    for (int i = 0; i < properties.size() - 1; i++) {
      Property p = properties.get(i);
      Segment seg = getSegment(properties,i);

      float segmentlength = seg.b.dist(seg.c)/2; 

      for (int j=0; j<=segmentlength; j++) 
      {
        float t = (float)(j) / (float)(segmentlength);
        float x = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
        float y = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
        float t1 = p.getT() + t;

        t = (float)(j+1) / (float)(segmentlength);
        float x2 = curvePoint(seg.a.get(0), seg.b.get(0), seg.c.get(0), seg.d.get(0), t);
        float y2 = curvePoint(seg.a.get(1), seg.b.get(1), seg.c.get(1), seg.d.get(1), t);
        float t2 = p.getT() + t;

        PVector bP = PVector.sub(new PVector(x2,y2), new PVector(x,y));
        PVector ortogonal1 = new PVector(-bP.y, bP.x);
        float speed = (bP.mag())/(t2 - t1);
        speeds.add(speed);

        if(speed > maxSpeed){
          maxSpeed = speed;
        }

        if(speed < minSpeed){
          minSpeed = speed;
        }

        ortogonal1.normalize();

        ortogonal1.mult(curveWeight);
        
        //  strokeWeight()
        vertexs.add(new PVector(x + ortogonal1.x, y + ortogonal1.y));
        vertexs.add(new PVector(x - ortogonal1.x, y - ortogonal1.y));
        vertexs.add(new PVector(x2 + ortogonal1.x, y2 + ortogonal1.y));
        vertexs.add(new PVector(x2 - ortogonal1.x, y2 - ortogonal1.y));
      }
      
    }
  }
}