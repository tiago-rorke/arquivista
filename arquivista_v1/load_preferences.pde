void loadPreferences() {

  String data[] = loadStrings(sketchPath("/home/pi/arquivista/preferences.txt"));
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
