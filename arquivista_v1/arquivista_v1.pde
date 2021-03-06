import controlP5.*;
import websockets.*;
import processing.serial.*;

import java.util.*;
import javax.swing.JOptionPane;
import java.awt.FileDialog;

import java.io.FileWriter;
import java.io.*;


// ----------------------------- PREFERENCES ------------------------------- //

// these are default values, they will be replaced
// by what is defined in preferences.txt

boolean autostartChrome = false;
boolean alwaysOnTop = false;
boolean useArduino = false;
boolean autoselectPort = false;
String arduinoPort = "/dev/ttyACM0";
boolean autoloadDatabase = false;
String dataPath = "/home/pi/arquivista_data/";

int windowWidth = 1024;
int windowHeight = 768;
int exportWidth = 3500; // image size for high-res export
boolean loadHighRes = true; // for export only
int fadeSpeed = 15;
int columns = 4;
int rows = 3;
float xMargin = 0.05; // percentage of total width
float yMargin = 0.04; // percentage of total width
float padding = 0.1;  // percentage of photoWidth

long standbyTimeout = 10000;

String str_connecting = "connecting...";
String str_waiting = "waiting for word";
String str_searching = "(searching...)";
String str_no_results = "(no results)";
String str_listening = "(listening...)";
String str_loading = "loading..."; // also hardcoded on arduino

int standby_font_size = 20;
int standby_pulse_speed = 15;

int stop_talk_delay = 500;


// --------------------------------- VARS ---------------------------------- //

// Setup
boolean gotPath = false;

// Visuals
PGraphics imgBuffer;
int fade = 0;
float photoWidth;
float xm, ym; // margin size in px
float xs, ys; // image size in px
int nc, nr; // number of rows and columns
boolean singleView = false; // single image view toggle
boolean standby = false;
boolean toStandby = false;
boolean leaveStandby = false;
long standbyTimer;
PFont standby_font;
int standby_fill = 0;
boolean standby_pulse_in = true;

// Metadata Tables
int numImages;       // total number of images in collection
String[] filenames;  // ID = index
String[] tags;       // all unique tags 
ArrayList<int[]> associations; // associations[i] = list of IDs associated with tags[i]
// duplicates of tags with accents are added to the end of the array
// cp5 doesn't seem to like accents, and i'm sure there will be 
// other scenarios where accents could be problematic
// we keep track of where the duplicates start, so we can ignore them when needed
int unaccentedIndex; 

// Search
StringList searchTerms = new StringList();
IntList imageIDs = new IntList(); // all search results
PImage[] images; // images to render
int page; // for handling multi-page results.
int numPages; // total number of pages for search result
boolean newSearch = false;
boolean refineSearch = false;

// Comms
WebsocketServer ws;
Serial arduino;
boolean ready = false;
int pingInterval = 15000; // ping after 15s of websockets inactivity
long wsTimer;

// GUI
ControlP5 cp5;
PFont font;
Textlabel searchLabel;
boolean showFrames = false;
boolean showImages = true;
boolean refresh = false;

// Print Quality Export
int exportHeight;
boolean export = false;
PGraphics exportRender;

// Logs
FileWriter logWriter;
BufferedWriter logBuffer;
File log;


// ========================================================================= //


void settings() {
  loadPreferences();
  size(windowWidth, windowHeight);
}


void setup() {

  noCursor();
  
  if(alwaysOnTop) surface.setAlwaysOnTop(true);

  imgBuffer = createGraphics(width, height);

  ws= new WebsocketServer(this,8080,"/arquivista");
  wsTimer = millis();
  
  if(useArduino) {
    if(autoselectPort) {
      println("connecting arduino on " + arduinoPort);
      arduino = new Serial(this, arduinoPort, 115200);
      arduino.bufferUntil('\n');
    } else {
      if(Serial.list().length > 0) {
        arduinoPort = (String) JOptionPane.showInputDialog(
          null, 
          "which port for arduino?", 
          "select port", 
          JOptionPane.PLAIN_MESSAGE, 
          null, 
          Serial.list(), 
          Serial.list()[Serial.list().length-1]
        );
        println("connecting arduino on " + arduinoPort);
        try {
          arduino = new Serial(this, arduinoPort, 115200);
          arduino.bufferUntil('\n');
        }
        catch(Exception e) {
          println("no arduino connected");
        }
      }
    }
  } else {
    println("no arduino connected");
  }

  // get database path
  if(!autoloadDatabase) {
    selectFolder("where is the database?", "selectDataPath");
  } else {
    gotPath = true;
  }
  while(!gotPath) {
    delay(100);
  }

  cp5 = new ControlP5(this);
  font = loadFont("NotoSans-12.vlw");
  cp5.setFont(font);
  cp5.addTextfield("search").setPosition(20, height-40).getCaptionLabel().setVisible(false);   
  searchLabel = cp5.addTextlabel("searchLabel").setText("").setPosition(20, height-60);
  searchLabel.setText(str_loading);
  cp5.get(Textfield.class,"search").setVisible(false);
  searchLabel.setVisible(false);

  exportHeight = int(exportWidth*height/width);

  String[] metadata = loadStrings(dataPath + "metadados.csv");

  numImages = metadata.length-1; // subtract the header
  filenames = new String[numImages+1]; // add an extra (empty) element so IDs match the array index;
  tags = new String[0];
  associations = new ArrayList<int[]>();  
  
  parseMetadata(metadata);
  makeUnaccentedTags();

  println();
  // print the tag list
  /*
  for (int i=0; i<tags.length; i++) {
    print(tags[i] + ": " );
    int[] list = associations.get(i);
    // print the total number of id's associated with each tag
    print(list.length);
    /*
    // print the list of id's associated with each tag
    for (int h=0; h<list.length; h++) {
      print(list[h] + ",");
    }
    *//*
    // print(byte(8));  // backspace char to remove last comma B-) // this stopped working TT
    println();
  }
  println();
  */
  
  println("window size = " + windowWidth + " x " + windowHeight);
  println("number of images = " + numImages);
  println("number of unique tags = " + unaccentedIndex);

  xm = xMargin*width;
  ym = yMargin*width;
  singleView = true;
  setupLayout();
  println("high-res image render width = " + photoWidth);
  singleView = false;
  setupLayout();
  println("low-res image render width = " + photoWidth);
  println();

  standby_font = loadFont("font.vlw");
  textFont(standby_font);
  textAlign(CENTER, CENTER);
  textSize(standby_font_size);

  //if(autostartChrome) exec("chromium-browser");
  //exec("chromium-arquivista");
  
  if(autostartChrome) {
    String[] env = {"PATH=/bin:/usr/bin/"};
    ProcessBuilder pb = new ProcessBuilder(sketchPath() + "/../start_chrome.sh");
    try {
      Process p = pb.start();
    } catch (IOException e) {
      e.printStackTrace();
    } 
  }

  delay(2000);
  searchLabel.setText(str_connecting);
  updateLCD_word(str_connecting);
  standbyTimer = 999999;
}


void draw() {

  background(0);

  webSocketKeepAlive();

  // for export
  if(export) {
    println("exporting...");    
    exportRender = createGraphics(exportWidth, exportHeight);
    exportRender.beginDraw();
    exportRender.background(0); 
    exportRender.imageMode(CENTER);

    if(loadHighRes) {
      loadImages(true);
    } else {
      loadImages(false);
    }

    drawImages(exportRender, true);

    exportRender.endDraw();
    String f = "export_"+nf(month(),2)+nf(day(),2)+nf(hour(),2)+nf(minute(),2)+nf(second(),2)+".jpg";
    exportRender.save(dataPath + f);
    println("saved " + dataPath + f);
    export = false;
  }

  imageMode(CORNER);
  if(standby) {
    fill(standby_fill);
    text(str_waiting, width/2, height/2);
    if(standby_pulse_in) {
      standby_fill += standby_pulse_speed;
    } else {
      standby_fill -= standby_pulse_speed;
    }
    if(standby_fill >= 255) {
      standby_pulse_in = false;
    }
    if(standby_fill <= 0) {
      standby_pulse_in = true;
    }
  } else {
    image(imgBuffer,0,0);
  }

  // handle fade out/in
  if (refresh || toStandby || leaveStandby) { // fade out
    noStroke();
    rectMode(CORNER);
    fill(0, fade);
    rect(0, 0, width, height);
    if (fade > 255) {
      fade = 255; 
      if(refresh) {
        updateSearch();
        refresh = false;
      }
      if(toStandby) {
        toStandby = false;
        standby = true;
        initStandby();
      }
      if(leaveStandby) {
        leaveStandby = false;
        standby = false;
      }
    }
    fade += fadeSpeed;
  } else if (fade > 0) { // fade in
    noStroke();
    rectMode(CORNER);
    fill(0, (int)fade);
    rect(0, 0, width, height);
    fade -= fadeSpeed;
  }

  // triggering/exiting standby mode
  if(!standby && !toStandby && millis() - standbyTimer > standbyTimeout) {
    toStandby = true;
  }
  if(standby && millis() - standbyTimer < standbyTimeout) {
    leaveStandby = true;
  }
  
}


// ========================================================================= //


// -------------------------------- SETUP ---------------------------------- //

void selectDataPath(File selection) {
  if (selection == null) {
    println("no path selected for database.");
    exit();
  } else {
    dataPath = selection.getAbsolutePath() + "/";
    println("loading database from " + dataPath);
    gotPath = true;
  }
}



// --------------------------- STATE MANAGEMENT ---------------------------- //


void initStandby() {
  updateLCD_word(str_waiting);
  updateLCD_msg("");
  searchLabel.setText("");
  searchTerms.clear();
  imageIDs.clear();
  imgBuffer.beginDraw();
  imgBuffer.background(0);
  imgBuffer.endDraw();
  singleView = false;
  setupLayout();
}

void pageRight() {
  if(page<numPages) {
    page++;
    refresh = true;
    standbyTimer = millis();
    updateLCD_pages();
  }
}

void pageLeft() {
  if(page>1) {
    page--;
    refresh = true;
    standbyTimer = millis();
    updateLCD_pages();
  }
}


void toggleSingleView() {
  if(imageIDs.size() > 0) {
    singleView = !singleView;
    println("singleView = " + singleView + '\n');
    setupLayout();
    refresh = true;
    newSearch = true;
    standbyTimer = millis();
  }
}



// -------------------------------- SEARCH --------------------------------- //


void search(String searchString) {
  standbyTimer = millis();

  searchString = searchString.toLowerCase();
  searchString = searchString.trim();
  if(refineSearch) {
    if(imageIDs.size() == 0 && searchTerms.size() > 0) {
      searchTerms.remove(searchTerms.size()-1);
    }
    searchTerms.append(searchString);
  } else {
    searchTerms.clear();
    searchTerms.append(searchString);    
  }
  println(searchString);
  refresh = true;
  searchLabel.setText(allSearchTerms() + str_searching);
  updateLCD_word(allSearchTerms());
  updateLCD_msg(str_searching);
  newSearch = true;

  logString(allSearchTerms());
}
 

void updateSearch() {

  if(searchTerms.size() > 0) {
    String currentSearchTerm = "";
    currentSearchTerm = searchTerms.get(searchTerms.size()-1);

    if(newSearch) {
      if(refineSearch && searchTerms.size() > 1) {
        getIDs(currentSearchTerm, false);
      } else {
        getIDs(currentSearchTerm, true); 
      } 
      newSearch = false;
    }

    loadImages(false);
    updateBuffer();
    
    if(imageIDs.size() > 0 ) {
      searchLabel.setText(allSearchTerms() + " " + page + " of " + numPages + " (" + imageIDs.size() + ")");
      updateLCD_pages();
    } else {
      searchLabel.setText(allSearchTerms() + str_no_results);
      updateLCD_msg(str_no_results);
    }
  }
}


String allSearchTerms() {
  String a = searchTerms.get(0);
  for(int i=1; i<searchTerms.size(); i++) {
    a += ", ";
    a += searchTerms.get(i);
  }
  return a;
}


void randomSearch() {
  int i = (int)random(1, tags.length);
  search(tags[i]);
}


void updateTextboxColor() {
  if(refineSearch)
    cp5.setColorBackground(color(#015848));  // green textbox
  else {
    cp5.setColorBackground(color(#01336F));  // blue textbox
  }
}


// -------------------------------- DRAWING -------------------------------- //


void setupLayout() {

  if(singleView) {
    nr = 1;
    nc = 1;
  } else {
    nr = rows;
    nc = columns;
  }
  
  images = new PImage[nr * nc];
  xs = (width - 2*xm)/nc;
  ys = (height - 2*ym)/nr;
  photoWidth = xs * (1-padding);

}


void loadImages(boolean highRes) {

  for(int i=0; i<imagesOnScreen(); i++) {
    int id = imageIDs.get(i + (page-1) * nr * nc);
    if(highRes || singleView) {
      if(highRes) {
        println("loading image " + (i+1));
      }
      images[i] = loadImage(dataPath + "images_highres/" + filenames[id] + ".jpg");
    } else {
      images[i] = loadImage(dataPath + "images_lowres/" + filenames[id] + ".jpg");
    }
  }    

}


void updateBuffer(){

  imgBuffer.beginDraw();
  imgBuffer.background(0);
  
  // draw page margins
  if(showFrames) {
    imgBuffer.stroke(0,255,0);
    imgBuffer.noFill();
    imgBuffer.rectMode(CENTER);
    imgBuffer.rect(width/2, height/2, width - 2*xm, height - 2*ym);
  }  
  
  // draw the images  
  drawImages(imgBuffer, false);
  imgBuffer.endDraw();

}


void drawImages(PGraphics g, boolean forExport) {


  g.imageMode(CENTER);

  for(int i=0; i<imagesOnScreen(); i++) {
    
    float r = (float)images[0].height/(float)images[0].width;
      
    float x = i%nc * xs + xm + xs/2;
    float y = ceil(i/nc) * ys + ym + ys/2;
    
    if(forExport) {
      float s = (float)exportWidth/(float)width;
      g.image(images[i], x*s, y*s, photoWidth*s, photoWidth*r*s);
    } else {
      if(showImages) {
        g.image(images[i], x, y, photoWidth, photoWidth*r);
      }
      if(showFrames) {
        g.stroke(0,0,255);
        g.noFill();
        g.rectMode(CENTER);
        g.rect(x, y, xs, ys);
        g.stroke(255,0,0);
        g.rect(x, y, photoWidth, photoWidth*r);
      }
    }  
  }
}


int imagesOnScreen() {
  int i;
  int a = imageIDs.size();
  int b = nr * nc;
  if(numPages<=1 || page == numPages) {
    i = a%b;
    if(i==0 && a>0) i=b;
  } else {
    i = b;
  }
  return i;
}



// -------------------------- VOICE RECOGINITION --------------------------- //


void webSocketServerEvent(String msg){
  //println(msg);
  delay(100);
  if(!ready && msg.equals("ready")) {
    ready = true;
    searchLabel.setText("ready");
    updateLCD_word("ready");
    standbyTimer = millis() - standbyTimeout + 2000;
  } else if(msg.equals("#")) {
    // ping, do nothing
  } else if (ready) {
    search(msg);
  }
  wsTimer = millis();
}

void webSocketKeepAlive() {
  if(millis() - wsTimer > pingInterval) {
    ws.sendMessage("?");
    wsTimer = millis();
  }
}


// ------------------------------- BUTTONS --------------------------------- //

void serialEvent(Serial port) {


  String s = port.readStringUntil('\n');
  
  if (s != null) {
    switch(s.charAt(0)) {
      case 'L':
        if(s.charAt(1) == 'E') { // new search
          refineSearch = true;
        }
        if(s.charAt(1) == 'D') { // refine search
          refineSearch = false;
        }
        println("refineSearch = " + refineSearch + '\n'); 
        updateTextboxColor();
        standbyTimer = millis();
        break;      
      case 'S':
        if(s.charAt(1) == 'E') { // start listening
          ws.sendMessage("start");
          updateLCD_msg(str_listening);
          cp5.setColorBackground(color(#6F0108));
        }
        if(s.charAt(1) == 'D') { // stop listening
          delay(stop_talk_delay);
          ws.sendMessage("stop");
          updateTextboxColor();
        }
        wsTimer = millis();
        standbyTimer = millis();
        break;
      case 'F':
        toggleSingleView();
        break;
      case '<':
        pageLeft();
        break;
      case '>':
        pageRight();
        break;
    }
  }
  
}


// --------------------------------- LOGS ---------------------------------- //

void logString(String s) {
  try {
    String dateStamp = nf(year(),4) + "-" + nf(month(),2) + "-" + nf(day(),2);
    log = new File(dataPath + "/logs/" + dateStamp + ".txt");
    logWriter = new FileWriter(log, true); // true = append
    logBuffer = new BufferedWriter(logWriter);
    if (!log.exists()) {
      log.createNewFile();
    }
    PrintWriter pw = new PrintWriter(logBuffer);
    String timestamp = nf(hour(),2) + ":" + nf(minute(),2) + ":" + nf(second(),2);
    pw.write(timestamp + '\t' + s + '\n');
    pw.close();
  }
  catch(IOException ioe) {
    System.out.println("Exception ");
    ioe.printStackTrace();
  }
}


// --------------------------------- LCD ----------------------------------- //


void updateLCD_pages() {
  if(useArduino) {
    arduino.write("N");
    arduino.write(nf(page));
    arduino.write(',');
    arduino.write(nf(numPages));
    arduino.write('\n');
  }
}


void updateLCD_word(String searchStrings) {
  if(useArduino) {
    arduino.write("W");
    sendString(arduino, searchStrings);
    arduino.write('\n');
  }
}

void updateLCD_msg(String msg) {
  if(useArduino) {
    arduino.write("M");
    sendString(arduino, msg);
    arduino.write('\n');
  }
}

// needed to add this switch/case to catch the accented chars, 
// due to some encoding issues with the serial comms on the raspberry pi

void sendString(Serial port, String s) { 

  for(int i=0; i< s.length(); i++) {
    char a = s.charAt(i);
    
    switch(a) {

      case 'à': 
        port.write(0xA0);
        break;
      case 'á': 
        port.write(0xA1);
        break;
      case 'â': 
        port.write(0xA2);
        break;
      case 'ã': 
        port.write(0xA3);
        break;
      case 'ç': 
        port.write(0xA7);
        break;
      case 'é': 
        port.write(0xA9);
        break;
      case 'ê': 
        port.write(0xAA);
        break;
      case 'í': 
        port.write(0xAD);
        break;
      case 'ó': 
        port.write(0xB3);
        break;
      case 'ô': 
        port.write(0xB4);
        break;
      case 'õ': 
        port.write(0xB5);
        break;
      case 'ú': 
        port.write(0xBA);
        break;
      case 'À': 
        port.write(0x80);
        break;
      case 'Á': 
        port.write(0x81);
        break;
      case 'Â': 
        port.write(0x82);
        break;
      case 'Ã': 
        port.write(0x83);
        break;
      case 'Ç': 
        port.write(0x87);
        break;
      case 'É': 
        port.write(0x89);
        break;
      case 'Ê': 
        port.write(0x8A);
        break;
      case 'Í': 
        port.write(0x8D);
        break;
      case 'Ó': 
        port.write(0x93);
        break;
      case 'Ô': 
        port.write(0x94);
        break;
      case 'Õ': 
        port.write(0x95);
        break;
      case 'Ú': 
        port.write(0x9A);
        break;

      default:
        port.write(a);
        break;
    }
  }
}
