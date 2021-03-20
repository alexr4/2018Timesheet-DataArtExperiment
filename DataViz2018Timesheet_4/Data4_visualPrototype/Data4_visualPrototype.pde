String[] days = {"M", "T", "W", "T", "F", "S", "S"};

PFont BluuNext, GapSans;

PGraphics buffer;

void setup() {
  size(1000, 1000, P2D);

  BluuNext = createFont("BluuNext-Bold.otf", 100);
  GapSans = createFont("GapSansBold.ttf", 100);

  buffer = createGraphics(width * 4, height * 4, P2D);
  buffer.smooth(8);

  computerBuffer(buffer);
  String it = year()+""+month()+""+day()+""+hour()+""+minute()+""+millis();
  buffer.save("buffer_"+it+".tif");
  //exit();
}

void draw() {
  image(buffer, 0, 0, width, height);
}

void computerBuffer(PGraphics buffer) {
  buffer.beginDraw();
  buffer.background(0);
  randomSeed(0);

  float nbDay = 365;
  float squareWidth = sqrt(nbDay);
  int gridWidth = ceil(squareWidth);

  float margin = 50;
  float res = (buffer.width - margin * 2.0) / gridWidth;

  for (int i=0; i<gridWidth; i++) {
    for (int j=0; j<gridWidth; j++) {
      float x = margin + res * i;// + res * 0.5;
      float y = margin + res * j;// + res * 0.5;
      float rand = random(1.0);
      float noise = noise(i * 0.5, j * 0.5);
      float randSize = 50;// + rand * (20 - 5);
      float noiseSize = 10;// + noise * (20 - 5);
      int day = (i + j * gridWidth);
      int modDay = day % 7;
      String txt = days[modDay];//.toLowerCase();//+(day + 1);
      //String txt = (day + 1) + "";
      if (rand > 0.25) {
        // txt = "1";
        //txt = "O";
        randSize = (5.0 + rand * 5.0) * 10;
        noiseSize = 5 + noise * (10);
      } else {
        //txt = "N";
        // txt = "0";
      }

      if ((day+1) > 365) {
        txt = "";
      }

      float hour = 24;
      float hourSqrt = sqrt(hour);
      int nbhour = ceil(hourSqrt);
      float hourmargin = res * 0.1;
      float hourres = (res - hourmargin *2.0) / nbhour;

      for (int k=0; k<nbhour; k++) {
        for (int l=0; l<nbhour; l++) {
          //float hx = hourmargin + k * hourres + x;// + res * 0.5;
          //float hy = hourmargin + l * hourres + y;// + res * 0.5;
          float minx =  hourmargin + 0 * hourres + x;// + res * 0.5;
          float maxx =  hourmargin + (nbhour - 1) * hourres + x;
          float miny = hourmargin + 0 * hourres + y;// + res * 0.5;
          float maxy = hourmargin + (nbhour - 1) * hourres + y;// + res * 0.5;
          float hx = random(minx, maxx);
          float hy = random(miny, maxy);
          
          float randhour = (random(1.0) > 0.5) ? 1.0 : 0.0;


          buffer.rectMode(CENTER);
          buffer.noStroke();
          buffer.fill(255, randhour * 255);
          buffer.ellipse(hx + hourres * 0.5, hy + hourres * 0.5, hourres * 1.0, hourres * 1.0);
        }
      }



      buffer.rectMode(CENTER);
      buffer.noFill();
      buffer.stroke(100);
      buffer.rect(x + res * 0.5, y + res * 0.5, res, res);
      // ellipse(x, y, res, res);
      /*
      buffer.noStroke();
       buffer.fill(0);
       buffer.textAlign(CENTER, CENTER);
       buffer.textFont(BluuNext);
       buffer.textSize(100);
       buffer.text(txt, x + res * 0.5, y + res * 0.5);
       */
    }
  }
  buffer.endDraw();
}
