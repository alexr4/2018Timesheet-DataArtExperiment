/**
 * This example show how to use the PerfTracker object 
 * in order to automatically track FPS, Millis and Memory of your program.
 * Click on the PerfTracker object to change the tracking display (FPS, MS, MB)
 */

import fpstracker.core.*;

PerfTracker pt;
ArrayList<Node> nodes;
PGraphics current, previous;
PGraphics datamosh;
PShader shader;


float i, j, k;

void settings() {
  float res= 16.0/9.0;
  size(1000, 1000, P2D);
  smooth(8);
}

void setup() {  
  surface.setLocation(1920/2 - width/2, 0);
  //instanciate PerfTracker object public PerfTracker(PApplet context, int samplingSize)
  pt = new PerfTracker(this, 100);

  nodes = new ArrayList<Node>();
  float goldenRatio = (1.0 + sqrt(5.0))/2.0;
  float constant = 10.0;
  int nbElement = 1000;
  for (int i=0; i<nbElement; i++) {
    float noiseijk = noise(i * 0.01, j, k);
    
    float angle = i * goldenRatio;
    float radius = constant * sqrt(i);
    
    float x = cos(angle) * radius + width * 0.5;
    float y = sin(angle) * radius + height * 0.5;
    Node node = new Node(new PVector(x, y), noiseijk * 25.0);
    nodes.add(node);
    j += 0.025;
    k += 0.015;
  }

  //pt.setUIComputation(false);
  //you can disable the UI Pannel drawing if you want to only use data as string
  println(pt.getLibraryInfos());

  datamosh = createGraphics(width, height, P2D);
  current = createGraphics(width, height, P2D);
  previous = createGraphics(width, height, P2D);
  shader = loadShader("datamosh3x3-5x5.glsl");
  shader.set("resolution", (float)width, (float)height);
}

void draw() {
  background(0);
  float nCount = 0.0;

  current.beginDraw();
  current.background(0);
  for (Node node : nodes) {
    node.separate(nodes);
    node.stopIfNoNeighbors(nodes, 0.0);
    node.update();
    node.display(current);

    nCount += node.neiCount;
  }
  current.endDraw();

  nCount /= nodes.size() * nodes.size();
  nCount = 1.0 - nCount;
  float easing = NormalEasing.inExp(nCount);

  float threshold = noise(millis() * 0.0001, frameCount * 0.01) * 0.15;
  float offsetRGB = noise(frameCount * 0.0125, millis() * 0.005) * 0.005;

  shader.set("previous", datamosh);
  shader.set("threshold", lerp(threshold, 0.5, easing));//threshold * nCount);
  shader.set("offsetRGB", offsetRGB);

  datamosh.beginDraw();
  datamosh.shader(shader);
  datamosh.image(current, 0, 0);
  datamosh.endDraw();
/*
  previous.beginDraw();
  previous.image(datamosh, 0, 0, previous.width, previous.height);
  //previous.image(current, 0, 0, previous.width, previous.height);
  previous.endDraw();*/


  image(datamosh, 0, 0);

  pt.display(0, 0); //display the actual tracker (default is FPS)
}
