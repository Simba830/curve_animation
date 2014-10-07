class SceneElement
{
	/** 

	Propriedades Posicionais possíveis do objeto:
		- Nome;
		- Posição;
		- Rotação;
		- Curva de Trajetória Associada;
	
	Propriedades Não-posicionais do Objeto:
		- Cor;
		- Transparência;
		- Escala;
		

	**/
	private String name;
	private SmoothPositionInterpolator pos;
	private float rotation; 
	private CurveCat curve; 
	private float scale; 
	private color c, curveColor; 
	private float transparency;
	private SmoothInterpolator sizeInterpolator;
	private boolean isStatic;
	private boolean hasStroke;
	private boolean followTangent;


	SceneElement(PVector position)
	{
		this.followTangent = true;
		this.hasStroke = true;
		this.isStatic = true;
		this.name = "Element";
		this.scale = 1.0;
		this.c = color(0,0,0);
		this.sizeInterpolator = new SmoothInterpolator();
		Property p = new Property(position.x,position.y,0);
		p.setT(0);
		p.setSize(1);
		this.sizeInterpolator.set(p.getT(), p);
		this.pos = new SmoothPositionInterpolator(new SmoothInterpolator());
		this.pos.set(0,position);
		this.rotation = 0.6;
		this.curveColor = color(100,100,100);
		this.transparency = 0;
		this.curve = new CurveCat();
		this.curve.setTolerance(15);
	}

	void draw(float t){

	}
	
	void drawCurve(){
		pushMatrix();
		curve.strokeColor = curveColor;
		noFill();
		this.curve.draw();
		stroke(0);
		popMatrix();
	}
	void load(){

	}
	void update(){

	}
	float lastTime(){
		return pos.keyTime(pos.nKeys()-1);
	}

	boolean isOver(PVector mouse){
		return true;
	}

	CurveCat getCurve(){
		return this.curve;
	}

	void setCurve(CurveCat newCurve){
		this.curve = newCurve;
	}

	void setInitialPosition(PVector v){
		pos.set(0, v);
		Property p = new Property(v.x, v.y);
		p.setSize(1);
		p.setT(0);
		this.curve.setPoint(p, 0);
	}

	PVector getInitialPosition(){
		return pos.get(0);
	}

	// Get e Set das Escalas
	void setScale(float _scale)
	{
		this.scale = _scale;
	}
	float getScale()
	{
		return this.scale;
	}
	// Get e Set da Rotação
	void setRotation(float _rotation)
	{
		this.rotation = _rotation;
	}
	float getRotation()
	{
		return this.rotation;
	}

	void noStroke(){
		this.hasStroke = false;
	}

	void setStroke(){
		this.hasStroke = true;
	}

	void toggleTangent(){
		this.followTangent = !this.followTangent;
	}
}
