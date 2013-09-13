class State
{
	Context context;

	State(Context _context){
		context = _context;
	}

	State(){
		context = new Context();
	}

	void mousePressed(){};
	void mouseDragged(){};
	void mouseReleased(){};
	void keyPressed(){};
	void draw(){};
	void drawInterface(){};
}
	