class Menu{
	ArrayList<Button> buttons;
	PVector pos;
	float spacing;
	color menuColor;
	float myWidth, myHeight;

	Menu(PVector pos){
		this.pos = pos;
		spacing = 50;
		menuColor = #03426A;
		this.myWidth = width;
		this.myHeight = 100;
		buttons = new ArrayList<Button>();
	}

	void createButton(String name){
		Button newButton = new Button(name);
		buttons.add(newButton);
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
			o.draw(new PVector( (pos.x + spacing) + i*(o.getWidth()/2 + spacing), pos.y + myHeight/2));
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
			}
		}
	}
}