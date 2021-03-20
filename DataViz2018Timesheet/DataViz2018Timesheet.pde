import fpstracker.core.*;
import gpuimage.core.*;
PerfTracker pt;
Filter filter, filterPP;
Compositor comp;

ArrayList<DayDatas> datalist;
DayDatas based;

PGraphics dataviz;
PGraphics datavizPP;
PGraphics dataInfo;
PGraphics datavizCompo;
PGraphics dataPostProcess;
PGraphics dataPostProcessCompo;
PFont font;

PShader postProcess;
boolean isComputed;

float res = 2.55;

void settings() {
  res = (50.0 / 70.0);
  int h = 1000;
  int w = int(h*res);
  size(w, h, P2D);
}

void setup() {
  pt = new PerfTracker(this, 100);


  datalist = new ArrayList<DayDatas>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  println("List has : "+f.size()+" files");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }

  based = new DayDatas(2018, "Janvier", "01/01/2018", "lundi", "10:00:00", "12:00:00", "13:00:00", "18:00:00");

  int h = 6000;
  int w = int(h * res);
  dataviz = createGraphics(w, h, P2D);
  dataInfo = createGraphics(w, h, P2D);
  datavizCompo = createGraphics(w, h, P2D);
  dataPostProcess = createGraphics(w, h, P2D);
  dataPostProcessCompo = createGraphics(w, h, P2D);
  filter = new Filter(this, dataviz.width, dataviz.height);
  filterPP = new Filter(this, dataviz.width, dataviz.height);
  comp = new Compositor(this, dataviz.width, dataviz.height);

  String[] fontList = PFont.list();
  printArray(fontList); //397
  font = createFont("MonumentExtended-Ultrabold.otf", 20);
  dataInfo.smooth(8);

  postProcess = loadShader("postprocess.glsl");
  postProcess.set("start", based.fstart);
  postProcess.set("end", based.fend);
  postProcess.set("startlunch", based.fslunch);
  postProcess.set("endlunch", based.felunch);
  postProcess.set("resolution", (float) dataviz.width, (float) dataviz.height);
  PImage ramp = loadImage("ramp.png");
  postProcess.set("ramp", ramp);

  surface.setLocation(0, 0);
}

void draw() {
  background(127);

  if (!isComputed) {
    computeDataViz(dataviz);
    computeDataInfo(dataInfo);
    datavizPP = filter.getCustomFilter(dataviz, postProcess);
    computeFinalBuffer(datavizCompo, datavizPP, dataInfo, 1.0);

    float cx = dataPostProcess.width/2;
    float cy = dataPostProcess.height/2;
    float size = 0.025;


    dataPostProcess = filterPP.getChromaWarpHighImage(datavizCompo, cx, cy, size * 0.1, (HALF_PI / 50.0) * size);
    //1- High pass the source image
    dataPostProcessCompo = filter.getHighPassImage(dataPostProcess, 5.0);
    //2- Desaturate the result image
    dataPostProcessCompo = filter.getDesaturateImage(dataPostProcessCompo, 100.0);
    //3- Compose it with the source image as overlay
    datavizCompo = comp.getBlendOverlayImage(dataPostProcessCompo, dataPostProcess, 100.0);
    dataPostProcess = filterPP.getGrainRGBImage(datavizCompo, 0.025);
    isComputed = true;
  }

  float x =  width/2;
  float y = height/2;
  float w = width;
  float h = height;

  if (mousePressed) {
    x -= (norm(mouseX, 0.0, width) * 2.0 - 1.0) * (datavizPP.width * 0.5);
    y -= (norm(mouseY, 0.0, height) * 2.0 - 1.0) * (datavizPP.height * 0.5);
    w = datavizPP.width;
    h = datavizPP.height;
  }

  imageMode(CENTER);
  image(dataPostProcess, x, y, w, h);

  pt.display(0, 0);
}


void loadCSV(String datafile) {
  Table table = loadTable(datafile, "header");
  println(table.getRowCount() + " total rows in table"); 

  for (TableRow row : table.rows()) {
    //Month,Weekday,Day,Start day,Break Lunch Start,Break Lunch End,End Day
    String month = row.getString("Month");
    String weekday = row.getString("Weekday");
    String day = row.getString("Day");

    String start = row.getString("Start day");
    String slunch = row.getString("Break Lunch Start");
    String elunch = row.getString("Break Lunch End");
    String end = row.getString("End Day");
    //println(month+" : "+weekday+" : "+day+"\t s:"+start+" : "+slunch+" : "+elunch+" : "+end);

    DayDatas data = new DayDatas(2018, month, day, weekday, start, slunch, elunch, end);
    datalist.add(data);
  }
}

void computeDataViz(PGraphics buffer) {
  buffer.beginDraw();

  buffer.background(0.0);

  float res = (float)buffer.height/(float)datalist.size();
  float margin = res * 0.2;
  buffer.rectMode(CORNERS);
  buffer.noStroke();
  for (int i=0; i<datalist.size(); i++) {
    DayDatas data = datalist.get(i);
    float y = res * i + margin;
    float yn = res * (i+1) - margin;

    float morningstart = data.fstart * buffer.width;
    float morningend =  data.fslunch * buffer.width;

    float afternoonstart = data.felunch * buffer.width;
    float afternoonend =  data.fend * buffer.width;

    float weeknorm = data.iday / 31.0;
    float weekdaynorm = data.iweekday / 7.0;


    dataviz.fill(255, weeknorm * 255, weekdaynorm * 255);
    if (data.isSup) {
      float supstart = data.fsstart * buffer.width;
      float supend =  data.fsend * buffer.width;
      buffer.beginShape(QUADS);
      buffer.vertex(supend, y);
      buffer.vertex(supend, yn);
      buffer.vertex(supstart, yn);
      buffer.vertex(supstart, y);
      buffer.endShape();
    }

    buffer.beginShape(QUADS);
    buffer.vertex(morningend, y);
    buffer.vertex(morningend, yn);
    buffer.vertex(morningstart, yn);
    buffer.vertex(morningstart, y);
    buffer.endShape();

    dataviz.beginShape(QUADS);
    dataviz.vertex(afternoonend, y);
    dataviz.vertex(afternoonend, yn);
    dataviz.vertex(afternoonstart, yn);
    dataviz.vertex(afternoonstart, y);
    dataviz.endShape();
  }

  //buffer.stroke(0.5, 1.0, 1.0);
  //buffer.line(based.fstart * buffer.width, 0, based.fstart * buffer.width, buffer.height);
  //buffer.line(based.fend * buffer.width, 0, based.fend * buffer.width, buffer.height);
  buffer.endDraw();
}

void computeDataInfo(PGraphics buffer) {
  buffer.beginDraw();

  buffer.background(0.0, 1.0);
  buffer.textMode(SHAPE);

  buffer.textFont(font);
  buffer.stroke(255);
  buffer.line(based.fstart * buffer.width, 0.0, based.fstart * buffer.width, buffer.height);
  buffer.line(based.fend * buffer.width, 0.0, based.fend * buffer.width, buffer.height);

  buffer.noStroke();
  buffer.fill(255, 120);
  buffer.textSize(60);
  buffer.textAlign(RIGHT, CENTER);
  buffer.text("10:00", based.fstart * buffer.width - 40, 40);
  buffer.textAlign(LEFT, CENTER);
  buffer.text("18:00", based.fend * buffer.width + 40, 40);

  buffer.textSize(120);
  buffer.textAlign(LEFT, CENTER);

  float res = (float)buffer.height/(float)datalist.size();
  float monthrest = (float)buffer.height/12.0;
  int month = 0;
  buffer.noStroke();
  for (int i=0; i<datalist.size(); i++) {
    DayDatas data = datalist.get(i);
    float y = res * i;

    int imonth = data.imonth;
    if (month != imonth) {
      float ty = y + 120 * 1.5;
      month = imonth;
      buffer.stroke(255);
      buffer.line(0, y, buffer.width, y);
      buffer.fill(255, 80);
      buffer.noStroke();
      buffer.text(data.month.toLowerCase(), buffer.width/12.5, ty);
    }
  }


  buffer.endDraw();
}

void computeFinalBuffer(PGraphics buffer, PGraphics back, PGraphics front, float scale) {
  buffer.beginDraw();
  buffer.background(0.0);
  buffer.imageMode(CENTER);
  buffer.image(back, buffer.width/2.0, buffer.height/2.0, buffer.width * scale, buffer.height * scale);
  buffer.image(front, buffer.width/2.0, buffer.height/2.0, buffer.width * scale, buffer.height * scale);
  buffer.endDraw();
}

void keyPressed() {
  if (key == 's') {
    dataPostProcess.save("data_NB"+hour()+""+minute()+""+second()+""+millis()+".png");
    println("image has been saved");
  }
}
