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
float piteration, pmaxIteration;

ArrayList<PVector> vertList;
float thetaInc, radius, ox, oy;

void settings() {
  float res = 1.0;
  int w = 700;
  int h = floor(w / res);
  size(w, h, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);


  colorMode(HSB, 1.0, 1.0, 1.0, 1.0);

  //data
  datalist = new ArrayList<Float>();
  ArrayList<String> f = FilesLoader.getAllPathToTypeFilesFrom(this, "", "csv");
  for (int i=0; i<f.size(); i++) {
    String file = f.get(i);
    loadCSV(file);
  }

  ArrayList<Float> monday = getDataPerDay(0);
  ArrayList<Float> tuesday = getDataPerDay(1);
  ArrayList<Float> wednesday = getDataPerDay(2);
  ArrayList<Float> thursday = getDataPerDay(3);
  ArrayList<Float> friday = getDataPerDay(4);
  ArrayList<Float> saturday = getDataPerDay(5);
  ArrayList<Float> sunday = getDataPerDay(6);

  println("monday", "\t", monday.get(0), "\t", monday.get(1));
  println("tuesday", "\t", tuesday.get(0), "\t", tuesday.get(1));
  println("wednesday", "\t", wednesday.get(0), "\t", wednesday.get(1));
  println("thursday", "\t", thursday.get(0), "\t", thursday.get(1));
  println("friday", "\t", friday.get(0), "\t", friday.get(1));
  println("saturday", "\t", saturday.get(0), "\t", saturday.get(1));
  println("sunday", "\t", sunday.get(0), "\t", sunday.get(1));

  ArrayList<Float> officeHour = new ArrayList<Float>();
  ArrayList<Float> officeAdditionalHour = new ArrayList<Float>();

  officeHour.add(monday.get(0));
  officeHour.add(tuesday.get(0));
  officeHour.add(wednesday.get(0));
  officeHour.add(thursday.get(0));
  officeHour.add(friday.get(0));
  officeHour.add(saturday.get(0));
  officeHour.add(sunday.get(0));

  officeAdditionalHour.add(monday.get(1));
  officeAdditionalHour.add(tuesday.get(1));
  officeAdditionalHour.add(wednesday.get(1));
  officeAdditionalHour.add(thursday.get(1));
  officeAdditionalHour.add(friday.get(1));
  officeAdditionalHour.add(saturday.get(1));
  officeAdditionalHour.add(sunday.get(1));

  float ohmin = Collections.min(officeHour);
  float ohmax = Collections.max(officeHour);

  float oahmin = Collections.min(officeAdditionalHour);
  float oahmax = Collections.max(officeAdditionalHour);

  float normOfficeHour = saturday.get(0) / ohmax;
  float normAdditionalOfficeHour = saturday.get(1) / oahmax;

  int iteration = round(lerp(5, 10, normOfficeHour));
  float deviation = lerp(0.15, 0.4, normAdditionalOfficeHour);
  float subDeviation = lerp(0.01, 0.15, normAdditionalOfficeHour);

  String day = "saturday";
  String name = "DataViz2018_"+day+"_"+year()+""+month()+""+day()+""+hour()+""+minute()+""+millis();
  //computeShape(iteration, deviation, subDeviation, name);

  piteration = 0.0;
  pmaxIteration = 8.0;


  process(piteration, pmaxIteration);
  exit();

  frameRate(300);
  background(0.1);
  surface.setLocation(10, 10);
}

void draw() {
  background(0.1);



  imageMode(CENTER);


  float x = width/2;
  float y = height/2;
  float w = width;
  float h = height;

  if (mousePressed) {
    w = dataBuffer.width;
    h = dataBuffer.height;
    x = norm(mouseX, 0, width) * w;
    y = norm(mouseY, 0, height) * h;
  }

  image(dataBuffer, x, y, w, h);

  pt.display(0, 0);
}

void process(float iteration, float maxIteration) {
  if (iteration <= 0) {
  } else {
    float normi = iteration/maxIteration;

    int it = round(lerp(5, 10, normi));
    float deviation = lerp(0.15, 0.4, normi);
    float subDeviation = lerp(0.01, 0.15, normi);

    String day = "Process_"+iteration;
    String name = "DataViz2018_"+day+"_"+year()+""+month()+""+day()+""+hour()+""+minute()+""+millis();
    computeShape(it, deviation, subDeviation, name);
    iteration--;
    print("process "+iteration+" done");
    process(iteration, maxIteration);
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
        //println(i+"\t"+hourMod+"\t"+dayCount+"\t"+modDay+"\t"+numberOfhourWorked+"\t"+hourOutsideOfficeHour);
      }
    }
  }

  ArrayList<Float> data = new ArrayList<Float>();
  data.add(numberOfhourWorked);
  data.add(hourOutsideOfficeHour);

  return data;
}


void computeShape(int it, float deviation, float subDeviation, String name) {
  dataBuffer = createGraphics(7000, 7000, P2D); 
  dataBuffer.smooth(8);


  vertList = new ArrayList<PVector>();

  thetaInc = TWO_PI/4.0;
  radius = dataBuffer.width * 0.35;
  ox = dataBuffer.width * 0.5;
  oy = dataBuffer.height * 0.5;

  for (int i=0; i<4; i++) {
    float theta = i * thetaInc;
    float x = cos(theta + HALF_PI * 0.5) * radius + ox;
    float y = sin(theta + HALF_PI * 0.5) * radius + oy;
    vertList.add(new PVector(x, y));
  }
  println("verList initialized");

  PVector A = vertList.get(0);
  PVector B = vertList.get(1);
  PVector C = vertList.get(2);  
  PVector D = vertList.get(3);

  subdivQuad(A, B, C, D, it, it, deviation, subDeviation);
  println("Subdiv done");

  dataBuffer.beginDraw();
  dataBuffer.background(0);
  computeBuffer(dataBuffer, vertList);
  dataBuffer.endDraw();
  println("Buffer computed");

  dataBuffer.save(name+".tif");
  //exportSVG("shape", vertList, buffer.width, buffer.height);
}

void computeBuffer(PGraphics b, ArrayList<PVector> vList) {
  b.stroke(255, 127 * 0.5);
  b.strokeWeight(1.5);
  b.strokeCap(ROUND);
  b.noFill();
  b.beginShape(QUADS);
  for (int i=4; i<vList.size(); i+=4) {
    PVector v1 = vList.get(i);
    PVector v2 = vList.get(i+1);
    PVector v3 = vList.get(i+2);
    PVector v4 = vList.get(i+3);

    b.vertex(v1.x, v1.y);
    b.vertex(v2.x, v2.y);
    b.vertex(v3.x, v3.y);
    b.vertex(v4.x, v4.y);
  }
  b.endShape();
}

void subdivQuad(PVector A, PVector B, PVector C, PVector D, int iteration, int maxIteration, float deviation, float subDeviation) {
  if (iteration <=0) {
    vertList.add(A);
    vertList.add(B);
    vertList.add(C);
    vertList.add(D);
  } else {
    PVector gravity = getCenter(A, C);
    PVector AB = getCenter(A, B);
    PVector BC = getCenter(B, C);
    PVector CD = getCenter(C, D);
    PVector DA = getCenter(D, A);

    PVector offset = PVector.sub(A, gravity);
    PVector AC = PVector.sub(A, C);
    float maxDeviation = AC.mag() * 0.5;
    float dev = deviation;
    if (iteration == maxIteration) {
      dev = 0;
    }
    float deviationSub = subDeviation;      
    offset.normalize().mult(-maxDeviation * dev);
    gravity.add(offset);

    /*
    PVector AG = PVector.sub(A, gravity).normalize().mult(maxDeviation * devitation * deviationSub); 
     PVector BG = PVector.sub(B, gravity).normalize().mult(maxDeviation * devitation * deviationSub);
     PVector CG = PVector.sub(C, gravity).normalize().mult(maxDeviation * devitation * deviationSub);
     PVector DG = PVector.sub(D, gravity).normalize().mult(maxDeviation * devitation * deviationSub);
     
     PVector gravityA = gravity.copy().add(AG);
     PVector gravityB = gravity.copy().add(BG);
     PVector gravityC = gravity.copy().add(CG);
     PVector gravityD = gravity.copy().add(DG);
     */

    PVector AAB = PVector.sub(A, AB).normalize();
    PVector BAB = AAB.copy().mult(-1);
    PVector BBC = PVector.sub(B, BC).normalize();
    PVector CBC = BBC.copy().mult(-1);
    PVector CCD = PVector.sub(C, CD).normalize();
    PVector DCD = CCD.copy().mult(-1);
    PVector DDA = PVector.sub(D, DA).normalize();
    PVector ADA = DDA.copy().mult(-1);

    AAB.mult(maxDeviation * deviationSub);
    BAB.mult(maxDeviation * deviationSub);
    BBC.mult(maxDeviation * deviationSub);
    CBC.mult(maxDeviation * deviationSub);
    CCD.mult(maxDeviation * deviationSub);
    DCD.mult(maxDeviation * deviationSub);
    DDA.mult(maxDeviation * deviationSub);
    ADA.mult(maxDeviation * deviationSub);

    AAB.add(AB);
    BAB.add(AB);
    BBC.add(BC);
    CBC.add(BC);
    CCD.add(CD);
    DCD.add(CD);
    DDA.add(DA);
    ADA.add(DA);

    PVector GAAB = PVector.sub(AAB, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GBAB = PVector.sub(BAB, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GBBC = PVector.sub(BBC, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GCBC = PVector.sub(CBC, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GCCD = PVector.sub(CCD, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GDCD = PVector.sub(DCD, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GDDA = PVector.sub(DDA, gravity).normalize().mult(maxDeviation * deviationSub);
    PVector GADA = PVector.sub(ADA, gravity).normalize().mult(maxDeviation * deviationSub);

    AAB.add(GAAB);  
    BAB.add(GBAB);
    BBC.add(GBBC);
    CBC.add(GCBC);
    CCD.add(GCCD);
    DCD.add(GDCD);
    DDA.add(GDDA);
    ADA.add(GADA);

    iteration --;
    subdivQuad(gravity, BAB, B, BBC, iteration, maxIteration, deviation, deviationSub);
    subdivQuad(gravity, CBC, C, CCD, iteration, maxIteration, deviation, deviationSub);
    subdivQuad(gravity, DCD, D, DDA, iteration, maxIteration, deviation, deviationSub);
    subdivQuad(gravity, ADA, A, AAB, iteration, maxIteration, deviation, deviationSub);
  }
}

PVector getGravityCenter(PVector A, PVector B, PVector C) {
  PVector gravity = new PVector();
  gravity.add(A);
  gravity.add(B);
  gravity.add(C);
  gravity.div(3);
  return gravity;
}

PVector getCenter(PVector A, PVector B) {
  PVector gravity = new PVector();
  gravity.add(A);
  gravity.add(B);
  gravity.div(2);
  return gravity;
}

void exportSVG(String name, ArrayList<PVector> vList, int w, int h) {
  String exportName = name+".svg";
  PGraphics pg = createGraphics(w, h, SVG, exportName);
  pg.beginDraw();
  pg.stroke(255, 50);
  pg.noFill();
  pg.beginShape(QUADS);
  for (int i=4; i<vList.size(); i+=4) {
    PVector v1 = vList.get(i);
    PVector v2 = vList.get(i+1);
    PVector v3 = vList.get(i+2);
    PVector v4 = vList.get(i+3);

    pg.vertex(v1.x, v1.y);
    pg.vertex(v2.x, v2.y);
    pg.vertex(v3.x, v3.y);
    pg.vertex(v4.x, v4.y);
  }
  pg.endShape();
  pg.endDraw();
  pg.dispose();
  println(exportName + " svg saved.");
}



void keyPressed() {
}
