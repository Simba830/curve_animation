class Square extends SceneElement{

	float width, height;
	boolean active;

	Square(float _width, float _height)
	{
		super(context.mouse);
		this.name = "Square";
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

		PVector position;
		if(!active){
			position = pos.get(0);
		}else{
			position = pos.get(t);
		}

		rectMode(CENTER);
		fill(c);
		stroke(0);
		rect(position.x, position.y, this.width, this.height);

		fill(0);
		stroke(0);
		point(position.x, position.y);
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
                PVector position = pos.get(0);
                float radious = this.width;
		return (mouse.x - position.x)*(mouse.x - position.x) + (mouse.y - position.y)*(mouse.y - position.y) <= radious*radious;
	}
}
