import fpstracker.core.*;

PerfTracker pt;
PShader sdfshader;
PShader voronoishader;
PGraphics samples;
PGraphics gpusdf;
PGraphics voronoigraphics;


void settings() {
  int s = 512;
  size(s*3, s, P2D);
}

void setup() {
  pt = new PerfTracker(this, 100);
  sdfshader = loadShader("sdfImage.glsl");
  voronoishader = loadShader("vornoisdf.glsl");
  int w = 2000;
  samples = generateSample(w, w, 200, 100);
  gpusdf = createGraphics(samples.width, samples.height, P2D);
  voronoigraphics =  createGraphics(samples.width, samples.height, P2D);

  computeGPUSDF(samples, gpusdf, 100);
  computeVoronoi(gpusdf, voronoigraphics);
  surface.setLocation(0, 0);
}

void draw() {
  image(samples, 0, 0, width/3, height);
  image(gpusdf, width/3, 0, width/3, height);
  image(voronoigraphics, width/3.0 * 2.0, 0, width/3, height);
  pt.display(0, 0);
}

void keyPressed() {
  save("frame");
  samples.save("samples.png");
  gpusdf.save("gpusdf.tif");
  voronoigraphics.save("voronoigraphics.tif");
}

void computeGPUSDF(PImage in, PGraphics out, int searchDistance) {
  sdfshader.set("searchDistance", searchDistance);
  sdfshader.set("resolution", (float) in.width, (float) in.height);
  out.beginDraw();
  out.shader(sdfshader);
  out.image(in, 0, 0);
  out.endDraw();
}

void computeVoronoi(PImage in, PGraphics out) {
  float time = (float) millis() /1000.0;
  // println(time);
  voronoishader.set("resolution", (float) in.width, (float) in.height);
  voronoishader.set("time", time);
  float mx = map(mouseX, width/3 * 2, width, 0.0, 1.0);
  float my = map(mouseY, 0, height, 1.0, 0.0);
  voronoishader.set("mouse", mx, my);
  out.beginDraw();
  out.shader(voronoishader);
  out.image(in, 0, 0);
  out.endDraw();
}

private PGraphics generateSample(int w, int h, int nbSamples, int samplesSize) {
  PGraphics buffer = createGraphics(w, h, P2D);

  buffer.smooth(8);
  buffer.beginDraw();
  buffer.background(0);
  buffer.noStroke();
  buffer.fill(255);
  for (int i=0; i<nbSamples; i++) {
    float angle = random(TWO_PI);
    float rad = random(buffer.width * 0.35);

    //float angle = noise(i) * TWO_PI;
    //float rad = noise(i) * buffer.width * 0.35;

    float x = cos(angle) * rad + buffer.width/2;
    float y = sin(angle) * rad + buffer.width/2;
    float r = random(samplesSize, samplesSize * 8.0);
    float ly0 = random(buffer.height);
    float ly1 = random(buffer.height);
    float lx0 = random(buffer.width);
    float lx1 = random(buffer.width);

    float tLx = random(0, -1.0);
    float tLy = random(0, -1.0);
    float tRx = random(0, 1.0);
    float tRy = random(0, -1.0);
    float bRx = random(0, 1.0);
    float bRy = random(0, 1.0);
    float bLx = random(0, -1.0);
    float bLy = random(0, 1.0);
    float quadSize = samplesSize;


    //line
    //// buffer.stroke(255);
    // buffer.strokeWeight(1);
    //buffer.line(lx0, ly0, lx1, ly1);
    //buffer.line(buffer.width/2, buffer.height/2, x, y);
    /*
    //triangle
     buffer.pushMatrix();
     buffer.translate(x,y);
     buffer.rotate(angle + HALF_PI + random(PI));
     buffer.triangle(0, samplesSize, samplesSize*0.5, 0, -samplesSize*0.5, 0.0);
     buffer.popMatrix();
     */
    //quad

    buffer.pushMatrix();
    buffer.translate(x, y);
    buffer.rotate(angle + HALF_PI + random(PI));
    buffer.quad(tLx * quadSize, tLy * quadSize, 
      tRx * quadSize, tRy * quadSize, 
      bRx * quadSize, bRy * quadSize, 
      bLx * quadSize, bLy * quadSize);
    buffer.popMatrix();

    //elipse
    // buffer.ellipse(x, y, samplesSize, samplesSize);
  }
  buffer.endDraw();

  return buffer;
}
