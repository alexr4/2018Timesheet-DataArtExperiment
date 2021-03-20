import fpstracker.core.*;
import processing.svg.*;
import java.util.*;

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

float[] day;
float[] hoursWorked;

PShader voronoi;
PVector[] array;
boolean zoom;

void settings() {
  float res = 1.0;
  int w = 800;
  int h = floor(w / resScreen);
  size(w, h, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);
  float res= 50.0/70.0;
  int w = 8000;
  int h = int(w / res);
  dataBuffer = createGraphics(w, h, P2D);
  dataBuffer.smooth();
  dataBuffer.beginDraw();
  dataBuffer.background(0);
  dataBuffer.endDraw();


  //data
  datalist = new ArrayList<Float>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }
  month = 11;
  /*  if (month >= 0) {
   loadCSV(f.get(month), month);
   }*/

  printArray(datalistVector);

  ArrayList<PVector> dataPerMonth = new ArrayList<PVector>();
  for (PVector v : datalistVector) {
    if (v.z == month +1) {
      dataPerMonth.add(v);
    }
  }
  Collections.shuffle(dataPerMonth);
  println(dataPerMonth.size());
  printArray(dataPerMonth);

  int maxData = (dataPerMonth.size() > 31) ? 31 : dataPerMonth.size();
  day =  new float[maxData];
  hoursWorked = new float[maxData];
  for (int i=0; i<maxData; i++) {
    PVector data = dataPerMonth.get(i);
    if (i <maxData) {
      day[i] = data.y;
      hoursWorked[i] = data.x;
    }
  }

  List<Float> list = new ArrayList<Float>();
  for (int i = 0; i < hoursWorked.length; i++) {
    list.add(hoursWorked[i]);
  }
  float min = Collections.min(list);
  float max = Collections.max(list);
  println("\n", min, max, hoursWorked.length);



  float goldenRatio = (3.0 + sqrt(5.0))/2.0;
  float constant = 600;

  array = new PVector[hoursWorked.length];
  voronoi = loadShader("voronoiArray.glsl");

  for (int i=0; i<hoursWorked.length; i++) {
    float angle = i * (TWO_PI * goldenRatio);
    float radius = constant * sqrt(i);

    float x = cos(angle) * radius + dataBuffer.width * 0.5;
    float y = sin(angle) * radius + dataBuffer.height * 0.5;
    float z = list.get(i) / 16.5;

    array[i] = new PVector(x, y, z);
  }
  voronoi.set("fermat", getDataForBinding());
  voronoi.set("maxElements", hoursWorked.length * 3);
  voronoi.set("resolution", (float)width, (float)height);

  dataBuffer.beginDraw();
  dataBuffer.background(0);
  dataBuffer.shader(voronoi);
  dataBuffer.rect(0, 0, dataBuffer.width, dataBuffer.height);
  dataBuffer.endDraw();


  String it = year()+""+month()+""+day()+""+hour()+""+minute()+""+millis(); 

  dataBuffer.save("Data13-"+month+"_from-"+min+"-to-"+max+"_"+it);

  frameRate(300);
  exit();
}

void draw() {

  background(0.0);
  imageMode(CENTER);
  int w = width;
  int h = height;
  if (zoom) {
    w = dataBuffer.width;
    h = dataBuffer.height;
  }
  image(dataBuffer, width*0.5, height*0.5, w, h);


  fill(255, 0, 0);
  noStroke();
  for (PVector v : array) {
    float x = (v.x / dataBuffer.width) * w - (w-width) * 0.5;
    float y = (v.y / dataBuffer.height) * h - (h-height) * 0.5;
    ellipse(x, y, 10, 10);
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
    //println(month+"\t"+weekday+"\t"+day+"\t am:"+start+" : "+slunch+"\tpm"+elunch+" : "+end);

    ArrayList<Float> data = DayDatas.convertData(2018, month, day, weekday, start, slunch, elunch, end);
    PVector dataVector = DayDatas.getData(month, day, weekday, start, slunch, elunch, end);
    datalistVector.add(dataVector);
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

//Fisher Yatessuffle algorithm https://stackoverflow.com/questions/1519736/random-shuffling-of-an-array
private static void shuffleArray(int[] array)
{
  int index;
  Random random = new Random();
  for (int i = array.length - 1; i > 0; i--)
  {
    index = random.nextInt(i + 1);
    if (index != i)
    {
      array[index] ^= array[i];
      array[i] ^= array[index];
      array[index] ^= array[i];
    }
  }
}

float[] getDataForBinding() {
  float[] dataList = new float[array.length * 3];
  for (int i=0; i<array.length; i++) {
    float dataX = array[i].x;
    float dataY = array[i].y;
    float dataZ = array[i].z;
    dataList[i * 3] = dataX;
    dataList[i * 3 + 1] = dataY;
    dataList[i * 3 + 2] = dataZ;
  }

  return dataList;
}


void mouseReleased() {
  zoom = !zoom;
}
