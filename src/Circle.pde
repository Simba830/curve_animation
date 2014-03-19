class Circle extends SceneElement{

	float width, height;
	boolean active;

	Circle(float _width, float _height)
	{
		super(context.mouse);
		this.name = "Circle";
		this.width = _width;
		this.height = _height;
		active = true;
	}

	void draw(float t)
	{
		if(pos.nKeys() < 1){
			return;
		}

		if(t >= pos.keyTime(pos.nKeys()-1)){
			t = pos.keyTime(pos.nKeys()-1);
		}

		Property position;
		if(!active){
			position = pos.interp.get(0);
		}else{
			position = pos.interp.get(t);
		}

		fill(c);
		stroke(0);
		ellipse(position.x, position.y, this.width, this.height);
	}

	void setWidth(float x){
		this.width = x;
	}

	void setHeight(float x){
		this.height = x;
	}

	float lastTime()
	{
		if(pos.nKeys() < 1)
			return 0;

		return pos.interp.time.get(pos.nKeys()-1);
	}

	boolean isOver(PVector mouse){
                PVector position = pos.interp.get(0);
                float radious = this.width;
		return (mouse.x - position.x)*(mouse.x - position.x) + (mouse.y - position.y)*(mouse.y - position.y) <= radious;
	}
}
