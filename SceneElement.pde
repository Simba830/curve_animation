class SceneElement
{
	String name;
	SmoothPositionInterpolator pos;
	CurveCat curve;

	SceneElement(PVector position)
	{
		name = "Element";
		pos = new SmoothPositionInterpolator();
		pos.set(0, position);

		this.curve = new CurveCat();
		this.curve.setTolerance(7);
	}

	void draw(){}
	void draw(float t){}
	void load(){}
	void update(){}
	float lastTime(){
		return pos.keyTime(pos.nKeys()-1);
	}
}