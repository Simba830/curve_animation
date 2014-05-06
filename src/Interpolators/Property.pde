// A property is an array of floats representing a
// multidimensional point
class Property {
  
  ArrayList<Float> prop = new ArrayList<Float>();
  
  // An empty property
  Property() {
  }

  // Make sure this property has room for storing n floats
  void setDimension (int n) {
    while (size() < n) add(0.0);
  }

  // Returns the number of floats defined for the property
  int size() {
    return prop.size();
  }
  
  // Adds another float to the property
  void add (Float f) {
    prop.add(f);
  }
  
  // A one-float property
  Property (float a) {
    super();
    setDimension (1);
    set (0,a);
  }

  // A two-float property
  Property (float a, float b) {
    super();
    setDimension (2);
    set (0,a);
    set (1,b);
  }

  // A three-float property
  Property (float a, float b, float c) {
    super();
    setDimension (3);
    set (0,a);
    set (1,b);
    set (2,c);
  }

  // Sets the i'th dimension of the property
  // to value v
  void set(int i, float v) {
     my_assert(i>=0);
     while (i >= size()) add(0.0);
     prop.set(i,v);
  }

  // Returns the i'th dimension of the property.
  // Returns 0.0 if that dimension was never set
  Float get(int i) {
    my_assert (i>=0);
    if (i >= size()) return 0.0;
    return prop.get(i);
  }

  Property sub(Property operand){
    if( this.size() != operand.size())
      throw new Exception("Property with diferents dimensions.");

    Property result = new Property();
    result.setDimension(this.size());
    for (int i = 0; i < this.size(); ++i) {
      result.set(i, this.get(i) - operand.get(i));
    }

    return result;
  }

  float mag(){
    float result = 0;
    for (int i = 0; i < this.size(); ++i) {
      result += pow(get(i), 2);
    }

    return sqrt(result);
  }

  Property add(Property operand){
    if( this.size() != operand.size())
      throw new Exception("Property with diferents dimensions.");

    Property result = new Property();
    result.setDimension(this.size());
    for (int i = 0; i < this.size(); ++i) {
      result.set(i, this.get(i) + operand.get(i));
    }

    return result;
  }

  void mult(float constant){
    for (int i = 0; i < this.size(); ++i) {
      this.set(i, this.get(i)*constant);
    }
  }

  void clone(){
    Property result = new Property();
    result.setDimension(this.size());
    for (int i = 0; i < this.size(); ++i) {
      result.set(i, this.get(i));
    }

    return result;
  }

  float dist(Property operand){
    return (operand.sub(this)).mag();
  }


};

