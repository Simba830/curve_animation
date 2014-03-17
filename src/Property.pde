// A property is an array of floats representing a
// multidimensional point
class Property extends ArrayList<Float> {
  
  // An empty property
  Property() {
    super();
  }

  // A one-float property
  Property (float a) {
    super();
    set (0,a);
  }

  // A two-float property
  Property (float a, float b) {
    super();
    set (0,a);
    set (1,b);
  }

  // A three-float property
  Property (float a, float b, float c) {
    super();
    set (0,a);
    set (1,b);
    set (2,c);
  }

  // Sets the i'th dimension of the property
  // to value v
  void set(int i, float v) {
    if(i < 0)  
    {
         println("Error: Property->get->i < 0");
         super.add(0.0);
    }
     while (i >= size()) add(0.0);
     super.set(i,v);
  }

  // Returns the i'th dimension of the property.
  // Returns 0.0 if that dimension was never set
  Float get(int i) {
    if (i<0)
    {
         println("Error: Property->get->i < 0");
         return 0.0;
    }
    if (i >= size()) return 0.0;
    
    return super.get(i);
  }
};
