class Button
{
	private String name;
	private float width, height;
	private color c, textColor;
	public PVector pos;
	Button(String name)
	{
		this.name = name;
		width = height = 50;

		c = #3E97D1;
		textColor = color(255);
	}

	void onMouseClick()
	{

	}

	void onMouseOver()
	{

	}

	void draw(PVector pos)
	{
		pushMatrix();
		rectMode(CENTER);
		fill(c);
		rect(pos.x,pos.y,width,height);

		textAlign(CENTER, CENTER);
		fill(textColor);
		text(name, pos.x, pos.y, width, height);

		rectMode(CORNER);
		popMatrix();
	}

	float getWidth()
	{
		return this.width;
	}

	float getHeight()
	{
		return this.height;
	}

	void setPosition(PVector pos)
	{
		this.pos = pos;
	}
}