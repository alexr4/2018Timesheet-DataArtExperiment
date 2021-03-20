import fpstracker.core.*;

PerfTracker pt;
ArrayList<PVector> vertList;
ArrayList<PVector> smoothVertList;
float thetaInc, thetaStart, radius, ox, oy;
PGraphics buffer;
boolean isComputed;

Rectangle aabb;
Rectangle range;
QuadTree quadtree;

void settings() {
  size(1000, 1000, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);
  buffer = createGraphics(5000, 5000, P2D); 
  buffer.smooth();

  vertList = new ArrayList<PVector>();
  smoothVertList = new ArrayList<PVector>();

  int nbDay = 7;
  thetaInc = TWO_PI/nbDay;
  thetaStart = thetaInc * 0.25;
  radius = buffer.width * 0.35;
  ox = buffer.width * 0.5;
  oy = buffer.height * 0.5;
  float margin = 0.01;
  for (int i=0; i<nbDay; i++) {
    float theta = i * thetaInc + thetaInc * margin;
    float gamma = (i+1) * thetaInc - thetaInc * margin;
    float eta = theta + (gamma - theta) * 0.5;

    float x1 = cos(theta + thetaStart) * radius + ox;
    float y1 = sin(theta + thetaStart) * radius + oy;
    float x2 = cos(gamma + thetaStart) * radius + ox;
    float y2 = sin(gamma + thetaStart) * radius + oy;
    float x3 = cos(eta + thetaStart) * radius * margin + ox;
    float y3 = sin(eta + thetaStart) * radius * margin + oy;

    //vertList.add(new PVector(x3, y3));
    vertList.add(new PVector(x1, y1));
    //vertList.add(new PVector(x2, y2));
  }
  println("verList initialized");

  //subdive
  for (int i=0; i<nbDay * 3; i+=3) {
   int it = (int) random(1, 5);
   PVector A = vertList.get(i);
   PVector B = vertList.get(i+1);
   PVector C = vertList.get(i+2);
   //subdivOnTwo(A,B,C,it);
   //subdivGravityCenter(A, B, C, it);
   //subdivGravityCenterInside(A, B, C, it, 0.01, it);
   //subdivGravityCenterOffset(A,B,C,it, new PVector(0, 1), 400.0, it);
   //subdivMediatrice(A, B, C, it);
   subdivGravityCenterMediatrice(A, B, C, it, it);
   //subdivGravityCenterMediatrice(A, B, C, it, 0.15, it);
   //subdivGravityCenterMediatrice(A, B, C, it, new PVector(buffer.width * 0.5, buffer.height * 0.5), radius, radius * 0.05, it);
   }
  println("Subdivision done");


  /*
  aabb = new Rectangle(buffer.width * 0.5, buffer.height * 0.5, buffer.width * 0.5, buffer.height * 0.5);
   quadtree = new QuadTree(aabb, 4);
   
   for (PVector v : vertList) {
   quadtree.insert(v);
   }
   println("QuadTree distribution done");
   
   
   int sit = 4;
   float desiredDistance = 500.0;
   smoothVertList = computeLaplacianSmooth(vertList, desiredDistance);
   println("\tLaplacian 0 done");
   for (int i=1; i<sit; i++) {
   float ni = 1.0 - (float)i / (float) sit;
   smoothVertList = computeLaplacianSmooth(smoothVertList, desiredDistance * ni);
   println("\tLaplacian "+i+" done");
   }
   println("smoothVertList done");
   */
  buffer.beginDraw();
  buffer.colorMode(HSB, 1.0, 1.0, 1.0, 1.0);
  buffer.background(0);
  //buffer.strokeWeight(10);
  computeBuffer(buffer, vertList);
  //computeBuffer(buffer, smoothVertList);
  buffer.endDraw();
}

void draw() {
  background(0);
  noFill();

  imageMode(CENTER);
  float x = width/2;
  float y = height/2;
  float w = width;
  float h = height;

  if (mousePressed) {
    w = buffer.width;
    h = buffer.height;
    x = norm(mouseX, 0, width) * w;
    y = norm(mouseY, 0, height) * h;
  }

  image(buffer, x, y, w, h);

  pt.display(0, 0);
}

void computeBuffer(PGraphics b, ArrayList<PVector> vList) {
  b.stroke(255);
  b.noFill();
  b.beginShape(TRIANGLES);
  for (int i=3*7; i<vList.size(); i+=3) {
    PVector v1 = vList.get(i);
    PVector v2 = vList.get(i+1);
    PVector v3 = vList.get(i+2);

    //float normi = (float)i / (float)vList.size();

    b.stroke(0.0, 0.0, 1.0);//, v1.z);

    b.vertex(v1.x, v1.y);
    b.vertex(v2.x, v2.y);
    b.vertex(v3.x, v3.y);
  }
  b.endShape();
}

void subdivOnTwo(PVector A, PVector B, PVector C, int iteration) {
  if (iteration <= 0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
  } else {
    float ratio = 1.0 / 3.0;
    float rand = random(1.0);
    PVector center = new PVector();
    if (rand <= ratio) {
      center = getCenter(A, B);
    } else if (rand <= ratio * 2.0) {
      center = getCenter(B, C);
    } else {
      center = getCenter(C, A);
    }

    println("\tSubdiv "+iteration+" done");
    iteration --;
    subdivOnTwo(A, B, center, iteration);
    subdivOnTwo(A, center, C, iteration);
    subdivOnTwo(center, B, C, iteration);
  }
}


void subdivGravityCenter(PVector A, PVector B, PVector C, int iteration) {
  if (iteration <= 0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
  } else {
    PVector gravity = getGravityCenter(A, B, C);

    println("\tSubdiv "+iteration+" done");
    iteration --;
    subdivGravityCenter(gravity, A, B, iteration);
    subdivGravityCenter(gravity, B, C, iteration);
    subdivGravityCenter(gravity, C, A, iteration);
  }
}

void subdivGravityCenterInside(PVector A, PVector B, PVector C, int iteration, float insideOffset, float maxIteration) {
  if (iteration <= 0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
  } else {
    PVector gravity = getGravityCenter(A, B, C);

    PVector gABG = getGravityCenter(A, B, gravity);
    PVector gAGC = getGravityCenter(A, gravity, C);
    PVector gGBC = getGravityCenter(gravity, B, C);


    PVector AtoABG = PVector.sub(gABG, A);
    PVector BtoABG = PVector.sub(gABG, B);
    PVector GtoABG = PVector.sub(gABG, gravity);

    PVector AtoAGC = PVector.sub(gAGC, A);
    PVector GtoAGC = PVector.sub(gAGC, gravity);
    PVector CtoAGC = PVector.sub(gAGC, C);

    PVector GtoGBC = PVector.sub(gGBC, gravity);
    PVector BtoGBC = PVector.sub(gGBC, B);
    PVector CtoGBC = PVector.sub(gGBC, C);


    float mAABG = AtoABG.mag();
    float mBABG = BtoABG.mag();
    float mGABG = GtoABG.mag();

    float mAAGC = AtoAGC.mag();
    float mGAGC = GtoAGC.mag();
    float mCAGC = CtoAGC.mag();

    float mGGBC = GtoGBC.mag();
    float mBGBC = BtoGBC.mag();
    float mCGBC = CtoGBC.mag();


    float ni = (float) iteration / maxIteration;


    AtoABG.normalize().mult(mAABG * insideOffset).add(A);
    BtoABG.normalize().mult(mBABG * insideOffset).add(B);
    GtoABG.normalize().mult(mGABG * insideOffset).add(gravity);

    AtoAGC.normalize().mult(mAAGC * insideOffset).add(A);
    GtoAGC.normalize().mult(mGAGC * insideOffset).add(gravity);
    CtoAGC.normalize().mult(mCAGC * insideOffset).add(C);

    GtoGBC.normalize().mult(mGGBC * insideOffset).add(gravity);
    BtoGBC.normalize().mult(mBGBC * insideOffset).add(B);
    CtoGBC.normalize().mult(mCGBC * insideOffset).add(C);

    float ninsideOffset = insideOffset * ni; 

    println("\tSubdiv "+iteration+" done");
    iteration --;
    subdivGravityCenterInside(AtoABG, BtoABG, GtoABG, iteration, ninsideOffset, maxIteration);
    subdivGravityCenterInside(AtoAGC, GtoAGC, CtoAGC, iteration, ninsideOffset, maxIteration);
    subdivGravityCenterInside(GtoGBC, BtoGBC, CtoGBC, iteration, ninsideOffset, maxIteration);
  }
}



void subdivGravityCenterOffset(PVector A, PVector B, PVector C, int iteration, PVector offset, float deviation, float maxIteration) {
  if (iteration <= 0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
  } else {
    PVector gravity = getGravityCenter(A, B, C);
    PVector dev = offset.copy();
    dev.mult(deviation);
    gravity.add(dev);
    float ni =  (float) iteration / maxIteration;
    float ndeviation = deviation * ni;

    println("\tSubdiv "+iteration+" done");
    iteration --;
    subdivGravityCenterOffset(A, B, gravity, iteration, offset, ndeviation, maxIteration);
    subdivGravityCenterOffset(A, gravity, C, iteration, offset, ndeviation, maxIteration);
    subdivGravityCenterOffset(gravity, B, C, iteration, offset, ndeviation, maxIteration);
  }
}


void subdivGravityCenterMediatrice(PVector A, PVector B, PVector C, int iteration, int maxIteration) {
  if (iteration <= 0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
  } else {
    PVector gravity = getGravityCenter(A, B, C);
    PVector AB = getCenter(A, B);
    PVector BC = getCenter(B, C);
    PVector AC = getCenter(A, C);

    println("\tSubdiv "+iteration+" done");
    iteration --;
    subdivGravityCenterMediatrice(A, AB, gravity, iteration, maxIteration);
    subdivGravityCenterMediatrice(AB, B, gravity, iteration, maxIteration);
    subdivGravityCenterMediatrice(A, gravity, AC, iteration, maxIteration);
    subdivGravityCenterMediatrice(AC, gravity, C, iteration, maxIteration);
    subdivGravityCenterMediatrice(gravity, B, BC, iteration, maxIteration);
    subdivGravityCenterMediatrice(gravity, BC, C, iteration, maxIteration);
  }
}

void subdivGravityCenterMediatrice(PVector A, PVector B, PVector C, int iteration, float deviation, float maxIteration) {
  if (iteration <= 0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
  } else {
    PVector gravity = getGravityCenter(A, B, C);
    PVector AB = getCenter(A, B);
    PVector BC = getCenter(B, C);
    PVector AC = getCenter(A, C);

    PVector gAB = PVector.sub(AB, gravity);
    PVector gBC = PVector.sub(BC, gravity);
    PVector gAC = PVector.sub(AC, gravity);

    float gABM = gAB.mag();
    float gBCM = gBC.mag();
    float gACM = gAC.mag();

    gAB.normalize();
    gBC.normalize();
    gAC.normalize();

    float ni =  (float) iteration / maxIteration;
    gAB.mult(deviation * gABM);
    gBC.mult(deviation * gBCM);
    gAC.mult(deviation * gACM);

    gAB.add(AB);
    gBC.add(BC);
    gAC.add(AC);

    float ndeviation = deviation * ni;

    A.z = ni;
    B.z = ni;
    C.z = ni;
    gAB.z = ni;
    gAC.z = ni;
    gBC.z = ni;
    gravity.z = ni;

    println("\tSubdiv "+iteration+" done");
    iteration --;
    subdivGravityCenterMediatrice(A, gAB, gravity, iteration, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(gAB, B, gravity, iteration, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(A, gravity, gAC, iteration, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(gAC, gravity, C, iteration, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(gravity, B, gBC, iteration, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(gravity, gBC, C, iteration, ndeviation, maxIteration);
  }
}

void subdivGravityCenterMediatrice(PVector A, PVector B, PVector C, int iteration, PVector center, float maxDist, float deviation, float maxIteration) {
  if (iteration <= 0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
  } else {
    PVector gravity = getGravityCenter(A, B, C);
    PVector AB = getCenter(A, B);
    PVector BC = getCenter(B, C);
    PVector AC = getCenter(A, C);

    PVector cAB = PVector.sub(AB, center);
    PVector cBC = PVector.sub(BC, center);
    PVector cAC = PVector.sub(AC, center);


    float cABM = cAB.mag()/maxDist;
    float cBCM = cBC.mag()/maxDist;
    float cACM = cAC.mag()/maxDist;

    cAB.normalize();
    cBC.normalize();
    cAC.normalize();

    float ni =  (float) iteration / maxIteration;
    cAB.mult(deviation * cABM);
    cBC.mult(deviation * cBCM);
    cAC.mult(deviation * cACM);

    cAB.add(AB);
    cBC.add(BC);
    cAC.add(AC);

    float ndeviation = deviation * ni;

    println("\tSubdiv "+iteration+" done");
    iteration --;
    subdivGravityCenterMediatrice(A, cAB, gravity, iteration, center, maxDist, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(cAB, B, gravity, iteration, center, maxDist, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(A, gravity, cAC, iteration, center, maxDist, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(cAC, gravity, C, iteration, center, maxDist, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(gravity, B, cBC, iteration, center, maxDist, ndeviation, maxIteration);
    subdivGravityCenterMediatrice(gravity, cBC, C, iteration, center, maxDist, ndeviation, maxIteration);
  }
}


void subdivMediatrice(PVector A, PVector B, PVector C, int iteration) {
  if (iteration <= 0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
  } else {
    PVector AB = getCenter(A, B);
    PVector BC = getCenter(B, C);
    PVector AC = getCenter(A, C);

    println("\tSubdiv "+iteration+" done");
    iteration --;
    subdivMediatrice(A, AB, AC, iteration);
    subdivMediatrice(AB, B, BC, iteration);
    subdivMediatrice(BC, C, AC, iteration);
    subdivMediatrice(AB, BC, AC, iteration);
  }
}


PVector getGravityCenter(PVector A, PVector B, PVector C) {
  PVector gravity = new PVector();
  gravity.add(A);
  gravity.add(B);
  gravity.add(C);
  gravity.div(3);
  return gravity;
}

PVector getCenter(PVector A, PVector B) {
  PVector gravity = new PVector();
  gravity.add(A);
  gravity.add(B);
  gravity.div(2);
  return gravity;
}

ArrayList<PVector> computeLaplacianSmooth(ArrayList<PVector> list, float desiredDistance) {
  ArrayList<PVector> smoothedNodeList = new ArrayList<PVector>();
  for (int i=0; i<list.size(); i++) {
    PVector vert = list.get(i);
    PVector nvert = new PVector();

    Rectangle range = new Rectangle(vert.x, vert.y, desiredDistance, desiredDistance);
    ArrayList<PVector> neighList = quadtree.query(range);
    float factor = 1.0 / neighList.size();
    for (PVector neighbor : neighList) {
      nvert.add(neighbor);
    }

    nvert.mult(factor);


    smoothedNodeList.add(nvert);
  }

  return smoothedNodeList;
}
