import fpstracker.core.*;
import processing.svg.*;
import java.util.*;

PerfTracker pt;

PGraphics dataBuffer;
float resScreen= 50.0 / 70.0; 


//data
ArrayList<Float> datalist;
ArrayList<HourData> hourdatalist;
boolean isComputed;

//Design
Veneation sps;

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

  colorMode(HSB, TWO_PI, 1.0, 1.0, 1.0);

  //data
  datalist = new ArrayList<Float>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }

  ArrayList<Float> dataDay = getDataPerDay(0);
  printArray(dataDay);

  sps = new Veneation(round(dataDay.get(0)) * 12, round(dataDay.get(1)) * 12);

  frameRate(300);
  background(0.1);
  surface.setLocation(10, 10);
}

void draw() {
  background(0.1);


  sps.grow();

  //sps.debugPoint(g, sps.nodeList, 2);
  dataBuffer.beginDraw();
  sps.debugBranch(dataBuffer, sps.branchList);
  dataBuffer.endDraw();
  image(dataBuffer, 0, 0);

  if (sps.nodeList.size() <= 0) {
    if (!isComputed) {
      println("Growth is finished");

      String it = "DataViz2018_"+year()+""+month()+""+day()+""+hour()+""+minute()+""+millis();
      sps.exportSVG("Monday_"+it+".tif", width, height);
      isComputed = true;
      println("Buffer is saved");
    }
  }

  //pt.display(0, 0);
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





void keyPressed() {
}
