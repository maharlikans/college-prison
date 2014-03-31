import java.util.Arrays;

class PieChart {
  String title;
  String[] headers;
  String[] races;
  ArrayList<Integer> years;
  HashMap<Integer, int[]> records;
  float xCenter;
  float yCenter;
  float diameter;
  Region[] angularRegions;
  
  // data for the little text box popup display
  boolean dataDisplayed;
  int currentYearDisplayed;
  int raceIndexDisplayed;
  float textDisplayX;
  float textDisplayY;
  float textDisplayWidth;
  float textDisplayHeight;
  int[] record;

  public PieChart(String title, float x, float y, float diameter) {
    this.title = title;
    xCenter = x;
    yCenter = y;
    this.diameter = diameter;
    
    textDisplayWidth = 100;
    textDisplayHeight = 100;
  }

  void initializeData(String csvFile) {
    try {
      BufferedReader scan = createReader(csvFile);

      // read first few lines of the record
      int numRecords = Integer.parseInt(scan.readLine());
      headers = scan.readLine().split(",");
      int numHeaders = headers.length;
      races = Arrays.copyOfRange(headers, 2, headers.length);
      
      // now read all the records
      records = new HashMap<Integer, int[]>();
      years = new ArrayList<Integer>();
      String[] currentRecord = null;
      int[] convertedRecord;
      int currentYear;
        
      for (int i = 0; i < numRecords; i++) {
        currentRecord = scan.readLine().split(",");
        convertedRecord = new int[numHeaders-1]; // -1 because the year is always the first item in the record
        currentYear = Integer.parseInt(currentRecord[0]);
        for (int j = 1; j < numHeaders; j++) {
          convertedRecord[j-1] = Integer.parseInt(currentRecord[j]);
        }
        if (convertedRecord[2] != -1) 
          records.put(currentYear, convertedRecord);
        if (!years.contains(currentYear))
          years.add(currentYear);
      }
        
      Collections.sort(years);
    } catch (IOException e) {
      // nothing, shouldn't happen
    }
  }

  void display(int year, HashMap<String, Color> racesToColors) {
    
    currentYearDisplayed = year;
    
    // make the title of the chart
    textFont(createFont("Georgia", 20));
    fill(128);
    textAlign(CENTER, CENTER);
    text(title, xCenter, yCenter - yCenter/2);
    
    record = records.get(year);
    if (record == null) {
      // a record wasn't found for this year, so draw the closest pie chart available...
      for (int i = 1; ; i++) {
        if (records.get(year-i) != null) {
          record = records.get(year-i);
          break;
        }
        else if (records.get(year+i) != null){
          record = records.get(year+i);
          break;
        }
      }
    }
    
    // generate the angles based on 360 degrees and percentages
    int totalPopulation = record[0];
    float[] angles = new float[races.length];
    angularRegions = new Region[races.length];

    for(int i = 1; i <= angles.length; i++) {
      angles[i-1] = 360*(((float)record[i])/(float)totalPopulation);
    }
    
    // make the pie chart with the calculated values
    float lastAngle = 0;
    for (int i = 0; i < angles.length; i++) {
     fill(racesToColors.get(races[i]).aColor);
     arc(xCenter, yCenter, diameter, diameter, lastAngle, lastAngle+radians(angles[i]));
     angularRegions[i] = new Region(lastAngle, lastAngle+radians(angles[i]));
     lastAngle += radians(angles[i]);
    }
    
    // display the text display
    if (dataDisplayed) {
      String toDisplay = "Total: " + record[0] + "\n"
                       + races[raceIndexDisplayed] + ": " + record[raceIndexDisplayed+1];
      fill(200, 80);
      rectMode(CORNER);
      rect(textDisplayX, textDisplayY, textDisplayWidth, textDisplayHeight);
      
      fill(0);
      textFont(createFont("Arial", 10, true), 10);
      text(toDisplay, textDisplayX + textDisplayWidth/2, textDisplayY + textDisplayHeight/2);
    }
  }
  
//  void detectCollision() {
//    if (sq(mouseX - xCenter) + sq(mouseY - yCenter) <= sq(diameter/2)) {
//      float angleFromCenter = atan2(mouseY - yCenter,  mouseX - xCenter);
//      if (angleFromCenter < 0) {
//        angleFromCenter = PI + ( PI + angleFromCenter); 
//      }
//      // TODO implement searching each region to see if this angle fits in the regions
//      for (int i = 0; i < angularRegions.length; i++) {
//        if (angleFromCenter >= angularRegions[i].begin && angleFromCenter <= angularRegions[i].end) {
//          System.out.println("Currently hovering over " + races[i]);
//        } 
//      }
//    }
//  }
  
  void onClick(int x, int y) {
    
    // first check to see if there's a box up
    // if so, then if the person clicked in the box, get rid of it
    // otherwise, if the person didn't click in the box... do all the following below...
    if (sq(x - xCenter) + sq(y - yCenter) <= sq(diameter/2)) {
      float angleFromCenter = atan2(y - yCenter,  x - xCenter);
      
      // negative angles must be adjusted for
      if (angleFromCenter < 0) {
        angleFromCenter = PI + ( PI + angleFromCenter); 
      }
      
      // search for the region in which they clicked, corresponding to the
      // race which they'd like to see data for 
      for (int i = 0; i < angularRegions.length; i++) {
        if (angleFromCenter >= angularRegions[i].begin && angleFromCenter <= angularRegions[i].end) {
          dataDisplayed = true;
          textDisplayX = x;
          textDisplayY = y;
          raceIndexDisplayed = i;
        }
      }
    }
    
    // TODO if you click in a box then get rid of the box
  }
  
  boolean clickedInTextBox(int x, int y) {
    if (x >= textDisplayX && x <= textDisplayX + textDisplayWidth) {
      if (y >= textDisplayY && y <= textDisplayY + textDisplayHeight) {
        return true; 
      }
    }
    return false;
  }
}

