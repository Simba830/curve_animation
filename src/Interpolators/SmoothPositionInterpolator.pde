// Wraps a interpolator class so that 
// methods return PVectors representing positions rather 
// than generic properties
class SmoothPositionInterpolator {
  
  // The interpolator being wrapped
  Interpolator interp;
  
  // Constructor
  SmoothPositionInterpolator (interpolator interp) {
    this.interp = interp;
  }

  // Converts a property to a PVector
  PVector toPVector (Property p) {
    return new PVector(p.get(0), p.get(1), p.get(2));
  }
  
  // Returns the number of keyframes
  int nKeys () {
    return interp.time.size();
  }

  // Return the time for keyframe i
  float keyTime(int i) {
    return interp.time.get(i);
  }

  // Return the property for keyframe i
  PVector keyPos (int i) {
    return toPVector(interp.prop.get(i));
  }

  // Sets the position for time t
  void set (float t, PVector p) { 
    interp.set(t, new Property (p.x, p.y, p.z));
  }
  
  // Gets the position at time t
  PVector get (float t) {
    return toPVector (interp.get(t));
  }
  
  // Returns the estimated tangent (a unit vector) at point t
  PVector getTangent (float t) {
    PVector tan = (t < 0.01) ?
                   PVector.sub(get(t+0.01),get(t)) :
                   PVector.sub(get(t),get(t-0.01));
    tan.normalize();
    return tan;
  }
  
  // Draws key frames as circles and the curve 
  // as n segments equally spaced in time
  void draw(int n) {
    pushStyle();
    noFill();
    float tickSize = 5;
    float tMax = keyTime(nKeys()-1);
    PVector p0 = get(0);
    for (int i = 0; i < n; i++) {
      float t = (float) i * tMax / (n-1);
      PVector p = get(t);
      PVector tan = getTangent(t);
      tan.mult(tickSize);
      line(p0.x,p0.y,p.x,p.y);
      line(p.x-tan.y, p.y+tan.x,p.x+tan.y, p.y-tan.x);
      p0 = p;
    }
    popStyle();
    for (int i = 0; i < interp.nKeys(); i++) {
      Property p = interp.keyProp(i);
      ellipse(p.get(0), p.get(1), 10, 10);
    }
  }

  void clear(){
    interp.clear();
  }
}

