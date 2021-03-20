import java.util.Calendar;
import java.util.Date;
import java.util.TimeZone;

static class DayDatas {

  static public ArrayList<Float> convertData(int iyear, String month, String day, String weekday, String start, String slunch, String elunch, String end) {
    int imonth  = convertMonthToNumber(month);
    int iwday   = convertWeekDayToNumber(weekday);
    int[] iday  = convertDayToNumber(day);

    float fstart = convertTimeDataToNumber(start);
    float fslunch = convertTimeDataToNumber(slunch);
    float felunch = convertTimeDataToNumber(elunch);
    float fend = convertTimeDataToNumber(end);

    fend = (fend == 0.0 && felunch != 0.0) ? 24.0 : fend;

    ArrayList<Float> data = new ArrayList<Float>();
    data.add(fstart);
    data.add(fslunch);
    data.add(felunch);

    if (fend < felunch && felunch != 0.0) {
      //println("WAHOUUUUUU");
      data.add(24.0);
      data.add(0.0);
      data.add(fend);
    } else {
      data.add(fend);
    }

    Calendar c = Calendar.getInstance();
    c.set(Calendar.YEAR, iday[2]);
    c.set(Calendar.MONTH, iday[1] - 1);
    c.set(Calendar.DATE, iday[0]);
    int CurrentDayOfYear = c.get(Calendar.DAY_OF_YEAR) - 1;

    ArrayList<Float> fdata = new ArrayList<Float>();

    if (iday[2] == iyear) {
      for (float f : data) {
        fdata.add(f + CurrentDayOfYear * 24);
      }
    }
    return fdata;
  }

  static public float convertTimeDataToNumber(String data) {
    String[] splitedData = split(data, ":");
    float hour = 0;
    if (!splitedData[0].isEmpty()) {
      hour += Integer.parseInt(splitedData[0]);
      hour += (Integer.parseInt(splitedData[1]) / 60.0);
    }
    return hour;
  }



  static public int convertMonthToNumber(String month) {
    month = month.toLowerCase();
    int imonth = 0;
    switch(month) {
    case "janvier" : 
      imonth = 1;
      break;
    case "février" : 
    case "fevrier" : 
      imonth = 2;
      break;
    case "mars" : 
      imonth = 3;
      break;
    case "avril" : 
      imonth = 4;
      break;
    case "mai" : 
      imonth = 5;
      break;
    case "juin" : 
      imonth = 6;
      break;
    case "juillet" : 
      imonth = 7;
      break;
    case "aout" : 
    case "août" : 
      imonth = 8;
      break;
    case "septembre" : 
      imonth = 9;
      break;
    case "octobre" : 
      imonth = 10;
      break;
    case "novembre" : 
      imonth = 11;
      break;
    case "décembre" : 
    case "decembre" : 
      imonth = 12;
      break;
    }

    return imonth;
  }

  static public int convertWeekDayToNumber(String weekday) {
    weekday = weekday.toLowerCase();
    int iweekday = 0;
    switch(weekday) {
    case "lundi" :
      iweekday = 1;
      break;
    case "mardi" :
      iweekday = 2;
      break;
    case "mercredi" :
      iweekday = 3;
      break;
    case "jeudi" :
      iweekday = 4;
      break;
    case "vendredi" :
      iweekday = 5;
      break;
    case "samedi" :
      iweekday = 6;
      break;
    case "dimanche" :
      iweekday = 7;
      break;
    }
    return iweekday;
  }

  static public int[] convertDayToNumber(String day) {
    day = day.toLowerCase();
    String[] splitedDay = split(day, "/");
    int[] iday = new int[splitedDay.length];
    for (int i=0; i<splitedDay.length; i++) {
      iday[i] = Integer.parseInt(splitedDay[i]);
    }
    return iday;
  }
}
