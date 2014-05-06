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
	float time;

	Context(){
		selectedSegments = new int[0];
		this.curve = new CurveCat();
		this.curve.setTolerance(7);

		playing = false;
		t = 0;

		sceneElements = new ArrayList<SceneElement>();
		selectedElement = null;
	}

	void updateContext(PVector mouse, PVector pmouse, int _mouseButton, int keyCode, char key){
		this.mouse = mouse;
		this.pMouse = pmouse;
		this.keyCode = keyCode;
		this.key = key;
		this.mouseButton = _mouseButton;
		
	}

	void setMouseCount(int _mouseCount){
		this.mouseCount = _mouseCount;
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

				o.pos.set(p.z, p);
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
		if(t == 0){
			t = this.time;
		}

		for (SceneElement o : sceneElements) {
			if(o == selectedElement){
				o.c = color(255,0,0);
				o.curveColor = color(0,0,0);
			}else{
				o.c = color(0,0,0);
				o.curveColor = color(200,200,200);
			}
			o.drawCurve();
			o.draw(t);
		}

		fill(0);
		stroke(0);
		text("Tempo: "+t, 20, height - 20);
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
				this.curve = new CurveCat();
				return;
			}
		}

		selectedElement = null;
		stateContext.setStateName("select");
	}

	void alignTimes(float t){
		this.time = t;
	}
}
