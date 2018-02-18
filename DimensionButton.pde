class DimensionButton {
  int columnIndex;
  String string;
  float xPos;
  float xStart, yStart, xWidth, yHeight;
  boolean active;
  public DimensionButton(int columnIndex, float xPos, String string) {
    this.active = false;
    this.columnIndex = columnIndex;
    this.xPos = xPos;
    this.string = string;
    xStart = xPos-textWidth(string)/1.98;
    yStart = bottom+height*.091;
    xWidth = textWidth(string)*1.02;
    yHeight = textAscent()+textDescent();
  }
  public void drawButton(float xPos) {
    xStart = xPos-textWidth(string)/1.98;
    yStart = bottom+height*.041;
    xWidth = textWidth(string)*1.02;
    yHeight = textAscent()+textDescent();
    stroke(255);
    fill(0);
    if (active) {
      fill(255, 215, 0, 200);
    }
    rect(xStart, yStart, xWidth, yHeight);
  }

  public boolean buttonClicked() {
    if (mouseX >= xStart && mouseX <= xStart + xWidth && mouseY >= yStart && mouseY <= yStart + yHeight) {
      return true;
    }
    return false;
  }

  public void setActive() {
    active = true;
  }

  public void deactivate() {
    active = false;
  }
}