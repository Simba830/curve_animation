class Image extends SceneElement{

  float width, height;
  PImage myImage;
  boolean active;

  Image(string path)
  {
    super(context.mouse);
    this.name = "Image";
    active = true;
    myImage = loadImage(path);
  }

  void draw(float t)
  {
    if(pos.nKeys() < 1){
      return;
    }

    if(t >= pos.keyTime(pos.nKeys()-1)){
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

    if(t == 0){
      myScale = 1;
    }

    float oldImageWidth = myImage.width;
    float oldImageHeight = myImage.height;
    myImage.resize(myImage.width*myScale, myImage.height*myScale);

    pushMatrix();

    // noFill();
    fill(255);
    // noStroke();
    smooth(8);
    imageMode(CENTER);

    stroke(c);
    translate(position.x, position.y, 0);
    rotate(atan2(tangent.y, tangent.x));
    translate(-myImage.width/2, -myImage.height/2,0);

    // rect(20,20,0,0);
    image(myImage, 0 ,0 );

    popMatrix();

    myImage.resize(oldImageWidth, oldImageHeight);
  }

  void setWidth(float x){
    this.width = x;
  }

  void setHeight(float x){
    this.height = x;
  }

  float lastTime()
  {
    if(pos.nKeys() < 1)
      return 0;

    return pos.interp.time.get(pos.nKeys()-1);
  }

  boolean isOver(PVector mouse){
                PVector position = pos.get(0);
                float my_width = myImage.width;
                float my_height = myImage.height;
    return mouse.x < position.x + my_height/2 && mouse.x > position.x - my_height/2 && mouse.y < position.y + my_width/2 && mouse.y > position.y - my_width/2;
  }
}
