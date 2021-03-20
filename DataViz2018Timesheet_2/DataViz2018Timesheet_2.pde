import fpstracker.core.*;
import gpuimage.core.*;
import gpuimage.utils.*;
PerfTracker pt;
Filter filter, filterPP;
Compositor comp;

ArrayList<Float> datalist;
ArrayList<HourData> hourdatalist;
PGraphics dataGraphics;


boolean isComputed;

float res = 2.55;
float size = 1.0;

boolean IsComputed;
int frameStart = 12;

void settings() {
  res = (50.0 / 70.0);
  int h = 1000;
  int w = int(h/res);
  size(int(w * size), int(h * size), P2D);
}

void setup() {
  pt = new PerfTracker(this, 100);


  datalist = new ArrayList<Float>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }

  setData(3);

  //surface.setLocation(0, 0);
}

void draw() {
  image(dataGraphics, 0, 0, width, height);
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
    for (float f : data) {
      datalist.add(f);
    }
  }
}

void setData(int version) {
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

  int[] area = GPUImageMathsPixels.getWidthHeightFromArea(hourdatalist.size());
  float scaler = 60.0;
  float res = 70.0 / 50.0;
  dataGraphics = createGraphics(int(area[0] * scaler), int((area[0] * scaler)/res), P2D);
  println(dataGraphics.width, dataGraphics.height);

  float offset = dataGraphics.height - area[1] * scaler;

  dataGraphics.smooth(8);
  dataGraphics.beginDraw();
  dataGraphics.background(10.0);
  dataGraphics.noStroke();
  dataGraphics.rectMode(CENTER);
  int dayCount = 0;
  for (int i=0; i<hourdatalist.size(); i++) {
    HourData h = hourdatalist.get(i);
    float normValue = h.normValue;
    color col = color(0.0, 0.0, 0.0, 0.0);

    float x = i % area[0];
    float y = (i - x) / area[0];

    float fx = x * scaler + scaler * 0.5;
    float fy = y * scaler + scaler * 0.5;

    dataGraphics.pushMatrix();
    dataGraphics.translate(fx, fy + offset * 0.5);
    //dataGraphics.rotate(HALF_PI);

    float hourMod = (i % 24.0);
    float hour = hourMod / 24.0;
    boolean isWeekend  = false;
    int modDay = dayCount % 7;
    float sat = 0.0;
    float sun = 0.0;
    float week = modDay / 6.0;
    if (hourMod == 0) {
      dayCount ++;
    }
    if (modDay > 4) {
      //println(dayCount, "is weekend");
      isWeekend = true;
      if (modDay == 5) {
        sat = hourMod / 24.0;
      } else {
        sun = hourMod / 24.0;
      }
    }
    // println(i, hourMod, dayCount, modDay, sun, sat, week);

    if (h.isWorked) {

      float edgestart = 10.0 / 24.0;
      float edgeend = 18.0 / 24.0;
      float isOutsideOfficeHours = 0.0;
      if (hour >= edgestart && hour <= edgeend) {
        isOutsideOfficeHours = 1.0;
      } else {
      }

      float hourOffset = hour * 0.75 + 0.25;
      float isHourFilled = h.value;

      switch(version) {
      case 0 :
        col = color(255 * isHourFilled, week * 255.0, hourOffset * 255);//it0
        break;
      case 1 :
        col = color(255 * (1.0 -  isHourFilled), week * 255.0, hourOffset * 255);//it1
        break;
      case 2 :
        col = color(hourOffset * 255, 255 * isHourFilled, week * 255.0);//it2
        break;
      case 3 :
        col = color(hourOffset * 255, week * 255.0, 255 * isHourFilled);//it3
        break;
      case 4 :
        col = color(week * 255.0, hourOffset * 255, 255 * isHourFilled);//it4
        break;
      case 5 :
        col = color(week * 255.0, 255 * isHourFilled, hourOffset * 255);//it5
        break;
      case 6 :
        col = color(week * 255.0, hourOffset * 255, 255 * isHourFilled);//it6
        break;
      case 7 :
        col = color(week * 255.0, hourOffset * 255, 255 * isHourFilled);//it7
        break;
      case 8 :
        col = color(week * 255.0, hourOffset * 255, isOutsideOfficeHours * 255);//it8
        break;
      case 9 :
        col = color(week * 255.0, isOutsideOfficeHours * 255, hourOffset * 255);//it9
        break;
      case 10 :
        col = color(isOutsideOfficeHours * 255, week * 255.0, hourOffset * 255);//it10
        break;
      case 11 :
        col = color(isOutsideOfficeHours * 255, hourOffset * 255, week * 255.0);//it11
        break;
      default :
        col = color(hourOffset * 255, week * 255.0, isOutsideOfficeHours * 255);//it12
      case 12 :
        col = color(255);//it12
        break;
      }


      dataGraphics.fill(col);
      dataGraphics.noStroke();
      dataGraphics.rect(0, 0, scaler * 0.35, scaler * 0.35);
    }



    dataGraphics.noFill();
    dataGraphics.stroke(40);
    dataGraphics.rect(0, 0, scaler*1.0, scaler*1.0);
    dataGraphics.popMatrix();
  }
  dataGraphics.endDraw();
  String it = year()+""+month()+""+day()+""+hour()+""+minute()+""+millis()+"_it"+version; 
  dataGraphics.save("saved/dataGraphics_"+it+".tif");

  println("image "+version+" has been saved");
}
