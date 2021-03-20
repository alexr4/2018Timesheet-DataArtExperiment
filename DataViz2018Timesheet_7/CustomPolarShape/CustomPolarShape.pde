import fpstracker.core.*;

PerfTracker pt;

void setup() {
  size(500, 500);
  smooth(8);


  background(0);
  noStroke();

  int nbEdge = 3;
  float incRadius = TWO_PI / float(nbEdge);

  int nbElement = 8670;
  float incThetaPerElement = TWO_PI / float(nbElement);
  float maxRadius = width;
  for (int i=0; i<nbElement; i++) {
    float theta = i * incThetaPerElement;
    
    //modulate the distance to define the shape

    float radius = random(maxRadius);
    float x = cos(theta) * radius + width * 0.5;    
    float y = sin(theta) * radius + height * 0.5;
    
    float dist = dist(x, y, width*0.5, height*0.5);
    
    float d = cos(floor(0.5 + theta/incRadius) * incRadius - theta) * dist;
    //d = (d >= width * 0.15) ? 0.0 : 1.0;
    d /= maxRadius;
    d = 1.0 - d;
    x = cos(theta) * radius * d + width * 0.5;    
    y = sin(theta) * radius * d + height * 0.5;
    
    fill(255);
    ellipse(x, y, 4, 4);
  }

  pt = new PerfTracker(this, 100);
}
