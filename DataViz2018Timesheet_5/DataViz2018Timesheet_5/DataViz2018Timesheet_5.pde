import fpstracker.core.*;
import processing.svg.*;

PerfTracker pt;

Rectangle aabb;
QuadTree quadtree;

PGraphics dataBuffer;
float resScreen= 50.0 / 70.0; 

//DIFFERENTIAL GROWTH SIMULATION
ArrayList<DGS> dgsdays;
ArrayList<PShape> dgsshapes;

//data
ArrayList<Float> datalist;
ArrayList<HourData> hourdatalist;
boolean isComputed;

void settings() {
  float res = 1.0;
  int w = 700;
  int h = floor(w / resScreen);
  size(w, h, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);
  int w = 5000;
  dataBuffer = createGraphics(w, floor(w/resScreen), P2D);
  dataBuffer.smooth();
  dataBuffer.beginDraw();
  dataBuffer.colorMode(HSB, 1.0, 1.0, 1.0, 1.0);
  dataBuffer.background(0.1);
  dataBuffer.endDraw();

  colorMode(HSB, 1.0, 1.0, 1.0, 1.0);

  //DGS
  aabb = new Rectangle(dataBuffer.width * 0.5, dataBuffer.height * 0.5, dataBuffer.width * 0.5, dataBuffer.height * 0.5);
  quadtree = new QuadTree(aabb, 8);

  dgsdays = new ArrayList<DGS>();
  dgsshapes = new ArrayList<PShape>();

  int nbDay = 7;
  float margin = dataBuffer.width*0.25;
  float x = dataBuffer.width*0.5;
  float res = (dataBuffer.height - margin *2.0)/nbDay;
  for (int i=0; i<nbDay; i++) {
    DGS dgs = new DGS(quadtree);
    //dgs.initAsLine(x, res * i + margin, x, res * (i+1));
    dgs.initAsCircle(x, res * i + res* 0.5 + margin, res * 0.5);
    dgsdays.add(dgs);
  }

  //data
  datalist = new ArrayList<Float>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }

  int inc = 4;
  for (int i=0; i<dgsdays.size(); i++) {
    ArrayList<Float> datas = getDataPerDay(i);
    DGS dgs = dgsdays.get(i);
    dgs.maxNode = ceil(datas.get(0)) * inc;
    println(i, dgs.maxNode * inc);
  }


  frameRate(300);
  background(0.1);
  surface.setLocation(10, 10);
}

void draw() {
  background(0.1);

  String text = "";
  for (int i=0; i<dgsdays.size(); i++) {
    DGS dgs = dgsdays.get(i);
    float normindex = (float) i / (float) dgsdays.size();
    int nbElement = dgs.getNumberOfNode(); 
    if (nbElement < dgs.maxNode) {
      dgs.addRandomNode();
      dgs.run(50.0);
    } else {
      if (!dgs.isComputed) {
        dgs.isComputed = true;
      }
    }
    text += "Differential Growth line "+i+" simulation: "+round((nbElement/dgs.maxNode)*100)+"%\n";
  }

  if (!isComputed) {
    int isAllComputed = 0;
    for (DGS dgs : dgsdays) {
      if (dgs.isComputed) {
        isAllComputed ++;
      }
    }

    if (isAllComputed == dgsdays.size()) {
      for (DGS dgs : dgsdays) {
        dgs.computeLaplacianSmooth(2, 8);
      }
      /*
      ArrayList<Node> finalNodeList = new ArrayList<Node>();
       for (DGS dgs : dgsdays) {
       ArrayList<Node> nodeList = dgs.getNodeList();
       finalNodeList.addAll(nodeList);
       }*/
      String it = "DataViz2018_"+year()+""+month()+""+day()+""+hour()+""+minute()+""+millis();
      exportSVGShape(it, dataBuffer.width, dataBuffer.height, 10.0);
      computeShapes(10.0);
      isComputed = true;
      text+= "everything is computed";
      println("everything is computed");
    }
  }

  dataBuffer.beginDraw();
  dataBuffer.background(0.1);
  for (int i=0; i<dgsdays.size(); i++) {
    DGS dgs = dgsdays.get(i);
    float normindex = (float) i / (float) dgsdays.size();
    if (isComputed) {
      //dgs.computeBuffer(dataBuffer, 10);
      PShape shape = dgsshapes.get(i);
      dataBuffer.shape(shape);
    } else {
      dgs.displayDebug(dataBuffer, normindex, 25.0);
    }
  }
  dataBuffer.endDraw();

  if (mousePressed) {
    imageMode(CENTER);
    image(dataBuffer, norm(mouseX, 0, width) * dataBuffer.width, norm(mouseY, 0, height) * dataBuffer.height);
  } else {
    imageMode(CORNER);
    image(dataBuffer, 0, 0, width, height);
  }

  fill(0, 0.0, 1.0);
  noStroke();
  textAlign(RIGHT);
  text(text, width - 20, 20);

  pt.display(0, 0);
}

void loadCSV(String datafile) {
  Table table = loadTable(datafile, "header");
  //println(table.getRowCount() + " total rows in table"); 

  for (TableRow row : table.rows()) {
    //Month,Weekday,Day,Start day,Break Lunch Start,Break Lunch End,End Day
    String month = row.getString("Month");
    String weekday = row.getString("Weekday");
    String day = row.getString("Day");

    String start = row.getString("Start day");
    String slunch = row.getString("Break Lunch Start");
    String elunch = row.getString("Break Lunch End");
    String end = row.getString("End Day");
    //println(month+"\t"+weekday+"\t"+day+"\t am:"+start+" : "+slunch+"\tpm"+elunch+" : "+end);

    ArrayList<Float> data = DayDatas.convertData(2018, month, day, weekday, start, slunch, elunch, end);
    for (float f : data) {
      datalist.add(f);
      //println("\t"+f);
    }
  }
}

ArrayList<Float> getDataPerDay(int dayToCompute) {
  hourdatalist = new ArrayList<HourData>();
  //fill the arry with all hour per yea
  for (int i=0; i<365 * 24; i++) {
    hourdatalist.add(new HourData(false));
  }

  //check if hour as been worked
  for (int i=0; i<datalist.size(); i+=2) {
    float start = datalist.get(i);
    float end = datalist.get(i+1);

    int istart = floor(start);
    int iend = ceil(end);
    if (istart != iend) {
      for (int h=istart; h<=iend; h++) {
        hourdatalist.get(h).isWorked = true;
        hourdatalist.get(h).normValue = 1.0 - abs(map(h, istart, iend, -1.0, 1.0));
        if (h == istart) {
          hourdatalist.get(h).value = (start - istart != 0.0) ? start - istart : 1.0;
        } else if (h == iend) {
          hourdatalist.get(h).value = (end - iend != 0.0) ? end - iend : 1.0;
        } else {
          hourdatalist.get(h).value = 1.0;
        }
      }
    }
  }


  int dayCount = 0;
  float numberOfhourWorked = 0;
  float hourOutsideOfficeHour = 0;
  for (int i=0; i<hourdatalist.size(); i++) {
    HourData h = hourdatalist.get(i);
    float normValue = h.normValue;

    float hourMod = (i % 24.0);
    float hour = hourMod / 24.0;
    if (hourMod == 0 && i != 0) {
      dayCount ++;
    }
    boolean isWeekend  = false;
    int modDay = dayCount % 7;
    float sat = 0.0;
    float sun = 0.0;
    float week = modDay / 6.0;

    if (modDay == dayToCompute) {
      if (h.isWorked) {
        float edgestart = 10.0 / 24.0;
        float edgeend = 18.0 / 24.0;
        float isOutsideOfficeHours = 0.0;
        if (hour >= edgestart && hour <= edgeend) {
        } else {
          isOutsideOfficeHours = 1.0;
          hourOutsideOfficeHour ++;
        }

        //check if its the day
        //draw here
        numberOfhourWorked ++;
        // println(i+"\t"+hourMod+"\t"+dayCount+"\t"+modDay+"\t"+numberOfhourWorked+"\t"+hourOutsideOfficeHour);
      }
    }
  }

  ArrayList<Float> data = new ArrayList<Float>();
  data.add(numberOfhourWorked);
  data.add(hourOutsideOfficeHour);

  return data;
}

void exportSVG(String name, ArrayList<Node> nodeList, int w, int h) {
  String exportName = name+".svg";
  PGraphics pg = createGraphics(w, h, SVG, exportName);
  pg.beginDraw();
  pg.beginShape();
  for (int i=0; i<nodeList.size(); i++) {
    pg.vertex(nodeList.get(i).location.x, nodeList.get(i).location.y);
  }
  pg.endShape();
  pg.endDraw();
  pg.dispose();
  println(exportName + " saved.");
}

void exportSVG(String name, int w, int h) {
  String exportName = name+".svg";
  PGraphics pg = createGraphics(w, h, SVG, exportName);
  pg.beginDraw();
  for (DGS dgs : dgsdays) {
    ArrayList<Node> nodeList = dgs.getNodeList();
    pg.beginShape();
    for (int i=0; i<nodeList.size(); i++) {
      pg.vertex(nodeList.get(i).location.x, nodeList.get(i).location.y);
    }
    pg.endShape();
  }
  pg.endDraw();
  pg.dispose();
  println(exportName + " saved.");
}

void exportSVGShape(String name, int w, int h, float thickness) {

  int i=0;
  for (DGS dgs : dgsdays) {
    ArrayList<Node> nodeList = dgs.getNodeList();
    ArrayList<PVector> vertList = new ArrayList<PVector>();

    for (Node node : nodeList) {
      vertList.add(node.location);
    }

    ArrayList<PVector> flineVertList = computeShape(vertList, thickness);

  String exportName = name+"_"+i+".svg";
    PGraphics pg = createGraphics(w, h, SVG, exportName);
    pg.beginDraw();
    pg.beginShape(TRIANGLES);
    pg.noStroke();
    int j=0;
    for (PVector v : flineVertList)
    {
      float lightness  = noise(v.x * 0.01, v.y * 0.01, i*j*0.01);
      pg.fill(0.0, 0.0, lightness);
      pg.vertex(v.x, v.y);
      j++;
    }
    pg.endShape();
    i++;
    pg.endDraw();
    pg.dispose();
  }
  println(" saved.");
}

void computeShapes(float thickness) {

  int i=0;
  for (DGS dgs : dgsdays) {
    ArrayList<Node> nodeList = dgs.getNodeList();
    ArrayList<PVector> vertList = new ArrayList<PVector>();
    PShape shape = createShape();

    for (Node node : nodeList) {
      vertList.add(node.location);
    }

    ArrayList<PVector> flineVertList = computeShape(vertList, thickness);

    shape.beginShape(TRIANGLES);
    shape.fill(0.0, 0.0, 1.0);
    shape.noStroke();
    int j=0;
    for (PVector v : flineVertList)
    {
      float lightness  = noise(v.x * 0.01, v.y * 0.01, i*j*0.01);
      shape.fill(0.0, 0.0, lightness);
      shape.vertex(v.x, v.y);
      j++;
    }
    shape.endShape();
    dgsshapes.add(shape);
    i++;
  }
}


void keyPressed() {
}
