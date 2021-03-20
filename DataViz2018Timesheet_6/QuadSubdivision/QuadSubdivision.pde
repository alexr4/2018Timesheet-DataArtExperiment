import fpstracker.core.*;
import processing.svg.*;

PerfTracker pt;
ArrayList<PVector> vertList;
float thetaInc, radius, ox, oy;
PGraphics buffer;
boolean isComputed;


void settings() {
  size(1000, 1000, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);
  
  computeShape(10);
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

void computeShape(int it) {
  buffer = createGraphics(7000, 7000, P2D); 
  buffer.smooth();

  vertList = new ArrayList<PVector>();

  thetaInc = TWO_PI/4.0;
  radius = buffer.width * 0.35;
  ox = buffer.width * 0.5;
  oy = buffer.height * 0.5;

  for (int i=0; i<4; i++) {
    float theta = i * thetaInc;
    float x = cos(theta + HALF_PI * 0.5) * radius + ox;
    float y = sin(theta + HALF_PI * 0.5) * radius + oy;
    vertList.add(new PVector(x, y));
  }
  println("verList initialized");

  PVector A = vertList.get(0);
  PVector B = vertList.get(1);
  PVector C = vertList.get(2);  
  PVector D = vertList.get(3);

  subdivQuad(A, B, C, D, it, it, 0.3, 0.15);
  println("Subdiv done");

  buffer.beginDraw();
  buffer.background(0);
  computeBuffer(buffer, vertList);
  buffer.endDraw();
  println("Buffer computed");

  //exportSVG("shape", vertList, buffer.width, buffer.height);
}

void computeBuffer(PGraphics b, ArrayList<PVector> vList) {
  b.stroke(255, 50);
  b.noFill();
  b.beginShape(QUADS);
  for (int i=4; i<vList.size(); i+=4) {
    PVector v1 = vList.get(i);
    PVector v2 = vList.get(i+1);
    PVector v3 = vList.get(i+2);
    PVector v4 = vList.get(i+3);

    b.vertex(v1.x, v1.y);
    b.vertex(v2.x, v2.y);
    b.vertex(v3.x, v3.y);
    b.vertex(v4.x, v4.y);
  }
  b.endShape();
}

void subdivQuad(PVector A, PVector B, PVector C, PVector D, int iteration, int maxIteration, float deviation, float subDeviation) {
  if (iteration <=0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
    vertList.add(D);
  } else {
    PVector gravity = getCenter(A, C);
    PVector AB = getCenter(A, B);
    PVector BC = getCenter(B, C);
    PVector CD = getCenter(C, D);
    PVector DA = getCenter(D, A);

    PVector offset = PVector.sub(A, gravity);
    PVector AC = PVector.sub(A, C);
    float maxDeviation = AC.mag() * 0.5;
    float dev = deviation;
    if (iteration == maxIteration) {
      dev = 0;
    }
    float deviationSub = subDeviation;      
    offset.normalize().mult(-maxDeviation * dev);
    gravity.add(offset);

    /*
    PVector AG = PVector.sub(A, gravity).normalize().mult(maxDeviation * devitation * deviationSub); 
     PVector BG = PVector.sub(B, gravity).normalize().mult(maxDeviation * devitation * deviationSub);
     PVector CG = PVector.sub(C, gravity).normalize().mult(maxDeviation * devitation * deviationSub);
     PVector DG = PVector.sub(D, gravity).normalize().mult(maxDeviation * devitation * deviationSub);
     
     PVector gravityA = gravity.copy().add(AG);
     PVector gravityB = gravity.copy().add(BG);
     PVector gravityC = gravity.copy().add(CG);
     PVector gravityD = gravity.copy().add(DG);
     */

    PVector AAB = PVector.sub(A, AB).normalize();
    PVector BAB = AAB.copy().mult(-1);
    PVector BBC = PVector.sub(B, BC).normalize();
    PVector CBC = BBC.copy().mult(-1);
    PVector CCD = PVector.sub(C, CD).normalize();
    PVector DCD = CCD.copy().mult(-1);
    PVector DDA = PVector.sub(D, DA).normalize();
    PVector ADA = DDA.copy().mult(-1);

    AAB.mult(maxDeviation * deviationSub);
    BAB.mult(maxDeviation * deviationSub);
    BBC.mult(maxDeviation * deviationSub);
    CBC.mult(maxDeviation * deviationSub);
    CCD.mult(maxDeviation * deviationSub);
    DCD.mult(maxDeviation * deviationSub);
    DDA.mult(maxDeviation * deviationSub);
    ADA.mult(maxDeviation * deviationSub);

    AAB.add(AB);
    BAB.add(AB);
    BBC.add(BC);
    CBC.add(BC);
    CCD.add(CD);
    DCD.add(CD);
    DDA.add(DA);
    ADA.add(DA);

    PVector GAAB = PVector.sub(AAB, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GBAB = PVector.sub(BAB, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GBBC = PVector.sub(BBC, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GCBC = PVector.sub(CBC, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GCCD = PVector.sub(CCD, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GDCD = PVector.sub(DCD, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GDDA = PVector.sub(DDA, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GADA = PVector.sub(ADA, gravity).normalize().mult(maxDeviation * deviationSub);

    AAB.add(GAAB);  
    BAB.add(GBAB);
    BBC.add(GBBC);
    CBC.add(GCBC);
    CCD.add(GCCD);
    DCD.add(GDCD);
    DDA.add(GDDA);
    ADA.add(GADA);

    iteration --;
    subdivQuad(gravity, BAB, B, BBC, iteration, maxIteration, deviation, deviationSub);
    subdivQuad(gravity, CBC, C, CCD, iteration, maxIteration, deviation, deviationSub);
    subdivQuad(gravity, DCD, D, DDA, iteration, maxIteration, deviation, deviationSub);
    subdivQuad(gravity, ADA, A, AAB, iteration, maxIteration, deviation, deviationSub);
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

void exportSVG(String name, ArrayList<PVector> vList, int w, int h) {
  String exportName = name+".svg";
  PGraphics pg = createGraphics(w, h, SVG, exportName);
  pg.beginDraw();
  pg.stroke(255, 50);
  pg.noFill();
  pg.beginShape(QUADS);
  for (int i=4; i<vList.size(); i+=4) {
    PVector v1 = vList.get(i);
    PVector v2 = vList.get(i+1);
    PVector v3 = vList.get(i+2);
    PVector v4 = vList.get(i+3);

    pg.vertex(v1.x, v1.y);
    pg.vertex(v2.x, v2.y);
    pg.vertex(v3.x, v3.y);
    pg.vertex(v4.x, v4.y);
  }
  pg.endShape();
  pg.endDraw();
  pg.dispose();
  println(exportName + " svg saved.");
}
