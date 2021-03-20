import fpstracker.core.*;
import processing.svg.*;

PerfTracker pt;

PGraphics dataBuffer;
float resScreen= 50.0 / 70.0; 


//data
ArrayList<Float> datalist;
ArrayList<PVector> datalistVector = new ArrayList<PVector>();
ArrayList<HourData> hourdatalist;
boolean isComputed;
int month;
String[] monthName = {"january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"};

//FLUID
final int N = 250;
final int scale = 4;
final int iter = 4;
float multForce, multDens;
int nbNeighbors;
int subRadius;
float radius;
int iterationPerRender;
boolean isLoop;
Fluid fluid;

void settings() {
  float res = 1.0;
  int w = 700;
  int h = floor(w / resScreen);
  size(N * scale, N * scale, P2D);
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
  /*for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }*/
  month = 0;
  if (month >= 0) {
    loadCSV(f.get(month));
  }

  printArray(datalistVector);

  //fluid


  nbNeighbors =datalistVector.size();
  subRadius = nbNeighbors / 8;
  radius = width * 0.25;
  iterationPerRender = 250;
  multForce = 5.0;
  multDens = 100.0;
  println(datalistVector.size());

  generateFluid();
  frameRate(300);
  surface.setLocation(10, 10);
}

void draw() {

  background(0.0);
  
  fluid.renderVelocity(g, 0.00, 2.0, radius); 

  pt.display(0, 0);
}

void generateFluid() {
  fluid = new Fluid(0.001, 0.0, 0.0);//0.001, 0.001);
  for (PVector v : datalistVector) {
    addDataToFluid(nbNeighbors, subRadius, radius, v.x  * multDens, v.y * multForce);
  }

  for (int i=0; i<iterationPerRender; i++) {
    fluid.step();
  }
}

void addDataToFluid(int nbNeighbors, int enviro, float radius, float density, float maxForce) {

  float randAngle = random(TWO_PI);
  float rad = random(radius);
  int cx = (int)(cos(randAngle) * rad + width * 0.5); 
  int cy = (int)(sin(randAngle) * rad + width * 0.5);  

  for (int i=0; i<nbNeighbors; i++) {
    int displaceX = (int) random(-enviro, enviro); 
    int displaceY = (int) random(-enviro, enviro); 
    int ncx = (cx + displaceX) / scale; 
    int ncy = (cy + displaceY) / scale; 
    fluid.addDensity(ncx, ncy, density); 

    float dist = 1.0 - (dist(cx, cy, ncx, ncy) / radius);
    float randHP =  HALF_PI * 0.1;
    float angle = randAngle + HALF_PI + random(-randHP, randHP) ;//random(TWO_PI); 
    PVector v = PVector.fromAngle(angle); 
    v.mult(maxForce * dist); 
    // v.mult(-1);

    fluid.addVelocity(ncx, ncy, v.x, v.y);
  }
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
    PVector dataVector = DayDatas.getData(month, day, weekday, start, slunch, elunch, end);
    datalistVector.add(dataVector);
    /*for (float f : data) {
     datalist.add(f);
     //println("\t"+f);
     }*/
  }
}

ArrayList<Float> getDataPerMonth() {
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
      println(i+"\t"+hourMod+"\t"+dayCount+"\t"+"\t"+numberOfhourWorked+"\t"+hourOutsideOfficeHour);
    }
  }

  ArrayList<Float> data = new ArrayList<Float>();
  data.add(numberOfhourWorked);
  data.add(hourOutsideOfficeHour);

  return data;
}

void exportSVG(String name, int w, int h) {
  String exportName = name+".svg";
  PGraphics pg = createGraphics(w, h, SVG, exportName);
  pg.beginDraw();
  pg.strokeCap(ROUND);
  fluid.renderVelocity(pg, 0.00, 2.0, radius); 
  pg.endDraw();
  pg.dispose();
  println(name+" saved.");
}



void keyPressed() {
  if (key == 'r') {
    generateFluid();
    // println(monthName[month]);
  }
  if (key =='s') {
    String file = "DataViz2018_"+year()+""+month()+""+day()+""+hour()+""+minute()+""+millis();
    String name = (month >= 0) ? monthName[month] : "FULL_YEAR";
    exportSVG(file+"_"+name, width, height);
  }
  if (key == '+') {
    month ++;
    if (month >= monthName.length) {
      month = 0;
    }
    println(monthName[month]);
  }
  if (key == '-') {
    month --;
    if (month < 0) {
      month = monthName.length - 1;
    }
    println(monthName[month]);
  }
}
