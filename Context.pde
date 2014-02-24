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
	SmoothPositionInterpolator pos;
	boolean playing;

	Context(){
		selectedSegments = new int[0];
		this.curve = new CurveCat();
		this.curve.setTolerance(7);

		pos = new SmoothPositionInterpolator();
		playing = false;
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
	}

	void diselect(){
		this.selectedSegments = new int[0];
	}

	boolean isPlayed(){
		return playing;
	}

	void play(){
		frameCount = 0;
		pos.clear();

		if(curve.getNumberControlPoints() == 0){
			return;
		}


		for (int i = 0; i<curve.getNumberControlPoints() - 1; i++){
			PVector p = curve.getControlPoint(i);

			pos.set(p.z, p);
		}

		playing= true;
	}

	void refreshInterpolator(){

		if(!this.isPlayed()){
			return;
		}

		pos.clear();

		float length = curve.curveLength();

		for (int i = 0; i<curve.getNumberControlPoints() - 1; i++){
			PVector p = curve.getControlPoint(i);

			pos.set(p.z, p);
		}

		playing= true;
	}

	void stop(){
		playing= false;
	}

}
