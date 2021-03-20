import fpstracker.core.*;
import gpuimage.core.*;
import gpuimage.utils.*;
import java.util.*;


PerfTracker pt;
Filter filter, filterPP;
Compositor comp;

ArrayList<ArrayList> datalist;
PGraphics dataGraphics;


boolean isComputed;

float res = 1.0;
float size = 0.5;

boolean IsComputed;
int frameStart = 12;

void settings() {
  int h = 1000;
  int w = int(h/res);
  size(int(w * size), int(h * size), P2D);
}

void setup() {
  pt = new PerfTracker(this, 100);
  datalist = new ArrayList<ArrayList>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }

  setData(4000);

  //surface.setLocation(0, 0);
}

void draw() {
  try {
    image(dataGraphics, 0, 0, width, height);
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

void setData(int iwidth) {
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
    if(amend == pmstart && amstart != amend && pmstart != pmend){
      hourWorked = pmend - amstart;
      //println("\t\t\tNo lunch :( worked\t"+hourWorked);
    }else if(amstart < amend || pmstart < pmend){
      hourWorked += amend - amstart;
      hourWorked += pmend - pmstart;
      //println("\t\t\tWorked\t"+hourWorked);
    }else{
    }
    
    hourWorkedPerDay.add(hourWorked);
    println(i+1, hourWorked, "\t", amstart, amend, pmstart, pmend);
  }
  
  float min = Collections.min(hourWorkedPerDay);
  float max = Collections.max(hourWorkedPerDay);
  float realMin = max;
  for(float f : hourWorkedPerDay){
    if(f < realMin && f > 0.0){
      realMin = f;
    }
  }
  
  float[] normalizedHourWorkedPerDay = new float[hourWorkedPerDay.size()];
  float[] normalizedDay = new float[hourWorkedPerDay.size()];
  for(int i=0; i<normalizedHourWorkedPerDay.length; i++){
    normalizedHourWorkedPerDay[i] = hourWorkedPerDay.get(i)/max;
    normalizedDay[i] = (i % 7.0) / 7.0;
    println(i%7, "\t",normalizedDay[i], "\t", normalizedHourWorkedPerDay[i]);
  }
  
  //printArray(normalizedHourWorkedPerDay);
  println("\n", min, realMin, max, realMin/max);
  
  dataGraphics = createGraphics(iwidth, iwidth, P2D);
  PShader shader = loadShader("voronoi.glsl");
  shader.set("resolution", float(dataGraphics.width), float(dataGraphics.height));
  shader.set("data", normalizedHourWorkedPerDay);
  shader.set("dataDay", normalizedDay);
  
  dataGraphics.smooth();
  dataGraphics.beginDraw();
  dataGraphics.background(0);
  dataGraphics.shader(shader);
  dataGraphics.rect(0, 0, dataGraphics.width, dataGraphics.height);
  dataGraphics.endDraw();
 
  String it = year()+""+month()+""+day()+""+hour()+""+minute()+""+millis(); 
  dataGraphics.save("saved/dataGraphics_"+it+".tif");

  println("image has been saved");
}
