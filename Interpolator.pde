// Linearly interpolates properties for a specific
// time, given values of these properties at 
// known times (keyframes)
class Interpolator {
  ArrayList<Float> time;
  ArrayList<Property> prop;
 
  // Constructor
  Interpolator() {
    time = new ArrayList<Float>();
    prop = new ArrayList<Property>();
  }
  
  // Returns the number of keyframes
  int nKeys () {
    return time.size();
  }

  // Return the time for keyframe i
  float keyTime(int i) {
    return time.get(i);
  }

  // Return the property for keyframe i
  Property keyProp (int i) {
    return prop.get(i);
  }

  // Returns the greatest index of time which contains a 
  // value smaller or equal to t. If no such value exists, 
  // returns -1.
  int locateTime(float t) {
    int i = -1;
    while (i+1 < time.size() && time.get(i+1) <= t) i++;
    return i;
  }

  // Sets the property p for time t
  void set (float t, Property p) {
    int i = locateTime(t);
    if (i >=0 && time.get(i) == t) {
      prop.set(i,p);
    }
    else {
      time.add(i+1,t);
      prop.add(i+1,p);
    }
  }

  // Gets the (linearly) interpolated property for time t 
  Property get(float t) {
    int i = locateTime(t);
    if (i >=0) {
      if (time.get(i) == t) {
        return prop.get(i);
      }
      else if (i+1 < time.size()) {
        float s = norm (t, time.get(i), time.get(i+1));
        Property p = new Property(), a = prop.get(i), b = prop.get(i+1);
        int n = max (a.size(), b.size());
        for (int k = 0; k < n; k++) {
          p.set(k, lerp(a.get(k), b.get(k), s));
        }
        return p;
      }
      else return prop.get(i);
    }
    else {
      if (time.size() > 0)
        println("Returned error because Time.size() <= 0");
      
      return prop.get(0);
    }
  }

  void clear(){
    time = new ArrayList<Float>();
    prop = new ArrayList<Property>();    
  }
};

