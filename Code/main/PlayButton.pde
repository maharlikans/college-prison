class PlayButton implements ControlButton {
  float size;
  float xCenter;
  float yCenter;
  float difference; 
  float angle;
  float xRight;
  float xLeft;
  float yLeftUpper;
  float yLeftLower;
  float xRightTemp;
  float xLeftTemp;
  float yLeftUpperTemp;
  float yLeftLowerTemp;
  float speed;
  boolean pulsing;
  
  PlayButton (float size, float xCenter, float yCenter) {
    this.size = size;
    this.xCenter = xCenter;
    this.yCenter = yCenter;
    difference = (.5)*size - size*(5.0/24);
    
    xRight = xCenter + difference;
    xLeft = xCenter - difference;
    yLeftUpper = yCenter - difference;
    yLeftLower = yCenter + difference;

    // used to restore the play button to the original values
    xRightTemp = xRight;
    xLeftTemp = xLeft;
    yLeftUpperTemp = yLeftUpper;
    yLeftLowerTemp = yLeftLower;
    
    angle = 0;
    speed = .05;
    pulsing = false;
  }
  
  void display() {
    fill(255);
    if (hover(mouseX, mouseY)) {
      fill(0);
    }
    if (pulsing) {
      
      float scale = map(cos(angle), -1, 1, .6, 1);
      xRight = xCenter + scale*difference;
      xLeft = xCenter - scale*difference;
      yLeftUpper = yCenter - scale*difference;
      yLeftLower = yCenter + scale*difference;
      
      beginShape();
      vertex(xLeft, yLeftUpper);
      vertex(xLeft, yLeftLower);
      vertex(xRight, yCenter);
      endShape(CLOSE);
      angle+= speed;
    } else {
      beginShape();
      vertex(xLeft, yLeftUpper);
      vertex(xLeft, yLeftLower);
      vertex(xRight, yCenter);
      endShape(CLOSE);
    }
  }
  
  void init() {
    pulsing = true;
  }
  
  void reset() {
    pulsing = false;
    angle = 0;
    xRight = xRightTemp;
    xLeft = xLeftTemp;
    yLeftUpper = yLeftUpperTemp;
    yLeftLower = yLeftLowerTemp;
  }
  
  boolean hover(int x, int y) {
    if (x >= xLeft && x <= xRight) {
      if (y >= yLeftUpper && y <= yLeftLower) {
        return true;
      } 
    }
    return false;
  }
}
