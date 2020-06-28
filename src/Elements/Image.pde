class Image extends SceneElement{

  float width, height;
  PImage myImage;
  string myPath;
  boolean active;

  Image(string path)
  {
    super(context.mouse);
    this.name = "Image";
    myPath = path;
    active = true;
    myImage = loadImage(myPath);
  }

  void draw(float t)
  {
    if(pos.nKeys() < 1){
      return;
    }

    if(t > pos.keyTime(pos.nKeys()-1)){
      t = pos.keyTime(pos.nKeys()-1);
    }

    PVector position;
    if(!active){
      position = pos.get(0);
      PVector tangent = pos.getTangent(0);
      float myScale = this.sizeInterpolator.get(0).getSize();
    }else{
      position = pos.get(t);
      PVector tangent = pos.getTangent(t);
      float myScale = this.sizeInterpolator.get(t).getSize();
    }

    if(t == 0 || isStatic){
      myScale = 1;
      position = getInitialPosition();
      tangent = new PVector(0,0);
    }

    pushMatrix();

    fill(255);
    // tint(255, 127);

    if(this.hasStroke){
      strokeWeight(1);
      stroke(c);
    }else{
      noStroke();
    }

    smooth(8);

    translate(position.x, position.y, 0);

    if(this.followTangent)
      rotate(atan2(tangent.y, tangent.x));


    float new_width = myImage.width * myScale;
    float new_height = myImage.height * myScale;

    translate(-new_width/2, -new_height/2,0);
    image(myImage, 0 ,0, new_width, new_height  );

    popMatrix();
  }

  void setWidth(float x){
    this.width = x;
  }

  void setHeight(float x){
    this.height = x;
  }

  float lastTime()
  {
    float lastTime = 0;
    if(pos.nKeys() < 1){
      lastTime = 0;
      isStatic = true;
    }else{
      lastTime = pos.interp.time.get(pos.nKeys()-1);
      if(lastTime <= 0 )
        isStatic = true;
      else
        isStatic = false;
    }
    
    return lastTime;
  }

  boolean isOver(PVector mouse){
                PVector position = pos.get(0);
                float my_width = myImage.width;
                float my_height = myImage.height;
    return mouse.x < position.x + my_height/2 && mouse.x > position.x - my_height/2 && mouse.y < position.y + my_width/2 && mouse.y > position.y - my_width/2;
  }
}
