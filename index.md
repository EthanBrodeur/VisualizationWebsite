
# Info Vis Project 2
[Go back to GitHub pages default](/GitHubPagesInfo.md) 




<script src="processing.js"></script>
<script type="text/processing" data-processing-target="processing-canvas">
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

//Table table;
String FILENAME;
float left, right, top, bottom;
String[] featureNames;
float[] mins, maxs;
float boxBegX, boxBegY, boxCurX, boxCurY;
float[] xVerts;
DimensionButton[] buttons;
FlipButton[] flips;
import java.util.HashSet;
import java.util.List;
HashSet<HashSet<LineSegment>> lines;
int activeFeatureIndex;
boolean[] flipped;
int numCols;
String[] rows;

void readFile() {
  rows = loadStrings(FILENAME);
  numCols = split(rows[0], ",").length;
}
void setup() {
  activeFeatureIndex = 0;
  lines = new HashSet<HashSet<LineSegment>>();
  FILENAME = "students.csv";
  // surface.setResizable(true);
  size(800,800);

  smooth(4);
  
  readFile();
  //table = loadTable(FILENAME, "header");
  mins= new float[numCols-1];
  maxs = new float[numCols-1];
  xVerts = new float[numCols-1];
  featureNames = getFeatureNames();
  buttons = new DimensionButton[numCols-1];
  flips = new FlipButton[numCols - 1];

  boxBegX = 0;
  boxBegY = 0;
  boxCurX = 0;
  boxCurY = 0;
  textSize(width/70.0);
  left = 0 +width*0.05;
  bottom = height*.85;
  right = width*.95;
  top = 0+height*0.05;

  for (int i = 1; i < numCols; i++) {
    initButtonSetup(i);
  }
  flipped = new boolean[numCols];
  for (boolean val : flipped) {
    val = false;
  }
}

void draw() {
  lines.clear(); //absurdly inefficient
  background(40);
  textSize(width/70.0);
  left = 0 +width*0.05;
  bottom = height*.85;
  right = width*.95;
  top = 0+height*0.05;
  for (int i = 1; i < numCols; i++) {
    drawParallelLine(numCols, i);
  }
  drawCoordinates();
  stroke(0);
  fill(50, 200, 50, 75);
  quad(boxBegX, boxBegY, boxCurX, boxBegY, boxCurX, boxCurY, boxBegX, boxCurY);
}

void drawCoordinates() {
  int ttCounted = 1;
  for (int h = 1; h < rows.length; h++) {
    String[] row = split(rows[h], ",");
    stroke(0, 0, 255); // draw blue by default
    HashSet<LineSegment> thisDataPointsLines = new HashSet<LineSegment>();
    boolean isHover = false; // by default, we are not hovering over the current line

    // get this height
    float prevHeight = 0;
    float prevX = 0;
    for (int i = 1; i < numCols; i++) {
      float xPos = (numCols != 2) ? (float)(i-1)/(numCols-2) * (right-left) + left : (left+right)/2;
      float curVal = (float) parseFloat(row[i]); 
      float maxPerc = (curVal-mins[i-1])/(maxs[i-1]-mins[i-1]);
      float heightOfPoint = 0;
      if (!flipped[i]) {
        heightOfPoint = top+(bottom-top)*(1.0-maxPerc);
      } else {
        heightOfPoint = bottom-(bottom-top)*(1.0-maxPerc);
      }
      if (i != 1) {
        stroke(0, 0, colorIntensity((float) parseFloat(row[activeFeatureIndex+1]), mins[activeFeatureIndex], maxs[activeFeatureIndex]));
        line(xPos, heightOfPoint, prevX, prevHeight);
        LineSegment l = new LineSegment(xPos, heightOfPoint, prevX, prevHeight);
        l.setName(row[0]);
        l.setTableRow(row);
        thisDataPointsLines.add(l);
        if (l.onLine(mouseX, mouseY)) {
          isHover = true;
          ToolTip tt = new ToolTip(l, ttCounted);
          tt.drawToolTip();
          ttCounted++;
        }
        if (l.boxHover(boxBegX, boxBegY, boxCurX, boxCurY)) {
          isHover = true;
        }
      }
      if (!lines.contains(thisDataPointsLines)) {
        lines.add(thisDataPointsLines);
      }
      prevHeight = heightOfPoint;
      prevX = xPos;
    }
    if (isHover) {
      stroke(255, 215, 0);
      fill(255, 215, 0);
      for (LineSegment gold : thisDataPointsLines) {
        line(gold.x, gold.y, gold.xx, gold.yy);
      }
    }
    thisDataPointsLines.clear();
  }
}

void drawParallelLine(int numCols, int index) {
  float xPos = (numCols != 2) ? (float)(index-1)/(numCols-2) * (right-left) + left : (left+right)/2;
  xVerts[index-1] = xPos;
  stroke(230);
  fill(230);
  line(xPos, top, xPos, bottom);

  // iterate through the rows of this column and get the min and max
  float min = 1000000; // arbitrary
  float max = -10000000; // arbitrary
  for (int i = 1; i < rows.length; i++) {
    String[] row = split(rows[i], ",");
    float val = (float) parseFloat(row[index]);
    min = ( val < min ? val : min);
    max = ( val > max ? val : max);
  }
  mins[index-1] = min;
  maxs[index-1] = max;


  textAlign(CENTER, CENTER);
  if (!flipped[index]) {
    text((int)(min), xPos, bottom+height*.015);  
    text((int)(max), xPos, top-height*.02);
  } else {
    text((int)(min), xPos, top-height*.02);  
    text((int)(max), xPos, bottom+height*.015);
  }

  flips[index-1].drawButton(xPos);
  // draw feature title
  buttons[index-1].drawButton(xPos);
  fill(255);
  text(featureNames[index-1], xPos, bottom+height*.05);
}
void mousePressed() {
  boxBegX = mouseX;
  boxBegY = mouseY;
  boxCurX = mouseX;
  boxCurY = mouseY;
}
void mouseClicked() {
  for (DimensionButton b : buttons) {
    if (b.buttonClicked()) {
      b.setActive();
      activeFeatureIndex = b.columnIndex;
      for (DimensionButton j : buttons) {
        if (j != b) {
          j.deactivate();
        }
      }
    }
  }
  for (FlipButton f : flips) {
    if (f.buttonClicked()) {
      flipped[f.columnIndex] = !flipped[f.columnIndex];
    }
  }
}
void mouseDragged() {
  boxCurX = mouseX;
  boxCurY = mouseY;
}

void mouseReleased() {
  boxCurX = 0;
  boxCurY = 0;
  boxBegX = 0;
  boxBegY = 0;
}

String[] getFeatureNames() {
  String[] firstLine = split(rows[0], ",");
  String[] ret = new String[numCols-1]; 
    for (int i = 1; i < numCols; i++) {
      ret[i-1] = firstLine[i];
    }
  return ret;
  
}

public int closestVertLine() {
  // start at the beginning, keep track of delta. if delta grows larger, we were closer to the line before
  float[] delta = new float[xVerts.length];
  for (int i = 0; i < xVerts.length; i++) {
    delta[i] = abs(mouseX-xVerts[i]);
  }
  int minIndex = 0;
  float min = delta[0];
  for (int i = 0; i < delta.length; i++) {
    if (delta[i] < min) {
      min = delta[i];
      minIndex=i;
    }
  }
  return minIndex;
}

public float xOfClosestVertLine(int closestLine) {
  return xVerts[closestLine];
}

public void initButtonSetup(int i) {
  float xPos = (numCols != 2) ? (float)(i-1)/(numCols-2) * (right-left) + left : (left+right)/2;
  stroke(230);
  fill(230);
  DimensionButton db = new DimensionButton(i-1, xPos, featureNames[i-1]);
  FlipButton bopit = new FlipButton(xPos, i);
  if (i ==1) {
    db.setActive();
  }
  buttons[i-1] = db;
  flips[i-1] = bopit;
}

public float colorIntensity(float thisVal, float minVal, float maxVal) {
  if (maxVal == minVal) {
    return 255.0;
  }
  float maxPerc = (thisVal-minVal)/(maxVal-minVal);
  return maxPerc*255.0;
}


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

class LineSegment {
  float x, y, xx, yy, minx, maxx, miny, maxy;
  String name;
  String[] tr;
  public LineSegment(float x, float y, float xx, float yy) {
    this.x = x;
    this.y = y;
    this.xx = xx;
    this.yy = yy;
    maxx = (xx >= x ? xx : x);
    minx = (xx < x ? xx : x);
    maxy = (yy >= y ? yy : y);
    miny = (yy < y ? yy : y);
  }

  public void setName(String name) {
    this.name = name;
  }
  public void setTableRow(String[] tr) {
    this.tr = tr;
  }

  public boolean onLine(float xCandidate, float yCandidate) {

    if (xCandidate > maxx | xCandidate < minx) {
      return false;
    }
    float leeway = height*.02;
    float slope = (yy-y)/(xx-x);
    float b = y - slope*x;


    float wouldBeYPos = slope*xCandidate + b;
    if (yCandidate <= wouldBeYPos + leeway && yCandidate >= wouldBeYPos - leeway) {
      return true;
    } else return false;
  }

  public boolean boxHover(float xl, float yt, float xr, float yb) {
    LineSegment box1 = new LineSegment(xl, yt, xl, yb);
    LineSegment box2 = new LineSegment(xl, yt, xr, yt);
    LineSegment box3 = new LineSegment(xr, yt, xr, yb);
    LineSegment box4 = new LineSegment(xl, yb, xr, yb);
    if (lineIntersection(this, box1)||lineIntersection(this, box2)||lineIntersection(this, box3)||lineIntersection(this, box4)) {
      return true;
    }
    return false;
  }
  public boolean lineIntersection(LineSegment l1, LineSegment l2) {
    if ((l2.minx > l1.maxx) || (l1.minx>l2.maxx)) {
      //return false;
    }

    float l1xgap = l1.x - l1.xx;
    float l1ygap = l1.y - l1.yy;
    float l2xgap = l2.x - l2.xx;
    float l2ygap = l2.y - l2.yy;

    //Cramer's Rule, borrowed from SO: https://stackoverflow.com/questions/563198/whats-the-most-efficent-way-to-calculate-where-two-line-segments-intersect
    float s = (-l1ygap*(l1.xx-l2.xx)+ l1xgap*(l1.yy-l2.yy))/(-l2xgap * l1ygap + l1xgap*l2ygap);
    float t = (l2xgap*(l1.yy-l2.yy)-l2ygap*(l1.xx-l2.xx))/(-l2xgap*l1ygap + l1xgap*l2ygap);

    if ( s>= 0 && s<= 1 && t >= 0 && t<= 1) {
      return true;
    }
    return false;
  }

  @Override
    public boolean equals(Object obj) {
    if (obj == null) {
      return false;
    }
    if ((((LineSegment)obj).x == this.x) && (((LineSegment)obj).y == this.y) && (((LineSegment)obj).xx == this.xx) && (((LineSegment)obj).yy == this.yy)) {
      return true;
    } else return false;
  }
  public String toString() {
    //  return 
    return this.x + ", " + this.y + " | " + this.xx + ", " + this.yy;
  }
}

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
</script>
<canvas id="processing-canvas"> </canvas>

