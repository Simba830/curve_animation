class Context{
	private PVector mouse;
	private PVector pMouse;
	private int mouseButton;
	private int keyCode;
	private char key;
	private CurveCat curve;
	private PVector mouseInit;
	private PVector mouseFinal;
	private int[] selectedSegments;
	private int mouseCount;
	private boolean playing;
	private ArrayList<SceneElement> sceneElements;
	private SceneElement selectedElement;
	private float time;

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

		Property p;

		for (SceneElement o : sceneElements) {
			o.pos.clear();

			for (int i = 0; i< o.curve.getNumberControlPoints(); i++){
				p = o.curve.getControlPoint(i);

				o.pos.set(p.getT(), new PVector(p.getX(), p.getY()));
			}
		}

		play = true;
	}

	void stop(){
		playing = false;
		t = 0;
	}

	// Adiciona um elemento a lista de elementos
	void addElement(SceneElement e)
	{
		sceneElements.add(e);
	}

	// Desenha todos os elementos na tela
	void draw(float t){
		if(t == 0){
			t = this.time;
		}

		for (SceneElement o : sceneElements) {
			if(o == selectedElement){
				o.c = #428bca;
				o.curveColor = color(0,0,0);
			}else{
				o.c = color(0,0,0);
				o.curveColor = color(200,200,200);
			}

			o.draw(t);
			o.drawCurve();
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

	void setSelectionBox(PVector mouseInit, PVector mouseFinal){
		this.mouseInit = mouseInit;
		this.mouseFinal = mouseFinal;
	}
	
	PVector getpMouse()
	{
		return this.pMouse;
	}

	PVector getMouse(){
		return this.mouse;
	}
}
