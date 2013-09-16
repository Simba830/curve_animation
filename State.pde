class State
{
	Context context;
    // Constants
    final float distanceToSelect = 5;

     // Variaveis de Curvas
    int selectedSegment;
    PVector closestPoint;
    PVector q;


	State(Context _context){
		context = _context;
	}

	State(){
		context = new Context();
  	}

	void mousePressed(){

	};
	void mouseDragged(){

	};
	void mouseReleased(){
		while(curve.canBeDecimed()){
		    curve.decimeCurve(context.tolerance);
		}
	};
	void keyPressed(){

	};
	void draw(){};
	void drawInterface(){};
}
	