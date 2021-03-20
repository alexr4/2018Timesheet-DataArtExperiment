import fpstracker.core.*;
PerfTracker pt;
PShader shader;

void setup() {
  size(1000, 1000, P2D);
  pt = new PerfTracker(this, 100);
  reloadShader();

  surface.setLocation(40, 40);
}

void draw() {
  try {
    shader.set("mouse", norm(mouseX, 0, width), norm(mouseY, 0, height));
    shader.set("time", millis()/1000.0);
    background(0);
    shader(shader);
    rect(0, 0, width, height);
  }
  catch(Exception e) {
    e.printStackTrace();
  } 
  
  resetShader();
  pt.display(0, 0);
}

void keyPressed() {
  if (key =='r' || key == 'R') {
    reloadShader();
  }
  
  if (key =='s' || key == 'S') {
    save("frame-v.png");
  }
}

void reloadShader() {
  shader = loadShader("voronoi.glsl");
  shader.set("resolution", float(width), float(height));
}
