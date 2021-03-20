//import fpstracker.core.*;
import processing.svg.*;

//PerfTracker pt;

PGraphics dataBuffer;
float resScreen= 1422.0/5000.0;
PImage monthName;
PShader shader;

//data
ArrayList<Float> datalist;
ArrayList<HourData> hourdatalist;
boolean isComputed;

void settings() {
  int h = 1000;
  int w = floor(h * resScreen);
  size(w, h, P2D);
  smooth(8);
}

void setup() {
  //pt = new PerfTracker(this, 100);
  int h = 7000;
  dataBuffer = createGraphics(floor(h * resScreen), h, P2D);
  dataBuffer.smooth(8);
  //data
  shader = loadShader("2DDisplaceVoronoi.glsl");
  datalist = new ArrayList<Float>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  //for (int i=0; i<f.size(); i++) {
  monthName = loadImage("december.png");
    String file = f.get(11);
    loadCSV(file);
  //}
    ArrayList<Float> data = getData();
    
  //minH 187
  //maxH 343
  //minAH 26
  //maxAH 112
  
  float cellNumber = map(data.get(1), 26, 112, 3, 20);
  float numberOfLines = map(data.get(0), 187, 343, 150, 400);

  shader.set("u_time", random(1000.0));
  shader.set("numberOfCell", cellNumber);
  shader.set("numberOfLines", numberOfLines);
  shader.set("u_resolution", (float)dataBuffer.width, (float)dataBuffer.height);
  dataBuffer.beginDraw();
  dataBuffer.shader(shader);
  dataBuffer.image(monthName, 0, 0, dataBuffer.width, dataBuffer.height);
  dataBuffer.endDraw();
  dataBuffer.save("december.tif");
  frameRate(300);
  background(0.1);
  surface.setLocation(10, 10);
}

void draw() {
  background(0.1);

  image(dataBuffer, 0, 0, width, height);
  // pt.display(0, 0);
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

ArrayList<Float> getData() {
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
      // println(i+"\t"+hourMod+"\t"+dayCount+"\t"+modDay+"\t"+numberOfhourWorked+"\t"+hourOutsideOfficeHour);
    }
  }

  ArrayList<Float> data = new ArrayList<Float>();
  data.add(numberOfhourWorked);
  data.add(hourOutsideOfficeHour);
  println(numberOfhourWorked, hourOutsideOfficeHour);
  return data;
}





void keyPressed() {
}
