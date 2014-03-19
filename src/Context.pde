class Context{
	PVector mouse;
	PVector pMouse;
	int mouseButton;
	int keyCode;
	char key;
	CurveCat curve;
	PVector mouseInit;
	PVector mouseFinal;
	int[] selectedSegments;
	int mouseCount;
	boolean playing;
	ArrayList<SceneElement> sceneElements;
	SceneElement selectedElement;

	Context(){
		selectedSegments = new int[0];
		this.curve = new CurveCat();
		this.curve.setTolerance(7);

		playing = false;

		sceneElements = new ArrayList<SceneElement>();
		selectedElement = null;
	}

	void updateContext(PVector mouse, PVector pmouse, int _mouseButton, int keyCode, char key,
		PVector _mouseInit, PVector _mouseFinal){
		this.mouse = mouse;
		this.pMouse = pmouse;
		this.keyCode = keyCode;
		this.key = key;
		this.mouseButton = _mouseButton;
		this.mouseInit = _mouseInit;
		this.mouseFinal = _mouseFinal;
	}

	void setMouseCount(int _mouseCount){
		this.mouseCount = _mouseCount;
	}

	void setSelectionBox(PVector ini, PVector _final){
		this.mouseInit = ini;
		this.mouseFinal = _final;
	}

	void print(){
		println("Context[");
		println("this.mouse: "+this.mouse+",");
		println("this.pMouse: "+this.pMouse+",");
		println("this.keyCode: "+this.keyCode+",");
		println("this.key: "+this.key+",");
		Utils.print_r(selectedSegments);
		println("elements"+sceneElements);
	}

	void diselect(){
		this.selectedSegments = new int[0];
	}

	boolean isPlayed(){
		return playing;
	}

	void play(){
		frameCount = 0;

		playing = true;
		refreshInterpolator();
	}

	void togglePlay(){
		playing = !playing;

		frameCount = 0;
		refreshInterpolator();
	}

	void refreshInterpolator(){

		if(!this.isPlayed()){
			return;
		}

		PVector p;

		for (SceneElement o : sceneElements) {
			o.pos.clear();

			for (int i = 0; i< o.curve.getNumberControlPoints(); i++){
				p = o.curve.getControlPoint(i);

				o.pos.interp.set(p.z, p);
			}
		}

		play = true;
	}

	void stop(){
		playing = false;
	}

	void addElement(SceneElement e)
	{
		sceneElements.add(e);
	}

	void draw(float t){
		for (SceneElement o : sceneElements) {
			if(o == selectedElement){
				o.c = color(255,0,0);
				o.curveColor = color(0,0,0);
			}else{
				o.c = color(0,0,0);
				o.curveColor = color(200,200,200);
			}
			o.draw(t);
			o.drawCurve();
		}
	}

	float lastTime(){
		float lastTime = 0;
		float lastTimeElement = 0;
		for (SceneElement o : sceneElements) {
			lastTimeElement = o.lastTime();
			if(lastTimeElement > lastTime){
				lastTime = lastTimeElement;
			}
		}

		return lastTime;
	}

	void setSelectedElement(SceneElement element){
		selectedElement = null;
		selectedElement = element;
        if(selectedElement != null){
		  curve = selectedElement.curve;
        }
	}

	SceneElement getSelectedElement(){
		return selectedElement;
	}

	void deleteSelectedElement(){
		for (int i = 0; i < sceneElements.size(); ++i) {
			SceneElement o = sceneElements.get(i);
			if(o == selectedElement){
				sceneElements.remove(i);
				return;
			}
		}

		selectedElement = null;
		stateContext.setStateName("select");
	}
}
