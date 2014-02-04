class SceneElement
{
	String name;
	SmoothPositionInterpolator pos;
	color c, curveColor;
	CurveCat curve;

	SceneElement(PVector position)
	{
		c = color(0,0,0);
		curveColor = color(100,100,100);
		name = "Element";
		pos = new SmoothPositionInterpolator();
		pos.set(0, position);

		this.curve = new CurveCat();
		this.curve.setTolerance(5);
	}

	void draw(){}
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