class Circle extends SceneElement{

	float width, height;
	boolean active;

	Circle(float _width, float _height)
	{
		super(context.mouse);
		this.width = _width;
		this.height = _height;
		active = false;
	}

	void draw(float t)
	{
		if(t >= pos.keyTime(pos.nKeys()-1)){
			t = pos.keyTime(pos.nKeys()-1);
		}

		PVector position;
		if(!active){
			position = pos.get(0);
		}else{
			position = pos.get(t);
		}

		fill(0);
		stroke(0);
		ellipse(position.x, position.y, this.width, this.height);
	}

	float lastTime()
	{
		return pos.keyTime(pos.nKeys()-1);
	}
}