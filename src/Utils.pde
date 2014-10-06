public static class Utils{
  
  static void printArrayPVector(PVector[] p)
  {
    for (int i=0;i<p.length-1;i++)
      println(i+" "+p[i]);
  }

  static boolean mouseOverRect(PVector mouse, int x, int y, int w, int h) {
  	return (mouse.x >= x && mouse.x <= x+w && mouse.y >= y && mouse.y <= y+h);
  }

  static void pvectorArrayCopy(PVector[] src, PVector[] dest){
  	for (int i = 0; i<src.length; i++){
  		dest[i] = src[i];
  	}
  }

  static void print_r(int[] array){
    for (int i = 0; i<array.length; i++){
      println(array[i]);
    }
  }
}

void my_assert (boolean p) {
  if (!p) console.log ("my_assertion failed");
}
