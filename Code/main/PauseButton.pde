class PauseButton implements ControlButton {
  float size;
  float xCenter;
  float yCenter;
  float rectHeight;
  float rectWidth;
  float xDiff;
  
  PauseButton (float size, float xCenter, float yCenter) {
    this.size = size;
    this.xCenter = xCenter;
    this.yCenter = yCenter;
    
    rectHeight = size/2;
    rectWidth = size/4;
    xDiff = size/6;
  } 
  
  void display() {
    rectMode(CENTER);
    noStroke();
    if (hover(mouseX, mouseY))
      fill(0);
    else
      fill(204);
    rect(xCenter - xDiff, yCenter, rectWidth, rectHeight);
    rect(xCenter + xDiff, yCenter, rectWidth, rectHeight);
  }
  
  void reset() {
    // nothing
  }
  
  void init() {
    // nothing 
  }
  
  boolean hover(int x, int y) {
    if (x >= xCenter - xDiff - rectWidth/2 && x <= xCenter + xDiff + rectWidth/2) 
      if (y >= yCenter - rectHeight/2 && y <= yCenter + rectHeight/2)
        return true;
    return false;
  }
}
