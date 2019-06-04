
/*
void loadDefaults() {
  // in main .pde
}
*/

void savePreferences() {

  String[] preferences = {
    "autostartChrome=" + (autostartChrome ? 1 : 0),
    "alwaysOnTop=" + (alwaysOnTop ? 1 : 0),
    "useArduino=" + (useArduino ? 1 : 0),
    "autoselectPort=" + (autoselectPort ? 1 : 0),
    "arduinoPort=" + arduinoPort,
    "autoloadDatabase=" + (autoloadDatabase ? 1 : 0),
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
    "standbyTimeout=" + standbyTimeout,
    "standby_font_size=" + 20,
    "standby_pulse_speed=" +  15,
    "",
    "// messages",
    "str_connecting=" + "connecting...",
    "str_waiting=" + "waiting for word",
    "str_searching=" + "(searching...)",
    "str_listening=" + "(listening...)",
    "str_no_results=" + "(no results)",
    "// loading message also in arduino code",    
    "str_loading=" + "loading...",
    ""
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
  autostartChrome = Integer.parseInt(data[vars.indexOf("autostartChrome")]) > 0 ? true : false;
  useArduino = Integer.parseInt(data[vars.indexOf("useArduino")]) > 0 ? true : false;
  autoselectPort = Integer.parseInt(data[vars.indexOf("autoselectPort")]) > 0 ? true : false;
  autoloadDatabase = Integer.parseInt(data[vars.indexOf("autoloadDatabase")]) > 0 ? true : false;
  alwaysOnTop = Integer.parseInt(data[vars.indexOf("alwaysOnTop")]) > 0 ? true : false;
  loadHighRes = Integer.parseInt(data[vars.indexOf("loadHighRes")]) > 0 ? true : false;

  // strings
  arduinoPort = data[vars.indexOf("arduinoPort")];
  dataPath = data[vars.indexOf("dataPath")];
  str_connecting = data[vars.indexOf("str_connecting")];
  str_waiting = data[vars.indexOf("str_waiting")];
  str_searching = data[vars.indexOf("str_searching")];
  str_listening = data[vars.indexOf("str_listening")];
  str_no_results = data[vars.indexOf("str_no_results")];
  str_loading = data[vars.indexOf("str_loading")];
  
  // ints
  windowWidth = Integer.parseInt(data[vars.indexOf("windowWidth")]);
  windowHeight = Integer.parseInt(data[vars.indexOf("windowHeight")]);
  exportWidth = Integer.parseInt(data[vars.indexOf("exportWidth")]);
  fadeSpeed = Integer.parseInt(data[vars.indexOf("fadeSpeed")]);
  columns = Integer.parseInt(data[vars.indexOf("columns")]);
  rows = Integer.parseInt(data[vars.indexOf("rows")]);
  standby_font_size = Integer.parseInt(data[vars.indexOf("standby_font_size")]);
  standby_pulse_speed = Integer.parseInt(data[vars.indexOf("standby_pulse_speed")]);

  // floats
  xMargin = Float.parseFloat(data[vars.indexOf("xMargin")]);
  yMargin = Float.parseFloat(data[vars.indexOf("yMargin")]);
  padding = Float.parseFloat(data[vars.indexOf("padding")]);

  // longs
  standbyTimeout = Long.parseLong(data[vars.indexOf("standbyTimeout")]);

}