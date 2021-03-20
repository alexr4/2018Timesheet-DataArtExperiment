import fpstracker.core.*;
import gpuimage.core.*;
import gpuimage.utils.*;
PerfTracker pt;
Filter filter, filterPP;
Compositor comp;

ArrayList<Float> datalist;
ArrayList<HourData> hourdatalist;

PShader sdfshader;
PShader voronoishader;
PGraphics samples;
PGraphics gpusdf;
PGraphics dataGraphics;

boolean isComputed;

float res = 2.55;
float size = 0.5;

boolean IsComputed;
int frameStart = 12;

void settings() {
  res = (50.0 / 50.0);
  int h = 1000;
  int w = int(h/res);
  size(int(w * size * 3), int(h * size), P2D);
}

void setup() {
  pt = new PerfTracker(this, 100);

  sdfshader = loadShader("sdfImage.glsl");
  voronoishader = loadShader("vornoisdf.glsl");


  datalist = new ArrayList<Float>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }


  surface.setLocation(0, 0);
}

void draw() {
  if (!IsComputed) {
    setData(6, 3000, 1000, 75, 0.15);
    IsComputed = true;
  } else {
    image(samples, 0, 0, width/3, height);
    image(gpusdf, width/3, 0, width/3, height);
    image(dataGraphics, width/3 * 2.0, 0, width/3, height);
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
    for (float f : data) {
      datalist.add(f);
      //println("\t"+f);
    }
  }
}

void setData(int dayToCompute, int bufferwidth, int sampleSize, int sdfiteration, float inc) {
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
  int numberOfhourWorked = 0;
  int hourOutsideOfficeHour = 0;
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
        println(i+"\t"+hourMod+"\t"+dayCount+"\t"+modDay+"\t"+numberOfhourWorked+"\t"+hourOutsideOfficeHour);
      }
    }
  }

  String it = "DAY_"+dayToCompute+"_"+year()+""+month()+""+day()+""+hour()+""+minute()+""+millis(); 

  samples = generateSample(bufferwidth, bufferwidth, round(hourOutsideOfficeHour), sampleSize);
  gpusdf = createGraphics(samples.width, samples.height, P2D);
  dataGraphics =  createGraphics(samples.width, samples.height, P2D);

  computeGPUSDF(samples, gpusdf, sdfiteration);
  computeVoronoi(gpusdf, dataGraphics, (float) numberOfhourWorked * inc);
  //samples.save("saved/samples_"+it+".tif");
 // gpusdf.save("saved/gpusdf_"+it+".tif");
 // dataGraphics.save("saved/dataGraphics_"+it+".tif");

  println("image has been saved");
}


void computeGPUSDF(PImage in, PGraphics out, int searchDistance) {
  sdfshader.set("searchDistance", searchDistance);
  sdfshader.set("resolution", (float) in.width, (float) in.height);
  out.beginDraw();
  out.shader(sdfshader);
  out.image(in, 0, 0, out.width, out.height);
  out.endDraw();
}

void computeVoronoi(PImage in, PGraphics out, float nbOfHours) {
  float time = (float) millis() /1000.0;
  // println(time);
  voronoishader.set("resolution", (float) in.width, (float) in.height);
  voronoishader.set("time", time);
  voronoishader.set("numberOfHours", (float) nbOfHours);

  float mx = map(mouseX, width/3 * 2, width, 0.0, 1.0);
  float my = map(mouseY, 0, height, 1.0, 0.0);
  voronoishader.set("mouse", mx, my);
  out.beginDraw();
  out.shader(voronoishader);
  out.image(in, 0, 0, out.width, out.height);
  out.endDraw();
}

private PGraphics generateSample(int w, int h, int nbSamples, int samplesSize) {
  PGraphics buffer = createGraphics(w, h, P2D);

  buffer.smooth(8);
  buffer.beginDraw();
  buffer.background(255);
  buffer.noStroke();
  buffer.fill(0);
  for (int i=0; i<nbSamples; i++) {
    float angle = random(TWO_PI);
    float rad = random(buffer.width * 0.1, buffer.width * 0.45);

    //float angle = noise(i) * TWO_PI;
    //float rad = noise(i) * buffer.width * 0.35;

    //float rad = randomGaussian() * (buffer.width * 0.25) + (buffer.width * 0.35);

    float x = cos(angle) * rad + buffer.width/2;
    float y = sin(angle) * rad + buffer.width/2;
    float r = random(samplesSize, samplesSize * 8.0);
    float ly0 = random(buffer.height);
    float ly1 = random(buffer.height);
    float lx0 = random(buffer.width);
    float lx1 = random(buffer.width);

    float tLx = random(0, -1.0);
    float tLy = random(0, -1.0);
    float tRx = random(0, 1.0);
    float tRy = random(0, -1.0);
    float bRx = random(0, 1.0);
    float bRy = random(0, 1.0);
    float bLx = random(0, -1.0);
    float bLy = random(0, 1.0);
    float quadSize = random(samplesSize * 0.5, samplesSize);

    float rand = random(1);
    if (rand > 0.5) {

      buffer.stroke(255);
      buffer.strokeWeight(random(samplesSize * 0.05));
    } else {
      buffer.noStroke();
    }


    //line
    //// buffer.stroke(255);
    // buffer.strokeWeight(1);
    //buffer.line(lx0, ly0, lx1, ly1);
    //buffer.line(buffer.width/2, buffer.height/2, x, y);
    /*
    //triangle
     buffer.pushMatrix();
     buffer.translate(x,y);
     buffer.rotate(angle + HALF_PI + random(PI));
     buffer.triangle(0, samplesSize, samplesSize*0.5, 0, -samplesSize*0.5, 0.0);
     buffer.popMatrix();
     */
    //quad

    buffer.pushMatrix();
    buffer.translate(x, y);
    buffer.rotate(angle + HALF_PI + random(PI));
    buffer.quad(tLx * quadSize, tLy * quadSize * 0.5, 
      tRx * quadSize, tRy * quadSize * 0.5, 
      bRx * quadSize, bRy * quadSize * 0.5, 
      bLx * quadSize, bLy * quadSize * 0.5);
    buffer.popMatrix();

    //elipse
    // buffer.ellipse(x, y, samplesSize, samplesSize);
  }
  buffer.endDraw();

  return buffer;
}
