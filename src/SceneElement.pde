class SceneElement
{
	String name;
	SmoothPositionInterpolator pos;
	color c, curveColor;
	CurveCat curve;

	SceneElement(PVector position)
	{
		console.log("SceneElement construct");
		c = color(0,0,0);
		curveColor = color(100,100,100);
		name = "Element";
		pos = new SmoothPositionInterpolator();
		pos.interp.set(0,position);

		console.log("Pos working!");
		this.curve = new CurveCat();
		this.curve.setTolerance(15);
	}

	void draw(float t){}
	void drawCurve(){
		curve.strokeColor = curveColor;
		noFill();
		if(curve.getNumberControlPoints() >= 4)
			this.curve.draw();


		stroke(0);
	}
	void load(){}
	void update(){}
	float lastTime(){
		return pos.keyTime(pos.nKeys()-1);
	}

	boolean isOver(PVector mouse){
		return true;
	}
}
