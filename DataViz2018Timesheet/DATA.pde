class DayDatas {
  private String year = "2018";
  private String month, day, weekday;
  private String start, slunch, elunch, end;

  private int iyear = 2018;
  private int imonth, iday, iweekday;

  private int istart, islunch, ielunch, iend;
  private float fstart, fslunch, felunch, fend;
  private float fsstart, fsend;
  private boolean isSup;

  DayDatas(int iyear, String month, String day, String weekday, String start, String slunch, String elunch, String end) {
    this.iyear = iyear;

    this.year = String.valueOf(this.iyear);
    this.month = month;
    this.day = day;
    this.weekday = weekday;
    this.start = start;
    this.slunch = slunch;
    this.elunch = elunch;
    this.end = end;

    convertData();
  }

  private void convertData() {
    convertDateToNumber();

    istart = convertTimeDataToNumber(start);
    islunch = convertTimeDataToNumber(slunch);
    ielunch = convertTimeDataToNumber(elunch);
    iend = convertTimeDataToNumber(end);

    fstart = (float) istart / (24.0 * 60 * 60);
    fslunch = (float) islunch / (24.0 * 60 * 60);
    felunch = (float) ielunch / (24.0 * 60 * 60);
    fend = (float) iend / (24.0 * 60 * 60);
    
    //check hour sup
    if(fend < felunch){
      fsstart = 0.0;
      fsend = fend;
      fend = 1.0;
      isSup = true;
    }
    
    if(fslunch == felunch && felunch == 0 && fstart !=0 && fend !=0){
      fslunch = felunch = 0.5;
    }
  }

  private int convertTimeDataToNumber(String data) {
    String[] splitedData = split(data, ":");
    int hour = 0;
    for (int i=0; i<splitedData.length; i++) {
      if (!splitedData[i].isEmpty()) {
        int dataAsNumber = Integer.parseInt(splitedData[i]);
        float fdataAsNumber = dataAsNumber * pow(60.0, 2.0 - i);
        hour += fdataAsNumber;
      }
    }
    return hour;
  }

  private void convertDateToNumber() {
    convertMonthToNumber(this.month);
    convertWeekDayToNumber(this.weekday);
    convertDayToNumber(this.day);
  }

  private void convertMonthToNumber(String month) {
    month = month.toLowerCase();
    switch(month) {
    case "janvier" : 
      this.imonth = 1;
      break;
    case "février" : 
    case "fevrier" : 
      this.imonth = 2;
      break;
    case "mars" : 
      this.imonth = 3;
      break;
    case "avril" : 
      this.imonth = 4;
      break;
    case "mai" : 
      this.imonth = 5;
      break;
    case "juin" : 
      this.imonth = 6;
      break;
    case "juillet" : 
      this.imonth = 7;
      break;
    case "aout" : 
    case "août" : 
      this.imonth = 8;
      break;
    case "septembre" : 
      this.imonth = 9;
      break;
    case "octobre" : 
      this.imonth = 10;
      break;
    case "novembre" : 
      this.imonth = 11;
      break;
    case "décembre" : 
    case "decembre" : 
      this.imonth = 12;
      break;
    }
  }

  private void convertWeekDayToNumber(String weekday) {
    weekday = weekday.toLowerCase();
    switch(weekday) {
    case "lundi" :
      this.iweekday = 1;
      break;
    case "mardi" :
      this.iweekday = 2;
      break;
    case "mercredi" :
      this.iweekday = 3;
      break;
    case "jeudi" :
      this.iweekday = 4;
      break;
    case "vendredi" :
      this.iweekday = 5;
      break;
    case "samedi" :
      this.iweekday = 6;
      break;
    case "dimanche" :
      this.iweekday = 7;
      break;
    }
  }

  private void convertDayToNumber(String day) {
    day = day.toLowerCase();
    String[] splitedDay = split(day, "/");
    this.iday = Integer.parseInt(splitedDay[0]);
  }
}
