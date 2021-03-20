import fpstracker.core.*;

PerfTracker pt;

PVector center, size;
Line root;

ArrayList<Line> lineList;
Line current;

void settings() {
  size(512, 512, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);

  center = new PVector(width * 0.5, height * 0.5);
  size = new PVector(width * 0.25, height - 20);
  PVector[] AB = getRandomointOnRectEdge(center, size);
  root = new Line(AB[0], AB[1]);
  root.isFinished = true;

  Line l = root.getNewlineDirection();

  lineList = new ArrayList<Line>();
  lineList.add(root);
  lineList.add(l);

  current = lineList.get(lineList.size() - 1);
  
  frameRate(300);
}

void draw() {
  background(0);

  rectMode(CENTER);
  noFill();
  stroke(255, 0, 0);
    strokeWeight(1.0);
  rect(center.x, center.y, size.x, size.y);

  grow();
  strokeCap(ROUND);
  float hyp = sqrt(size.x * size.x + size.y * size.y);
  for (Line line : lineList) {
    if (line.isFinished) {
      stroke(255);
    } else {
      stroke(0, 255, 0);
    }
    float d = PVector.dist(line.A, line.B);
    float nd = d / hyp;
   // nd = 1.0 - nd;
    //strokeWeight(1.0 + nd * 3.0);
    line.displayLine(g);
    // line.displayRoots(g);
  }

  pt.display(0, 0);
}




void keyPressed() {
  lineList.clear();
  PVector[] AB = getRandomointOnRectEdge(center, size);
  root = new Line(AB[0], AB[1]);
  root.isFinished = true;

  Line l = root.getNewlineDirection();


  lineList.add(root);
  lineList.add(l);
  current = lineList.get(lineList.size() - 1);
}

void grow() {
  float minDist = 10.0;
  if (!current.isFinished) {
    //seek to an edge
    PVector seek = current.dir.copy();
    seek.mult(1.0);
    seek.add(current.B);

    current.B = seek.copy();

    //check all other line for intersection
    for (int j=0; j<lineList.size(); j++) {
      Line neighbor = lineList.get(j);
      if (current != neighbor && PVector.dist(current.A, current.B) > 5.0 && neighbor.isFinished) {
        boolean isIntersected = isIntersectedBy(current.B, current.A, neighbor.A, neighbor.B, 0.05);
        if (isIntersected) {
          current.isFinished = true;
          addNewLine(minDist);
          break;
        }
      }
    }

    //check edge
    if (current.B.x < center.x - size.x * 0.5 
      || current.B.x > center.x + size.x * 0.5 
      || current.B.y < center.y - size.y * 0.5 
      || current.B.y > center.y + size.y * 0.5) {

      current.isFinished = true;
      addNewLine(minDist);
    }
  }
}

void addNewLine(float minDist) {
  //get random line on array
  int index = floor(random(lineList.size()-1));
  Line root = lineList.get(index);

  float dist = PVector.dist(root.A, root.B);
  while (dist < minDist) {
    //println(dist, "Root not found");
    index = floor(random(lineList.size()-1));  
    root = lineList.get(index);
    dist = PVector.dist(root.A, root.B);
  } 
    //println("\t", dist, "Root found");

  Line newLine = root.getNewlineDirection();
  lineList.add(newLine);
  current = lineList.get(lineList.size() - 1);
}

boolean isIntersectedBy(PVector P, PVector Q, PVector A, PVector B, float range) {
  //from http://jeffreythompson.org/collision-detection/line-point.php
  float dist = PVector.dist(A, B);
  float PtoA = PVector.dist(P, A);
  float PtoB = PVector.dist(P, B);

  PVector AtoB = PVector.sub(A, B).normalize();
  PVector PtoQ = PVector.sub(P, Q).normalize();
  float dot = PVector.dot(AtoB, PtoQ);

  if (abs(dot) < 0.995 && dist > range * 2.0) { //avoid parallels lines
    if (PtoA + PtoB >= dist - range && PtoA + PtoB <= dist + range) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

PVector[] getRandomointOnRectEdge(PVector center, PVector size) {
  //based rectangle;
  PVector A = new PVector(center.x - size.x * 0.5, center.y - size.y * 0.5);
  PVector B = new PVector(center.x + size.x * 0.5, center.y - size.y * 0.5);
  ;
  PVector C = new PVector(center.x + size.x * 0.5, center.y + size.y * 0.5);
  PVector D = new PVector(center.x - size.x * 0.5, center.y + size.y * 0.5);

  //define random Vector
  PVector A_ = new PVector();
  PVector B_ = new PVector();
  float rand = random(1.0);
  A_ = getRandomPosition(A, B, C, D, rand);
  if (rand <= 0.25) {
    B_ = getRandomPosition(A, B, C, D, random(0.26, 1.0));
  } else if (rand <= 0.5) {
    float randb = (random(1.0) > 0.5) ? random(0.0, 0.25) : random(0.51, 1.0);
    B_ = getRandomPosition(A, B, C, D, randb);
  } else if (rand <= 0.75) {
    float randb = (random(1.0) > 0.5) ? random(0.0, 0.5) : random(0.76, 1.0);
    B_ = getRandomPosition(A, B, C, D, randb);
  } else {
    B_ = getRandomPosition(A, B, C, D, random(0.0, 0.76));
  }

  PVector[] array = {A_, B_};
  return array;
}

PVector getRandomPosition(PVector A, PVector B, PVector C, PVector D, float rand) {
  float randPosition = random(1.0);
  PVector V;
  if (rand <= 0.25) {
    V = PVector.lerp(A, B, randPosition);
  } else if (rand <= 0.5) {
    V = PVector.lerp(B, C, randPosition);
  } else if (rand <= 0.75) {
    V = PVector.lerp(C, D, randPosition);
  } else {
    V = PVector.lerp(D, A, randPosition);
  }

  return V;
}

PVector mult2D(PVector U, PVector multiplier) {
  return new PVector(U.x * multiplier.x, U.y * multiplier.y);
}
