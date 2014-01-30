class VerticalMenu{
	ArrayList<Button> buttons;
	ArrayList<SceneElement> elements;
	PVector pos;
	float spacing;
	color menuColor;
	float myWidth, myHeight;

	VerticalMenu(PVector pos){
		this.pos = pos;
		spacing = 15;
		menuColor = #03426A;
		this.myWidth = 100;
		this.myHeight = 500;
		buttons = new ArrayList<Button>();
		elements = new ArrayList<SceneElement>();
	}

	void addElement(SceneElement element){
		elements.add(element);
		Button b = new Button(element.name){
			public void onMouseClick(){
				println("test");
			}
		};

		b.width = 100;
		b.height = 25;
		buttons.add(b);
	}

	void updatePositions()
	{
		int i = 0;
		for (Button o : buttons) {
			o.setPosition(new PVector( (pos.x + spacing) + i*(o.getWidth()/2 + spacing), pos.y + myHeight/2));
			i++;
		}
	}

	void draw()
	{
		stroke(menuColor);
		fill(menuColor);
		rect(pos.x,pos.y,this.myWidth, this.myHeight);

		fill(255);
		int i = 0;
		for (Button o : buttons) {
			o.draw(new PVector( pos.x + myWidth/2, (pos.y + spacing) + i*(o.getHeight()/2 + spacing)));
			i++;
		}
	}

	void mousePressed(Context context, StateContext stateContext)
	{
		for (Button o : buttons) {
			if(Utils.mouseOverRect(new PVector(context.mouse.x, context.mouse.y), 
								(int)(o.pos.x - o.getWidth()/2), 
								(int)(o.pos.y - o.getHeight()/2), 
								(int)(o.pos.x + o.getWidth()/2), 
								(int)(o.pos.y + o.getHeight()/2) ))
			{
				o.onMouseClick();
				return;
			}
		}
	}

	boolean isOver(PVector mouse)
	{
		if(Utils.mouseOverRect(new PVector(mouse.x, mouse.y), 
								(int)(pos.x), 
								(int)(pos.y), 
								(int)(myWidth), 
								(int)(myHeight) ))
			{
				return true;
			}
		return false;
	}
}