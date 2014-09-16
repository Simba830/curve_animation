class Renderer{
  ArrayList<PVector> vertexs;

  void calculateVertexs(){};
  void render(){};

  Segment getSegment(ArrayList<Property> pAux, int i)
  { 
         Property a = i >= 1 ? pAux.get(i-1) : pAux.get(0);
         Property b = pAux.get(i);
         Property c = pAux.get(i+1);
         Property d = i+2 < pAux.size() ? pAux.get(i+2) : pAux.get(i+1);
         return new Segment(a,b,c,d);
  }

  Segment getSegment(int i)
  { 
         return getSegment(controlPoints,i);
  }
}