/* TODO: still need to edit the years in this class so the timeline can display correctly and work correctly
 * needs to be retrieved from each of the pie classes */

import java.io.BufferedReader;
import java.io.IOException;
import java.io.File;
import java.lang.StringBuffer;
import java.util.Arrays;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.Collections;

PieChart collegePie, prisonPie, americanPie; // I know you're shaking your head here but I had to do it
String[] races;
Timeline timeline;
HashMap<String, Color> racesToColors;
HashMap<Region, Integer> regionToYear;
ArrayList<Integer> years;
Region[] regions;
int year;
float circleDiameter;
float timelineXBegin, timelineYBegin, timelineXWidth;

void setup () {
  size(1024,768);
  background(255);
  
  circleDiameter = width/5;
  
  // determine center points of all pies
  float prisonxCenter = width*(3.0/8) - width*(1.0/32);
  float prisonyCenter = height/2;
  
  float collegexCenter = width*(5.0/8) - width*(1.0/32);
  float collegeyCenter = height/2;
  
  float usxCenter = width*(7.0/8) - width*(1.0/32);
  float usyCenter = height/2;
  
  // initialize each piechart
  prisonPie = new PieChart("Prison", prisonxCenter, prisonyCenter, circleDiameter);
  collegePie = new PieChart("College", collegexCenter, collegeyCenter, circleDiameter);
  americanPie = new PieChart("United States", usxCenter, usyCenter, circleDiameter);
  
  // read the data from the appropriate files
  prisonPie.initializeData("prisondata.csv");
  collegePie.initializeData("collegedata.csv");
  americanPie.initializeData("usdata.csv");
  
  years = new ArrayList<Integer>();
  for (Integer year : prisonPie.years) 
    if (!years.contains(year))
      years.add(year);
  
  for (Integer year : collegePie.years) 
    if (!years.contains(year))
      years.add(year);
  
  for (Integer year : americanPie.years) 
    if (!years.contains(year))
      years.add(year);
      
  Collections.sort(years);
  year = years.get(0);
  
  // initialize the timeline
  float timelineXBegin = float(width)/8;
  float timelineYBegin = height*(7.0/8);
  float timelineXWidth = width*(7.0/8) - width/8;
  float timelineXHeight = 10;

  timeline = new Timeline(timelineXBegin, timelineYBegin, timelineXWidth, timelineXHeight, years);
  
  // display all elements
  printTitles();
  determineColors();
  printLegend();
  collegePie.display(year, racesToColors);
  prisonPie.display(year, racesToColors);
  americanPie.display(year, racesToColors);
  timeline.display();
}


void draw () {
  rectMode(CORNER);
  background(255);
  
  
  
  timeline.display();
  year = timeline.getCurrentYear();
  printTitles();
  printLegend();
  collegePie.display(year, racesToColors);
  prisonPie.display(year, racesToColors);
  americanPie.display(year, racesToColors);
  
}

/* HELPER FUNCTIONS */

void printTitles() {
  // print main title
  textFont(createFont("Georgia", 30));
  fill(0);
  textAlign(CENTER, CENTER);
  text("Racial Demographics of Prisons vs. Colleges", width/2, height/8);
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
  if (collegePie.headers.length > prisonPie.headers.length) {
    races = Arrays.copyOfRange(collegePie.headers, 2, collegePie.headers.length); // starts at 2 because the records follow through as year, total, firstrace, secondrace, ...
  } else {
    races = Arrays.copyOfRange(prisonPie.headers, 2, prisonPie.headers.length);
  }
  
  // determine mapping of race to color
  racesToColors = new HashMap<String, Color>();
  for (int i = 0; i < races.length; i++) {
    racesToColors.put(races[i], new Color(colors[i]));
  } 
}
