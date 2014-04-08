class Timeline {
  HScrollbar scroller;
  float timelineXBegin, timelineYBegin, timelineXWidth, timelineXHeight;
  int smoothness = 3;
  ArrayList<Integer> years;
  int year;
  HashMap<Region, Integer> regionToYear;
  Region[] regions;
  boolean paused;
  
  Timeline(float timelineXBegin, float timelineYBegin, float timelineXWidth, float timelineXHeight, 
           ArrayList<Integer> years) {
    this.timelineXBegin = timelineXBegin;
    this.timelineYBegin = timelineYBegin;
    this.timelineXWidth = timelineXWidth;
    this.timelineXHeight = timelineXHeight;
    this.years = years;
    
    regionToYear = new HashMap<Region, Integer>();
    scroller = new HScrollbar(timelineXBegin, timelineYBegin, (int)timelineXWidth, (int)timelineXHeight, 3);
    
    // display years above the timeline
    float currentXToDrawYear = timelineXBegin;
    float newXToDrawYear;
    Region currentRegion;
    regionToYear = new HashMap<Region, Integer>();
    regions = new Region[years.size()];
    
    boolean above = true;
    
    for(int i = 0; i < years.size(); i++) {
      newXToDrawYear = currentXToDrawYear + (timelineXWidth/(years.size()-1));
      currentRegion = new Region(currentXToDrawYear, newXToDrawYear);
      regionToYear.put(currentRegion, years.get(i));
      regions[i] = currentRegion;
      currentXToDrawYear = newXToDrawYear;
      above = !above;
    }
  }
  
  void display() {
    if(!paused)
      scroller.slowSlide();
    scroller.update();
    scroller.display();
    
    // find the region the slider is in right now and update the pie chart
    for (int i = 0; i < regions.length; i++) {
      if (regions[i].begin <= scroller.spos && scroller.spos < regions[i].end) {
         year = regionToYear.get(regions[i]);
         break;
      }
    }
    
    float currentXToDrawYear = timelineXBegin;
    boolean above = true;
    
    for(int i = 0; i < years.size(); i++) {
      textFont(createFont("Sans Serif", 10));
      textAlign(CENTER, CENTER); // restated for clarity
      if (years.get(i) == year) 
        fill(255, 0, 0);
      else 
        fill(128);
      text(String.valueOf(years.get(i)), currentXToDrawYear, above ? timelineYBegin - 20 : timelineYBegin + 15);
      above = !above;
      currentXToDrawYear += (timelineXWidth/(years.size()-1));
    }
  }
  
  int getCurrentYear() {
    return year;
  }
  
  void setPause(boolean paused) {
    this.paused = paused;
  }
}


