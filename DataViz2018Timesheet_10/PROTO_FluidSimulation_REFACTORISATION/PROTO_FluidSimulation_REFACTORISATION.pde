// Based of D.Shiffman tutorial : https://www.youtube.com/watch?v=alhpH6ECFvQ&list=WL&index=7&t=0s
// Check all the sources in video description

import fpstracker.core.*;

PerfTracker pt;

final int N = 32 * 4;
final int scale = 6;
final int iter = 4;

boolean isLoop;
Fluid fluid;

void settings() {
  size(N * scale, N * scale, P2D);
  smooth();
}

void setup() {
  pt = new PerfTracker(this, 100);

  fluid = new Fluid(0.001, 0.001, 0.001);//0.001, 0.001);
  /*
  for (int i=0; i<25; i++) {
   int nb = (int)random(10, 100);
   int enviro = (int)random(10, 25);
   addRandomTurb(nb, enviro);
   }
   
   for (int i=0; i<100; i++) {
   fluid.step();
   }
   
   background(0);
   fluid.renderVelocity(0.00, 0.25); 
   save("buffer");*/
}

void draw() {
  background(0);
  float radius = width * 0.25;
  float mt = 4.0;
  float t = millis()/1000;
  float modt = t % mt;
  float normt = modt/mt;

  if (normt < 0.1) {
    if (!isLoop) {
      for (int i=0; i<30; i++) {
        int nb = (int)random(10, 100);
        int enviro = (int)random(10, 25);
        //addRandomTurb(nb, nb*2, radius);
        addRandomTurb(4);
      }
      isLoop = true;
    }
  } else {
    isLoop = false;
  }


  fluid.step();
  //fluid.renderDensity(); 
  //fluid.fadeDensity(0.1); 
  //fluid.renderVelocity(0.00, 2.0, radius); 
  fluid.renderVelocity(0.00, 4.0);

  fill(255); 
  text(modt, 20, 100); 

  pt.display(0, 0);
}

void addRandomTurb(int nbTurb, int enviro, float radius) {
  float randAngle = random(TWO_PI);
  float rad = random(radius);
  int cx = (int)(cos(randAngle) * rad + width * 0.5); 
  int cy = (int)(sin(randAngle) * rad + width * 0.5);  
  for (int i=0; i<nbTurb; i++) {
    int displaceX = (int) random(-enviro, enviro); 
    int displaceY = (int) random(-enviro, enviro); 
    int ncx = (cx + displaceX) / scale; 
    int ncy = (cy + displaceY) / scale; 
    fluid.addDensity(ncx, ncy, 500); 

    float angle = random(TWO_PI); 
    PVector v = PVector.fromAngle(angle); 
    v.mult(5.75); 

    fluid.addVelocity(ncx, ncy, v.x, v.y);
  }
}

void addRandomTurb(int nbTurb) {
  for (int i=0; i<nbTurb; i++) {
    int cx = (int)random(width) / scale; 
    int cy = (int)random(height) / scale; 
    fluid.addDensity(cx, cy, 500); 

    float angle = random(TWO_PI); 
    PVector v = PVector.fromAngle(angle); 
    v.mult(5.75); 

    fluid.addVelocity(cx, cy, v.x, v.y);
  }
}

void mousePressed() {
  //addRandomTurb(N*N);
}

void mouseDragged() {
  float amtX = mouseX - pmouseX; 
  float amtY = mouseY - pmouseY; 
  fluid.addDensity(mouseX/scale, mouseY/scale, 100); 
  fluid.addVelocity(mouseX/scale, mouseY/scale, amtX, amtY);
}
