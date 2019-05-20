
/*
void loadDefaults() {
  // in main .pde
}
*/

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
    "padding=" + padding,
    "",
    "// standby timeout is in seconds",
    "standbyTimeout=" + standbyTimeout
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
    //loadDefaults();
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

  // longs
  standbyTimeout = Long.parseLong(data[vars.indexOf("standbyTimeout")]);

}