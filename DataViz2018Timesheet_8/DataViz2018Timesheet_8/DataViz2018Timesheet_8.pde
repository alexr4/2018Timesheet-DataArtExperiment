import fpstracker.core.*;
import processing.svg.*;

PerfTracker pt;

PGraphics dataBuffer;
float resScreen= 50.0 / 70.0; 


//data
ArrayList<Float> datalist;
ArrayList<HourData> hourdatalist;
ArrayList<PVector> hourDatas;
int dataIndex;
boolean isComputed;
boolean isExported;

//lines
PVector center, size;
Line root;
ArrayList<Line> lineList;
Line current;

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


  //data
  datalist = new ArrayList<Float>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }

  hourDatas = getDatasPerDay(6);
  printArray(hourDatas);

  //create fracture line
  center = new PVector(width * 0.5, height * 0.5);
  size = new PVector(width * 0.25, height - 10);
  PVector[] AB = getRandomointOnRectEdge(center, size);
  root = new Line(AB[0], AB[1]);
  root.isFinished = true;

  Line l = root.getNewlineDirection();

  lineList = new ArrayList<Line>();
  lineList.add(root);
  lineList.add(l);

  dataIndex = lineList.size() - 1;
  current = lineList.get(dataIndex);


  frameRate(300);
  background(0.1);
  surface.setLocation(10, 10);
}

void draw() {
  background(0.1);
  if (!isComputed) {
    grow(50.0);
  } else {
    if (!isExported) {
      String it = "DataViz2018_"+year()+""+month()+""+day()+""+hour()+""+minute()+""+millis();
      exportSVG("Sunday_"+it+".tif", width, height);
      isExported = true;
    }
  }

  rectMode(CENTER);
  noFill();
  stroke(255);
  strokeWeight(1.0);
  rect(center.x, center.y, size.x, size.y);

  strokeCap(ROUND);
  float hyp = sqrt(size.x * size.x + size.y * size.y);
  for (Line line : lineList) {
    if (line.isFinished) {
      stroke(255);
    } else {
      stroke(0, 255, 0);
    }
    float d = PVector.dist(line.A, line.B);
    float nd = d / hyp;
    // nd = 1.0 - nd;
    //strokeWeight(1.0 + nd * 3.0);
    line.displayLine(g);
    // line.displayRoots(g);
  }

  textAlign(RIGHT);
  fill(255);
  noStroke();
  text(lineList.size()+"/"+hourDatas.size(), width - 20, 20);
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


ArrayList<PVector> getDatasPerDay(int dayToCompute) {
  hourdatalist = new ArrayList<HourData>();
  ArrayList<PVector> data = new ArrayList<PVector>();
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
        //println(i+"\t"+hourMod+"\t"+dayCount+"\t"+modDay+"\t"+numberOfhourWorked+"\t"+hourOutsideOfficeHour);
        data.add(new PVector(hourMod, isOutsideOfficeHours));
      }
    }
  }

  // data.add(numberOfhourWorked);
  // data.add(hourOutsideOfficeHour);
  //printArray(data);
  return data;
}

void exportSVG(String name, int w, int h) {
  String exportName = name+".svg";
  PGraphics pg = createGraphics(w, h, SVG, exportName);
  pg.beginDraw();
  pg.strokeCap(ROUND);

  pg.rectMode(CENTER);
  pg.noFill();
  pg.stroke(255);
  pg.strokeWeight(1.0);
  pg.rect(center.x, center.y, size.x, size.y);

  pg.strokeCap(ROUND);
  float hyp = sqrt(size.x * size.x + size.y * size.y);
  for (Line line : lineList) {
    if (line.isFinished) {
      pg.stroke(255);
    } else {
      pg.stroke(0, 255, 0);
    }
    float d = PVector.dist(line.A, line.B);
    float nd = d / hyp;
    // nd = 1.0 - nd;
    //strokeWeight(1.0 + nd * 3.0);
    line.displayLine(pg);
    // line.displayRoots(g);
  }

  pg.endDraw();
  pg.dispose();
  println(" saved.");
}




void keyPressed() {
}
