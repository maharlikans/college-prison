import java.io.BufferedReader;
import java.io.IOException;
import java.io.File;
import java.lang.StringBuffer;
import java.util.Arrays;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;

String[] collegeHeaders;
String[] prisonHeaders;
String[] usHeaders;
HashMap<Integer, int[]> collegeRecords;
HashMap<Integer, int[]> prisonRecords;
HashMap<Integer, int[]> usRecords;
String[] races;
HashMap<String, Color> racesToColors;
HashMap<Region, Integer> regionToYear;
Region[] regions;
ArrayList<Integer> years;
int year;
float prisonxCenter, prisonyCenter, circleDiameter;
float collegexCenter, collegeyCenter;
float usxCenter, usyCenter;
float timelineXBegin, timelineYBegin, timelineXWidth;
HScrollbar timeline;

void setup () {
  size(1024,768);
  background(255);
  
  parseData();
  printTitles();
  determineColors();
  printLegend();
  
  // circle diameter
  circleDiameter = width/5;
  
  // prison circle
  prisonxCenter = width*(3.0/8) - width*(1.0/32);
  prisonyCenter = height/2;
  
  // college circle
  collegexCenter = width*(5.0/8) - width*(1.0/32);
  collegeyCenter = height/2;
  
  // us whole circle
  usxCenter = width*(7.0/8) - width*(1.0/32);
  usyCenter = height/2;
  
  year = years.get(0);
  pieChart(prisonxCenter, prisonyCenter, circleDiameter, Arrays.copyOfRange(prisonHeaders, 2, prisonHeaders.length), prisonRecords.get(year));
  fill(0);

  pieChart(collegexCenter, collegeyCenter, circleDiameter, Arrays.copyOfRange(collegeHeaders, 2, collegeHeaders.length), collegeRecords.get(year));
  fill(0);
  
  pieChart(usxCenter, usyCenter, circleDiameter, Arrays.copyOfRange(usHeaders, 2, usHeaders.length), usRecords.get(year));
  fill(0);
  
  displayTimeline();
}


void draw () {
  timeline.slowSlide();
  rectMode(CORNER);
  background(255);
  
  boolean prisonDataFound = false;
  boolean collegeDataFound = false;
  boolean usDataFound = false;
  int year = -1;
  // find the region the slider is in right now and update the pie chart
  for (int i = 0; i < regions.length; i++) {
    if (regions[i].begin <= timeline.spos && timeline.spos < regions[i].end) {
       year = regionToYear.get(regions[i]);
       prisonDataFound = pieChart(prisonxCenter, prisonyCenter, circleDiameter, Arrays.copyOfRange(prisonHeaders, 2, prisonHeaders.length), prisonRecords.get(year));
       fill(0);
          
       collegeDataFound = pieChart(collegexCenter, collegeyCenter, circleDiameter, Arrays.copyOfRange(collegeHeaders, 2, collegeHeaders.length), collegeRecords.get(year));
       fill(0);
       
       usDataFound = pieChart(usxCenter, usyCenter, circleDiameter, Arrays.copyOfRange(usHeaders, 2, usHeaders.length), usRecords.get(year));
       fill(0);
    }
  }
  
  // if no data found, update with closest region
  if (!prisonDataFound) {
    for (int i = 1; ; i++) {
      if (pieChart(prisonxCenter, prisonyCenter, circleDiameter, Arrays.copyOfRange(prisonHeaders, 2, prisonHeaders.length), prisonRecords.get(year-i))
          || pieChart(prisonxCenter, prisonyCenter, circleDiameter, Arrays.copyOfRange(prisonHeaders, 2, prisonHeaders.length), prisonRecords.get(year+i)))
        break;
    }
  }
  
  if (!collegeDataFound) {
    for (int i = 1; ; i++) {
      if (pieChart(collegexCenter, collegeyCenter, circleDiameter, Arrays.copyOfRange(collegeHeaders, 2, collegeHeaders.length), collegeRecords.get(year-i))
          || pieChart(collegexCenter, collegeyCenter, circleDiameter, Arrays.copyOfRange(collegeHeaders, 2, collegeHeaders.length), collegeRecords.get(year+i)))
        break;
    }
  }
  
  if (!usDataFound) {
    for (int i = 1; ; i++) {
      if (pieChart(usxCenter, usyCenter, circleDiameter, Arrays.copyOfRange(usHeaders, 2, usHeaders.length), usRecords.get(year-i)) 
          || pieChart(usxCenter, usyCenter, circleDiameter, Arrays.copyOfRange(usHeaders, 2, usHeaders.length), usRecords.get(year+i)))
        break;
    } 
  }
  
  timeline.update();
  timeline.display();
  printYears();
  printTitles();
  printLegend();
}

/* HELPER FUNCTIONS */

boolean pieChart(float xCenter, float yCenter, float circleDiameter, String[] races, int[] record) {
  // if record unavailable for this year, do nothing
  if (record == null) {
    // draw the same pie chart that's on the screen 
    return false;
  }
  
  // generate the angles based on 360 degrees and percentages
  int totalPopulation = record[0];
  float[] angles = new float[races.length];

  for(int i = 1; i <= angles.length; i++) {
    angles[i-1] = 360*(((float)record[i])/(float)totalPopulation);
  }
  
  // make the pie chart with the calculated values
  float lastAngle = 0;
  for (int i = 0; i < angles.length; i++) {
     fill(racesToColors.get(races[i]).aColor);
     arc(xCenter, yCenter, circleDiameter, circleDiameter, lastAngle, lastAngle+radians(angles[i]));
     lastAngle += radians(angles[i]);
  }
  
  return true;
}

void parseData() {
   BufferedReader cScan = createReader("collegedata.csv");
   BufferedReader pScan = createReader("prisondata.csv");
   BufferedReader uScan = createReader("usdata.csv");
   
   years = new ArrayList<Integer>();
   
   try {
     // read in initial data for college records
     int numRecordsCollege = Integer.parseInt(cScan.readLine());
     collegeHeaders = cScan.readLine().split(",");
     int numHeadersCollege = collegeHeaders.length;
     
     // read in initial data for prison records
     int numRecordsPrison = Integer.parseInt(pScan.readLine());
     prisonHeaders = pScan.readLine().split(",");
     int numHeadersPrison = prisonHeaders.length;
     
     // read in initial data for prison records
     int numRecordsUS = Integer.parseInt(uScan.readLine());
     usHeaders = uScan.readLine().split(",");
     int numHeadersUS = usHeaders.length;
     
     collegeRecords = createRecords(cScan, numRecordsCollege, numHeadersCollege);
     prisonRecords = createRecords(pScan, numRecordsPrison, numHeadersPrison);
     usRecords = createRecords(uScan, numRecordsUS, numHeadersUS);
   } catch (IOException e) {
     // nothing, shouldn't ever happen
   }
}

HashMap<Integer, int[]> createRecords(BufferedReader input, int numRecords, int numHeaders) {
  HashMap<Integer, int[]> records = new HashMap<Integer, int[]>();
  String[] currentRecord = null;
  int[] convertedRecord;
  int currentYear;
  
  for (int i = 0; i < numRecords; i++) {
    try {
      currentRecord = input.readLine().split(",");
    } catch (IOException e) {
      // nothing 
    }
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
  return records;
}

void printTitles() {
  // print main title
  textFont(createFont("Georgia", 30));
  fill(0);
  textAlign(CENTER, CENTER);
  text("Racial Demographics of Prisons vs. Colleges", width/2, height/8);
  
  // label all pie charts
  textFont(createFont("Georgia", 20));
  fill(128);
  textAlign(CENTER, CENTER); // restated for clarity
  text("Prison", prisonxCenter, height*(2.0/8));
  text("College", collegexCenter, height*(2.0/8));
  text("US Population", usxCenter, height*(2.0/8));
}

void printLegend() {
  // set up the legend at left 
  rectMode(CENTER);
  float legendWidth = width/8;
  float legendHeight = height/2;
  float legendStart = height/5;
  float legendCenter = width/8;
  fill(235);
  rect(width/8, height/2, legendWidth, legendHeight, 7);
  
  textFont(createFont("Bold Arial", 15));
  textAlign(CENTER, CENTER); // restated for clarity
  
  // print the text in the legend
  for(int i = 1; i <= races.length; i++) {
    fill(racesToColors.get(races[i-1]).aColor);
    text(races[i-1], legendCenter, legendStart + i*legendHeight/races.length);
  }
}

void determineColors() {
  // possible colors to use for the races
  color[] colors = {color(255, 0, 0), color(0, 0, 255), color(0, 255, 0), color(255, 255, 0), color(255, 0, 255), color(0, 255, 255)};

  // Determine which races to display
  // if one set of headers is longer than another, it has more racial categories in it
  // the array with a smaller number of headers is simply a subset of the larger number
  // of headers, so we must use all the racial categories provided by the longer set
  races = null;
  if (collegeHeaders.length > prisonHeaders.length) {
    races = Arrays.copyOfRange(collegeHeaders, 2, collegeHeaders.length); // starts at 2 because the records follow through as year, total, firstrace, secondrace, ...
  } else {
    races = Arrays.copyOfRange(prisonHeaders, 2, prisonHeaders.length);
  }
  
  // determine mapping of race to color
  racesToColors = new HashMap<String, Color>();
  for (int i = 0; i < races.length; i++) {
    racesToColors.put(races[i], new Color(colors[i]));
  } 
}

void displayTimeline() {
  // display the timeline
  timelineXBegin = float(width)/8;
  timelineYBegin = height*(7.0/8);
  timelineXWidth = width*(7.0/8) - width/8;
  int timelineXHeight = 10;
  
  timeline = new HScrollbar(timelineXBegin, timelineYBegin, (int)timelineXWidth, timelineXHeight, 3);
  timeline.display();
  
  // display years above the timeline
  rectMode(CENTER);
  float currentXToDrawYear = timelineXBegin;
  float newXToDrawYear;
  Region currentRegion;
  regionToYear = new HashMap<Region, Integer>();
  regions = new Region[years.size()];
  
  boolean above = true;
  
  for(int i = 0; i < years.size(); i++) {
    textFont(createFont("Sans Serif", 10));
    textAlign(CENTER, CENTER); // restated for clarity
    fill(0);
    text(String.valueOf(years.get(i)), currentXToDrawYear, above ? timelineYBegin - 20 : timelineYBegin + 15);
    newXToDrawYear = currentXToDrawYear + (timelineXWidth/(years.size()-1));
    currentRegion = new Region(currentXToDrawYear, newXToDrawYear);
    regionToYear.put(currentRegion, years.get(i));
    regions[i] = currentRegion;
    currentXToDrawYear = newXToDrawYear;
    above = !above;
  } 
}

void printYears() {
  float currentXToDrawYear = timelineXBegin;
  boolean above = true;
  
  for(int i = 0; i < years.size(); i++) {
    textFont(createFont("Sans Serif", 10));
    textAlign(CENTER, CENTER); // restated for clarity
    fill(128);
    text(String.valueOf(years.get(i)), currentXToDrawYear, above ? timelineYBegin - 20 : timelineYBegin + 15);
    above = !above;
    currentXToDrawYear += (timelineXWidth/(years.size()-1));
  }
}


/* DEBUGGING STATEMENTS */

void printCollegeData() {
  System.out.println("------COLLEGE DATA------");
  int[] currentRecord;
  for (int i = 1978; i <= 2010; i++) {
     currentRecord = collegeRecords.get(i);
     System.out.print("year: " + i + ", ");
     for (int j = 1; j <= currentRecord.length; j++) {
       System.out.print(collegeHeaders[j] + ": " + currentRecord[j-1] + ", ");
     }
     System.out.println();
  }
}

void printPrisonData() {
  System.out.println("------PRISON DATA------");
  int[] currentRecord;
  for (int i = 1978; i <= 2010; i++) {
     currentRecord = prisonRecords.get(i);
     System.out.print("year: " + i + ", ");
     for (int j = 1; j <= currentRecord.length; j++) {
       System.out.print(prisonHeaders[j] + ": " + currentRecord[j-1] + ", ");
     }
     System.out.println();
  }
}
