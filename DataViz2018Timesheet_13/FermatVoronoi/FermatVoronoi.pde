/**
 * This example show how to use the PerfTracker object 
 * in order to automatically track FPS, Millis and Memory of your program.
 * Click on the PerfTracker object to change the tracking display (FPS, MS, MB)
 */

import fpstracker.core.*;
import processing.svg.*;

PerfTracker pt;
PShader voronoi;
PGraphics buffer;
PVector[] array;
boolean zoom;

void settings() {
  float res= 50.0/70.0;
  int h = 1000;
  int w = int(h * res);
  size(w, h, P2D);
  smooth(8);
}

void setup() {  
  pt = new PerfTracker(this, 100);
  background(0);

  float goldenRatio = (3.0 + sqrt(5.0))/2.0;
  float constant = 600/10;

  float dataPerMonth = 31 * 10;//hourPerWeek * 4.0;
  println(dataPerMonth);
  array = new PVector[(int)dataPerMonth];
  voronoi = loadShader("voronoiArray.glsl");

  float res= 50.0/70.0;
  int w = 8000;
  int h = int(w / res);
  buffer = createGraphics(w, h, P2D);

  println(int(dataPerMonth));
  fill(255);
  noStroke();
  noFill();
  for (int i=0; i<int(dataPerMonth); i++) {
    float angle = (i/100.0) * (TWO_PI * goldenRatio);
    float radius = constant * sqrt(i);

    float x = cos(angle) * radius + buffer.width * 0.5;
    float y = sin(angle) * radius + buffer.height * 0.5;
    float z = random(1.0);

    array[i] = new PVector(x, y, z);
  }/*
  voronoi.set("fermat", getDataForBinding());
   voronoi.set("maxElements", int(dataPerMonth) * 3);
   voronoi.set("resolution", (float)width, (float)height);
   buffer.beginDraw();
   buffer.background(0);
   buffer.shader(voronoi);
   buffer.rect(0, 0, buffer.width, buffer.height);
   buffer.endDraw();*/
}

void draw() {
  background(0);

  //imageMode(CENTER);
  int w = width;
  int h = height;
  if (zoom) {
    w = buffer.width;
    h = buffer.height;
  }
  // image(buffer, width*0.5, height*0.5, w, h);


  fill(255, 0, 0);
  noStroke();
  for (int i=0; i<array.length; i+=10) {
    float ni = float(i)/float(array.length);
    PVector v = array[i];
    float x = (v.x / buffer.width) * w - (w-width) * 0.5;
    float y = (v.y / buffer.height) * h - (h-height) * 0.5;
    fill(55 + 200 * ni);
    ellipse(x, y, 10, 10);
  }

  beginShape();
  noFill();
  for (int i=0; i<array.length; i++) {
    float ni = float(i)/float(array.length);
    PVector v = array[i];
    float x = (v.x / buffer.width) * w - (w-width) * 0.5;
    float y = (v.y / buffer.height) * h - (h-height) * 0.5;
    stroke(55 + 200 * ni);
    vertex(x, y);
  }
  endShape();

  pt.display(0, 0); //display the actual tracker (default is FPS)*/
}

float[] getDataForBinding() {
  float[] dataList = new float[array.length * 3];
  for (int i=0; i<array.length; i++) {
    float dataX = array[i].x;
    float dataY = array[i].y;
    float dataZ = array[i].z;
    dataList[i * 3] = dataX;
    dataList[i * 3 + 1] = dataY;
    dataList[i * 3 + 2] = dataZ;
  }

  return dataList;
}


void mouseReleased() {
  zoom = !zoom;
}

void keyPressed() {
  String it = year()+""+month()+""+day()+""+hour()+""+minute()+""+millis(); 
  /*
  buffer.beginDraw();
   buffer.background(0);
   buffer.shader(voronoi);
   buffer.rect(0, 0, buffer.width, buffer.height);
   buffer.endDraw();
   buffer.save("voro-"+it);
   */
  exportSVG("voron-"+it, width, height);
}

void exportSVG(String name, int w, int h) {
  String exportName = name+".svg";
  PGraphics pg = createGraphics(w, h, SVG, exportName);
  pg.beginDraw();
  pg.strokeCap(ROUND);

  int w_ = width;
  int h_ = height;
  if (zoom) {
    w = buffer.width;
    h = buffer.height;
  }
  // image(buffer, width*0.5, height*0.5, w, h);


  pg.fill(255, 0, 0);
  pg.noStroke();
  for (int i=0; i<array.length; i+=10) {
    float ni = float(i)/float(array.length);
    PVector v = array[i];
    float x = (v.x / buffer.width) * w_ - (w_-w) * 0.5;
    float y = (v.y / buffer.height) * h_ - (h_-h) * 0.5;
    pg.fill(55 + 200 * ni);
    pg.ellipse(x, y, 10, 10);
  }

  pg.beginShape();
  pg.noFill();
  for (int i=0; i<array.length; i++) {
    float ni = float(i)/float(array.length);
    PVector v = array[i];
    float x = (v.x / buffer.width) * w - (w-width) * 0.5;
    float y = (v.y / buffer.height) * h - (h-height) * 0.5;
    pg.stroke(55 + 200 * ni);
    pg.vertex(x, y);
  }
  pg.endShape();


  pg.endDraw();
  pg.dispose();
  println(" saved.");
}
