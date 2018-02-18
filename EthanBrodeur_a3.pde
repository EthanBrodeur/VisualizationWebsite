Table table;
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
HashSet<HashSet<Line>> lines;
int activeFeatureIndex;
boolean[] flipped;

void setup() {
  activeFeatureIndex = 0;
  lines = new HashSet<HashSet<Line>>();
  FILENAME = "students.csv";
  size(1100, 700);

  smooth(4);
  table = loadTable(FILENAME, "header");
  mins= new float[table.getColumnCount()-1];
  maxs = new float[table.getColumnCount()-1];
  xVerts = new float[table.getColumnCount()-1];
  featureNames = getFeatureNames();
  buttons = new DimensionButton[table.getColumnCount()-1];
  flips = new FlipButton[table.getColumnCount() - 1];

  boxBegX = 0;
  boxBegY = 0;
  boxCurX = 0;
  boxCurY = 0;
  textSize(width/70.0);
  left = 0 +width*0.05;
  bottom = height*.85;
  right = width*.95;
  top = 0+height*0.05;

  for (int i = 1; i < table.getColumnCount(); i++) {
    initButtonSetup(i);
  }
  flipped = new boolean[table.getColumnCount()];
  for (boolean val : flipped) {
    val = false;
  }
}

void draw() {
  println("please log to console");
  lines.clear(); //absurdly inefficient
  background(40);
  textSize(width/70.0);
  left = 0 +width*0.05;
  bottom = height*.85;
  right = width*.95;
  top = 0+height*0.05;
  for (int i = 1; i < table.getColumnCount(); i++) {
    drawParallelLine(table.rows(), table.getColumnCount(), i);
  }
  drawCoordinates();
  stroke(0);
  fill(50, 200, 50, 75);
  quad(boxBegX, boxBegY, boxCurX, boxBegY, boxCurX, boxCurY, boxBegX, boxCurY);
}

void drawCoordinates() {
  int ttCounted = 1;
  for (TableRow row : table.rows()) {
    stroke(0, 0, 255); // draw blue by default
    HashSet<Line> thisDataPointsLines = new HashSet<Line>();
    boolean online = false; // by default, we are not hovering over the current line

    // get this height
    float prevHeight = 0;
    float prevX = 0;
    for (int i = 1; i < table.getColumnCount(); i++) {
      float xPos = (table.getColumnCount() != 2) ? (float)(i-1)/(table.getColumnCount()-2) * (right-left) + left : (left+right)/2;
      float curVal = row.getFloat(i); 
      float maxPerc = (curVal-mins[i-1])/(maxs[i-1]-mins[i-1]);
      float heightOfPoint = 0;
      if (!flipped[i]) {
        heightOfPoint = top+(bottom-top)*(1.0-maxPerc);
      } else {
        heightOfPoint = bottom-(bottom-top)*(1.0-maxPerc);
      }
      if (i != 1) {
        stroke(0, 0, colorIntensity(row.getFloat(activeFeatureIndex+1), mins[activeFeatureIndex], maxs[activeFeatureIndex]));
        line(xPos, heightOfPoint, prevX, prevHeight);
        Line l = new Line(xPos, heightOfPoint, prevX, prevHeight);
        l.setName(row.getString(0));
        l.setTableRow(row);
        thisDataPointsLines.add(l);
        if (l.onLine(mouseX, mouseY)) {
          online = true;
          ToolTip tt = new ToolTip(l, ttCounted);
          tt.drawToolTip();
          ttCounted++;
        }
        if (l.boxHover(boxBegX, boxBegY, boxCurX, boxCurY)) {
          online = true;
        }
      }
      if (!lines.contains(thisDataPointsLines)) {
        lines.add(thisDataPointsLines);
      }
      prevHeight = heightOfPoint;
      prevX = xPos;
    }
    if (online) {
      stroke(255, 215, 0);
      fill(255, 215, 0);
      for (Line gold : thisDataPointsLines) {
        line(gold.x, gold.y, gold.xx, gold.yy);
      }
    }
    thisDataPointsLines.clear();
  }
}

void drawParallelLine(Iterable<TableRow> rows, int numCols, int index) {
  float xPos = (numCols != 2) ? (float)(index-1)/(numCols-2) * (right-left) + left : (left+right)/2;
  xVerts[index-1] = xPos;
  stroke(230);
  fill(230);
  line(xPos, top, xPos, bottom);

  // iterate through the rows of this column and get the min and max
  float min = 1000000; // arbitrary
  float max = -10000000; // arbitrary
  for (TableRow row : rows) {
    float val = row.getFloat(index);
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
  String[] ret = new String[table.getColumnCount()-1]; 
  table = loadTable(FILENAME); 
  for (TableRow row : table.rows()) {
    for (int i = 1; i < table.getColumnCount(); i++) {
      ret[i-1] = row.getString(i);
    }
    break;
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
  int numCols = this.table.getColumnCount();
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
