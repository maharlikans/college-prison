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

  public PieChart(String title, float x, float y, float diameter) {
    this.title = title;
    xCenter = x;
    yCenter = y;
    this.diameter = diameter;
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
    // make the title of the chart
    textFont(createFont("Georgia", 20));
    fill(128);
    textAlign(CENTER, CENTER);
    text(title, xCenter, yCenter - yCenter/2);
    
    int[] record = records.get(year);
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

    for(int i = 1; i <= angles.length; i++) {
      angles[i-1] = 360*(((float)record[i])/(float)totalPopulation);
    }
    
    // make the pie chart with the calculated values
    float lastAngle = 0;
    for (int i = 0; i < angles.length; i++) {
     fill(racesToColors.get(races[i]).aColor);
     arc(xCenter, yCenter, diameter, diameter, lastAngle, lastAngle+radians(angles[i]));
     lastAngle += radians(angles[i]);
    }
  }
}

