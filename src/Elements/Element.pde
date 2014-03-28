class Element{
	PVector position;
	CurveCat curve;

	Element(PVector _position){
		position = _position;
	}

	void drag(float dx, float dy)
	{
		position.x += dx;
		position.y += dy;
	}
}