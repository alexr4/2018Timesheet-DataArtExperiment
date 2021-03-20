void grow(float minDist) {
  float len = 0.5;
  if (!current.isFinished) {
    //seek to an edge
    PVector seek = current.dir.copy();
    seek.mult(len);
    seek.add(current.B);

    current.B = seek.copy();

    //check all other line for intersection
    for (int j=0; j<lineList.size(); j++) {
      Line neighbor = lineList.get(j);
      if (current != neighbor && PVector.dist(current.A, current.B) > 5.0 && neighbor.isFinished) {
        boolean isIntersected = isIntersectedBy(current.B, current.A, neighbor.A, neighbor.B, 0.005);
        if (isIntersected) {
          current.isFinished = true;
          
          seek = current.dir.copy();
          seek.mult(len);
          seek.add(current.B);

          current.B = seek.copy();
          
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
  if (lineList.size() < hourDatas.size()) {
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
    float isAdditional = hourDatas.get(dataIndex).y;
    Line newLine = root.getNewlineDirection(isAdditional);
    lineList.add(newLine);
    current = lineList.get(lineList.size() - 1);
    dataIndex = lineList.size();
  } else {
    isComputed = true;
  }
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
