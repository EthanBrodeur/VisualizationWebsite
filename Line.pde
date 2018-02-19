class Line {
  float x, y, xx, yy, minx, maxx, miny, maxy;
  String name;
  String[] tr;
  public Line(float x, float y, float xx, float yy) {
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
    Line box1 = new Line(xl, yt, xl, yb);
    Line box2 = new Line(xl, yt, xr, yt);
    Line box3 = new Line(xr, yt, xr, yb);
    Line box4 = new Line(xl, yb, xr, yb);
    if (lineIntersection(this, box1)||lineIntersection(this, box2)||lineIntersection(this, box3)||lineIntersection(this, box4)) {
      return true;
    }
    return false;
  }
  public boolean lineIntersection(Line l1, Line l2) {
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
    if ((((Line)obj).x == this.x) && (((Line)obj).y == this.y) && (((Line)obj).xx == this.xx) && (((Line)obj).yy == this.yy)) {
      return true;
    } else return false;
  }
  public String toString() {
    //  return 
    return this.x + ", " + this.y + " | " + this.xx + ", " + this.yy;
  }
}