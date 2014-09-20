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
			PVector tangent = pos.getTangent(0);
		}else{
			position = pos.get(t);
			PVector tangent = pos.getTangent(t);
		}


		pushMatrix();

		rectMode(CENTER);

		fill(c);
		noStroke();
		smooth(8);
		translate(position.x, position.y, 0);
		rotate(-atan2(tangent.x, tangent.y));
		rect(0, 0, this.width, this.height);
		
		popMatrix();
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
