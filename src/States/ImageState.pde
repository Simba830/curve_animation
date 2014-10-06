class ImageState extends State {

    ImageState(Context _context){
      super(_context);
      console.log('Image State');
      console.log('context.path_image:'+context.path_image);  
    }

    public void mousePressed() 
    {
        Image m = new Image(context.path_image);
        m.sizeInterpolator.set(0, new Property());
        context.addElement(m);  
        context.setSelectedElement(m);
    }

    public void mouseDragged(){

    }
    
    public void mouseReleased() 
    {
        stateContext.setStateName("select");
    }

    public void keyPressed(){
      
    }

    public void draw()
    {

    }
}