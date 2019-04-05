
void loadDefaults() {

  // bools
  piMode = true;
  alwaysOnTop = false;
  loadHighRes = true;

  // strings
  arduinoPort = "/dev/ttyACM0";
  dataPath = "/home/pi/arquivista_data/";

  // ints
  windowWidth = 1024;
  windowHeight = 768;
  exportWidth = 3500;
  fadeSpeed = 15;
  columns = 4;
  rows = 4;

  // floats
  xMargin = 0.05;
  yMargin = 0.04;
  padding = 0.1;

}


void savePreferences() {

  String[] preferences = {
    "// enable raspberry pi mode (autostart chrome, autoselect serial port and database folder)",
    "piMode=" + (piMode ? 1 : 0),
    "alwaysOnTop=" + (alwaysOnTop ? 1 : 0),
    "arduinoPort=" + arduinoPort,
    "dataPath=" + dataPath,
    "",
    "windowWidth=" + windowWidth,
    "windowHeight=" + windowHeight,
    "",
    "// image size for high-res export",
    "exportWidth=" + exportWidth,
    "// enable loading high-res source images for export",
    "loadHighRes=" + (loadHighRes ? 1 : 0),
    "",
    "fadeSpeed=" + fadeSpeed,
    "columns=" + columns,
    "rows=" + rows,
    "",
    "// margins are percentage of total width",
    "xMargin=" + xMargin,
    "yMargin=" + yMargin,
    "",
    "// padding is percentage of photoWidth",
    "padding=" + padding
  };
  saveStrings("../preferences.txt", preferences);

}


void loadPreferences() {

  String data[] = new String[0];
  File preferences = new File(sketchPath("../preferences.txt"));
  if (preferences.exists())  {
    data = loadStrings(preferences);
    parsePreferences(data);
  } else {
    println("no preferences file found, loading defaults");
    loadDefaults();
    savePreferences();
    println("saved new prefrences file");
  }
}


void parsePreferences(String[] data) {

  ArrayList<String> vars = new ArrayList<String>();

  for(int i=0; i<data.length; i++) {
    int h = data[i].indexOf("=");
    if (h>0) {
      vars.add(data[i].substring(0,h));
      data[i] = data[i].substring(h+1);
    } else {
      vars.add(data[i]);
    }
  }
  
  // bools
  piMode = Integer.parseInt(data[vars.indexOf("piMode")]) > 0 ? true : false;
  alwaysOnTop = Integer.parseInt(data[vars.indexOf("alwaysOnTop")]) > 0 ? true : false;
  loadHighRes = Integer.parseInt(data[vars.indexOf("loadHighRes")]) > 0 ? true : false;

  // strings
  arduinoPort = data[vars.indexOf("arduinoPort")];
  dataPath = data[vars.indexOf("dataPath")];

  // ints
  windowWidth = Integer.parseInt(data[vars.indexOf("windowWidth")]);
  windowHeight = Integer.parseInt(data[vars.indexOf("windowHeight")]);
  exportWidth = Integer.parseInt(data[vars.indexOf("exportWidth")]);
  fadeSpeed = Integer.parseInt(data[vars.indexOf("fadeSpeed")]);
  columns = Integer.parseInt(data[vars.indexOf("columns")]);
  rows = Integer.parseInt(data[vars.indexOf("rows")]);

  // floats
  xMargin = Float.parseFloat(data[vars.indexOf("xMargin")]);
  yMargin = Float.parseFloat(data[vars.indexOf("yMargin")]);
  padding = Float.parseFloat(data[vars.indexOf("padding")]);

}