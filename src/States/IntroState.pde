class IntroState extends State
{
	PImage introImage;
	float currentAlpha;
	CurveCat introCurve;

	IntroState(Context _context){
		context = _context;
		currentAlpha = 255;
		// introImage = loadImage("intro.jpg");
		introCurve = new CurveCat();
	}

	void mousePressed(){
	};
	void mouseDragged(){

	};
	void mouseReleased(){
		context.curve.decimeAll();
	};

	void keyPressed(){

	};
	void draw(){
		pushMatrix();
		fill(0,currentAlpha);
		translate(width/2, height/2);
		textSize(50);
		textAlign(CENTER);
		text("CURVE ANIMATION", 0, 0);
		text("LCG - 2014", 0, 50);
		currentAlpha -= 1;
		popMatrix();
	};
}
	