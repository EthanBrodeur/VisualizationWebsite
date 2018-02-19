class ToolTip {
  String name;
  LineSegment lineseg;
  int positionIndex;
  public ToolTip(LineSegment lineseg, int positionIndex) {
    this.name = lineseg.name;
    this.lineseg = lineseg;
    this.positionIndex = positionIndex;
  }

  void drawToolTip() {
    fill(255);
    stroke(0);

    float tipHeight = height/15;
    String display = name + ": (";
    display += (float) parseFloat(lineseg.tr[closestVertLine()+1]) +")";
    float offset = 0;
    float tipWidth = textWidth(display);
    if (mouseX - tipWidth < 0) {
      offset = tipWidth;
    }
    if (mouseX + tipWidth > width) {
      offset = -tipWidth;
    }

    if (abs(xOfClosestVertLine(closestVertLine())-mouseX)>width/20) {
      // leave a dead zone since we aren't that close to the coordinate and info would be confusing
    } else {
      if (positionIndex == 1) { // above left of mouse
        rect(offset + mouseX-tipWidth, mouseY- tipHeight, tipWidth, tipHeight);
        textAlign(CENTER, CENTER);
        fill(0);
        text(display, offset + mouseX-tipWidth/2, mouseY-tipHeight/2);
      } else if (positionIndex == 2) { //above right of mouse
        rect(offset + mouseX, mouseY- tipHeight, tipWidth, tipHeight);
        textAlign(CENTER, CENTER);
        fill(0);
        text(display, offset + mouseX+tipWidth/2, mouseY-tipHeight/2);
      } else if (positionIndex == 3) { //below left of mouse
        rect(offset + mouseX-tipWidth, mouseY, tipWidth, tipHeight);
        textAlign(CENTER, CENTER);
        fill(0);
        text(display, offset + mouseX-tipWidth/2, mouseY+tipHeight/2);
      } else if (positionIndex == 4) { // bottom right of mouse
        rect(offset + mouseX, mouseY, tipWidth, tipHeight);
        textAlign(CENTER, CENTER);
        fill(0);
        text(display, offset + mouseX+tipWidth/2, mouseY+tipHeight/2);
      } else if (positionIndex > 4) {
        int numRowsDown = positionIndex - 4;
        rect(offset + mouseX-tipWidth/2, mouseY+tipHeight*numRowsDown, tipWidth, tipHeight);
        textAlign(CENTER, CENTER);
        fill(0);
        text(display, offset + mouseX, mouseY+tipHeight*numRowsDown+tipHeight/2);
      }
    }
  }
}