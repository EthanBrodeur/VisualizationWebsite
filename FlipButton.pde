class FlipButton {
  float xPos;
  int columnIndex;
  float xStart, yStart, xWidth, yHeight;
  public FlipButton(float xPos, int columnIndex) {
    this.xPos = xPos;
    this.columnIndex = columnIndex;
    xStart = xPos-textWidth("Flip!")/1.98;
    yStart = bottom+height*.091;
    xWidth = textWidth("Flip!")*1.02;
    yHeight = textAscent()+textDescent();
  }

  public void drawButton(float xPos) {
    xStart = xPos-textWidth("Flip!")/1.98;
    yStart = bottom+height*.091;
    xWidth = textWidth("Flip!")*1.02;
    yHeight = textAscent()+textDescent();
    stroke(255);
    fill(0);
    rect(xStart, yStart, xWidth, yHeight);
    fill(255);
    text("Flip!", xStart+xWidth/2, yStart+yHeight/2);
  }
  public boolean buttonClicked() {
    if (mouseX >= xStart && mouseX <= xStart + xWidth && mouseY >= yStart && mouseY <= yStart + yHeight) {
      fill(255, 0, 0, 200);
      rect(xStart, yStart, xWidth, yHeight);
      return true;
    }
    return false;
  }
}