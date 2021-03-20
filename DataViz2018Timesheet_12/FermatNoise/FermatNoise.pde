/**
 * This example show how to use the PerfTracker object 
 * in order to automatically track FPS, Millis and Memory of your program.
 * Click on the PerfTracker object to change the tracking display (FPS, MS, MB)
 */

import fpstracker.core.*;

PerfTracker pt;



void settings() {
  float res= 16.0/9.0;
  size(1000, 1000, P2D);
  smooth(8);
}

void setup() {  
  pt = new PerfTracker(this, 100);
  background(0);

  float goldenRatio = (3.0 + sqrt(5.0))/2.0;
  float constant = 15;

  float hourPerWeek = 60;//random(10, 60);
  float hourPerMonth = hourPerWeek * 4.0;

  fill(255);
  noStroke();
  noFill();
  colorMode(HSB, 1.0, 1.0, 1.0);
  beginShape(); 
  for (int i=0; i<int(hourPerMonth); i++) {
    float ni  = i / hourPerMonth;
    float angle = i * (TWO_PI * goldenRatio);
    float normAngle = (angle%TWO_PI)/TWO_PI;
    float offset = map(sin(normAngle * PI * 10.0), -1.0, 1.0, 1.0, 1.25);
    float radius = (constant * sqrt(i)) * offset;
    float x = cos(angle) * radius + width * 0.5;
    float y = sin(angle) * radius + height * 0.5;
    
    float d = dist(x, y, width * 0.5, height * 0.5) / (width * 0.25);
   // d = d * 0.5 + 0.5;
    float noise = noise(x * 0.01, y * 0.01, normAngle * 4.0);// * 200.0;
   // x = cos(angle) * (radius + noise) + width * 0.5;
    //y = sin(angle) * (radius + noise) + height * 0.5;
    fill(ni, 0.0, 1.0);
    ellipse(x, y, constant * 0.25, constant * 0.25);
    //stroke(ni, 1.0, 1.0);
    //vertex(x, y);
  }
  endShape();
}

void draw() {


  pt.display(0, 0); //display the actual tracker (default is FPS)
}
