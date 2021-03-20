import fpstracker.core.*;
import java.util.*;
import processing.svg.*;

PerfTracker pt;

ArrayList<ArrayList> datalist;
ArrayList<Node> nodes;
PGraphics dataGraphics;


boolean isComputed;



void settings() {
  int h = 1000;
  size(h, h, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);
  datalist = new ArrayList<ArrayList>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }

  setData();

  //surface.setLocation(0, 0);
}

void draw() {
  try {
    background(0);
    float edge = 125;
    /*rectMode(CENTER);
    fill(255);
    rect(width/2, height/2, width - edge * 2, height - edge * 2);*/
    for (Node node : nodes) {
      node.separate(nodes);
      node.stopIfNoNeighbors(nodes, 0.0);
      node.checkEdge(edge, edge, edge, edge);
      node.update();
      node.display();
    }
    /*
    float offset = 10;
     for (int i=0; i<nodes.size(); i++) {
     Node n1 = nodes.get(i);
     for (int j=0; j<nodes.size(); j++) {
     Node n2 = nodes.get(j);
     float d = PVector.dist(n1.location, n2.location);
     float mind = n1.radius + n2.radius;
     if (d <= mind + offset) {
     stroke(255, 50);
     line(n1.location.x, n1.location.y, n2.location.x, n2.location.y);
     }
     }
     }*/

    //image(dataGraphics, 0, 0, width, height);
  }
  catch(Exception e) {
  }
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
    //println(month+" : "+weekday+" : "+day+"\t s:"+start+" : "+slunch+" : "+elunch+" : "+end);

    ArrayList<Float> data = DayDatas.convertData(2018, month, day, weekday, start, slunch, elunch, end);

    datalist.add(data);
  }
}

void setData() {
  println(datalist.size());

  ArrayList<Float> hourWorkedPerDay = new  ArrayList<Float>();
  //fill the arry with all hour per year
  float hourBeforeStart = 0.0;
  for (int i=0; i<365; i++) {
    ArrayList<Float> data = datalist.get(i);
    //printArray(data);
    float amstart = data.get(0) % 24.0;
    float amend = data.get(1) % 24.0;
    float pmstart = data.get(2) % 24.0;
    float pmend = data.get(3) % 24.0;

    //println((i+1), amstart, amend, pmstart, pmend);
    if (pmend < amstart && pmend != pmstart) {
      //println("\t", pmend);
      hourBeforeStart = pmend;
      pmend = 24.0;
    } else {
      hourBeforeStart = 0.0;
    }

    //compute hours worked a day
    float hourWorked = hourBeforeStart;
    if (amend == pmstart && amstart != amend && pmstart != pmend) {
      hourWorked = pmend - amstart;
      //println("\t\t\tNo lunch :( worked\t"+hourWorked);
    } else if (amstart < amend || pmstart < pmend) {
      hourWorked += amend - amstart;
      hourWorked += pmend - pmstart;
      //println("\t\t\tWorked\t"+hourWorked);
    } else {
    }

    hourWorkedPerDay.add(hourWorked);
    println(i+1, "\t", i%7, "\t", hourWorked, "\t", amstart, "\t", amend, "\t", pmstart, "\t", pmend);
  }

  float min = Collections.min(hourWorkedPerDay);
  float max = Collections.max(hourWorkedPerDay);
  float realMin = max;
  for (float f : hourWorkedPerDay) {
    if (f < realMin && f > 0.0) {
      realMin = f;
    }
  }
  println(realMin, max, hourWorkedPerDay.size());

  float[] normalizedHourWorkedPerDay = new float[hourWorkedPerDay.size()];
  float[] normalizedDay = new float[hourWorkedPerDay.size()];
  for (int i=0; i<normalizedHourWorkedPerDay.length; i++) {
    normalizedHourWorkedPerDay[i] = hourWorkedPerDay.get(i)/ max;
    normalizedDay[i] = (i % 7.0) / 7.0;
    println(i, "\t", normalizedDay[i], "\t", normalizedHourWorkedPerDay[i]);
  }

  nodes = new ArrayList<Node>();
  float maxRad = 30;

  //based on https://fr.wikipedia.org/wiki/Spirale_de_Fermat
  float goldenRatio = (3.0 + sqrt(5.0))/2.0;
  float constant = 15;

  for (int i=0; i<365; i++) {
    float normHourWorked = normalizedHourWorkedPerDay[i];
    //normHourWorked = 0.0;
    float angle = i * (TWO_PI * (goldenRatio));
    float radius = constant * sqrt(i);
    float x = cos(angle) * radius + width * 0.5;
    float y = sin(angle) * radius + height * 0.5;
    Node node = new Node(new PVector(x, y), 5 + maxRad * normHourWorked, 5.0, i%7);
    nodes.add(node);
  }



  String it = year()+""+month()+""+day()+""+hour()+""+minute()+""+millis(); 

  // println("image has been saved");
}


void exportSVG(String name, int w, int h) {
  String exportName = name+".svg";
  PGraphics pg = createGraphics(w, h, SVG, exportName);
  pg.beginDraw();
  pg.strokeCap(ROUND);
  for (Node node : nodes) {
    node.display(pg);
  }
  pg.endDraw();
  pg.dispose();
  println(name+" saved.");
}

void keyPressed() {
  if (key == 's') {
    String it = year()+""+month()+""+day()+""+hour()+""+minute()+""+millis(); 
    exportSVG(it, width, height);
  }
}
