import fpstracker.core.*;
import processing.svg.*;
import java.util.*;

PerfTracker pt;
Veneation veneation;


//Buffer
PGraphics buffer;
boolean isComputed;

void settings() {
  //size(1000, 1000, FX2D);
  size(500, 500, P2D);
  smooth(8);
}

void setup() {
  colorMode(HSB, TWO_PI, 1.0, 1.0, 1.0);
  frameRate(300);
  buffer = createGraphics(width, height, P2D);

  pt = new PerfTracker(this, 100);

  veneation = new Veneation();
}

void draw() {
  background(0);

  veneation.grow();

  veneation.debugPoint(g, veneation.nodeList, 2);
  veneation.debugBranch(g, veneation.branchList, color(1.0, 0.0, 1.0, 1.0));

  if (veneation.nodeList.size() <= 0) {
    if (!isComputed) {
      println("Growth is finished");
      buffer.beginDraw();
      buffer.background(0);
      veneation.debugBranch(buffer, veneation.branchList, color(255));
      buffer.endDraw();

      //String it = "DataViz2018_"+year()+""+month()+""+day()+""+hour()+""+minute()+""+millis();
      //buffer.save("buffer_"+it+".tif");
      isComputed = true;
      println("Buffer is saved");
    }
  }

  pt.display(0, 0);
}
