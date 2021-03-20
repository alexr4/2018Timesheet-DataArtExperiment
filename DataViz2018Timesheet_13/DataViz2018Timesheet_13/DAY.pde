class HourData {
  public float value; //minute value (fractional part of data)
  public boolean isWorked;
  public float normValue = 0.0;

  HourData(boolean isWorked, float value) {
    this.isWorked = isWorked;
    this.value = value;
  }
  
  HourData(boolean isWorked) {
    this.isWorked = isWorked;
    this.value = 0.0;
  }
}
