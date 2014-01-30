class Text extends SceneElement{
	PFont font;
	String text;
	color c;

	Text(String fontName, float size, PVector _position, String text, color c)
	{
		super(_position);
		font = this.loadFont(fontName, size);
		this.text = text;
		this.c = c;
	}

	void draw()
	{
		/*pushMatrix();
			fill(this.c);
			textFont(font);
			text(text, position.x, position.y);
		popMatrix();*/
	}

	private PFont loadFont(String fontName, float size)
	{
		return createFont(fontName, size);
	}

	void setText(String _text)
	{
		this.text = _text;
	}

	String getText()
	{
		return this.text;
	}
}