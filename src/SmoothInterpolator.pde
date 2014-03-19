// Smooth (Cubic) interpolation of properties
class SmoothInterpolator extends Interpolator {

  // Gets the Catmull-Rom interpolated property for time t 
  Property get(float t) {
    int i = locateTime(t);
    if (i >= 0) {
      if (time.get(i) == t) return prop.get(i);
      if (i+1 < time.size()) {
        // Compute the 4 points that will be used
        // to interpolate the property 
        Property a,b,c,d;
        a = b = new Property( prop.get(i)[0], prop.get(i)[1], prop.get(i)[2]); 
        c = d = (Property) new Property( prop.get(i + 1)[0], prop.get(i + 1)[1], prop.get(i + 1)[2]); 
        if (i > 0) a = new Property( prop.get(i - 1)[0], prop.get(i - 1)[1], prop.get(i - 1)[2]) ; 
        if (i+2 < time.size()) d = new Property( prop.get(i + 2)[0], prop.get(i + 2)[1], prop.get(i + 2)[2]);
        // Interpolate the parameter
        float s = norm (t, time.get(i), time.get(i+1)); 
        // Now interpolate the property dimensions
        Property p = new Property(); 
        int n = max (a.size(), b.size());
        for (int k = 0; k < n; k++) {
          p.set(k, curvePoint(a.get(k), b.get(k), c.get(k), d.get(k), s));
        }
        return p;
      }
      else return prop.get(i);
    }
    else {
      my_assert (time.size() > 0);
      return prop.get(0);
    }
  }

};

