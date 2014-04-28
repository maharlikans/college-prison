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
  boolean textBoxDisplayed;
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
    
//    textDisplayWidth = 100;
//    textDisplayHeight = 100;
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
    textFont(createFont("MyriadPro-Bold", 20));
    fill(225);
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
     stroke(220);
     arc(xCenter, yCenter, diameter, diameter, lastAngle, lastAngle+radians(angles[i]), PIE);
     angularRegions[i] = new Region(lastAngle, lastAngle+radians(angles[i]));
     lastAngle += radians(angles[i]);
    }
    
    int indexToDarken = hover(mouseX, mouseY);
    if (indexToDarken != -1) {
     fill(220);
     stroke(220);
     arc(xCenter, yCenter, diameter, diameter, angularRegions[indexToDarken].begin, angularRegions[indexToDarken].end, PIE);
    }
    
    // display the text display
    if (textBoxDisplayed) {
      float d = 100*((float)record[raceIndexDisplayed+1]/record[0]);
      String toDisplay = "total: " + record[0] + "\n"
                       + races[raceIndexDisplayed] + ": " + record[raceIndexDisplayed+1] + "\n"
                       + "percentage: " + nf(d, 2, 2) + "%";
                       
      textFont(createFont("MyriadPro-Regular", 15, true));
      textDisplayWidth = textWidth(toDisplay);
      textDisplayHeight = 4*(textAscent() + textDescent());
      fill(racesToColors.get(races[raceIndexDisplayed]).aColor);
      rectMode(CENTER);
      rect(textDisplayX, textDisplayY, textDisplayWidth + 20, textDisplayHeight + 20, 7);
      
      fill(255);
      stroke(220);
      textAlign(CENTER, CENTER);
      text(toDisplay, textDisplayX, textDisplayY);
    }
  }
  
  void onClick(int x, int y) {
    // if the person clicks in the text box, get rid of it
    // and do nothing else
    if (textBoxDisplayed) {
      if (clickedInTextBox(x, y)) {
        textBoxDisplayed = false;
        return;
      }
    }
    
    // check if the person clicked in the pie
    // and set the text box correctly if they did
    int previousIndex = raceIndexDisplayed;
    raceIndexDisplayed = hover(x, y);
    if (raceIndexDisplayed != -1) {
      textBoxDisplayed = true;
      textDisplayX = xCenter;
      textDisplayY = yCenter + yCenter/2;
    } else {
      raceIndexDisplayed = previousIndex;
    }
  }
  
  // simply check if a person clicked within the text box if it is being displayed
  boolean clickedInTextBox(int x, int y) {
    if (x >= textDisplayX - textDisplayWidth/2 && x <= textDisplayX + textDisplayWidth/2) {
      if (y >= textDisplayY - textDisplayHeight/2 && y <= textDisplayY + textDisplayHeight/2) {
        return true; 
      }
    }
    return false;
  }
  
  // returns the region the user is currently hovering over
  int hover(int x, int y) {
    int index = -1;
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
          index = i;
          return index;
        }
      }
    }
    return index;
  }
}

