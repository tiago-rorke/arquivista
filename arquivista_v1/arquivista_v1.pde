import controlP5.*;
import websockets.*;
import processing.serial.*;

import java.util.*;
import javax.swing.JOptionPane;
import java.awt.FileDialog;

// ========= PREFERENCES ========= //

// these are default values, they will be replaced
// by what is defined in preferences.txt

// raspberry pi mode = autostart chrome, autoselect serial port.
boolean piMode = true;
boolean alwaysOnTop = false;
String arduinoPort = "/dev/ttyACM0";
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


// ========= VARS ========= //

// Visuals
PGraphics imgBuffer;
int fade = 0;
float photoWidth;
float xm, ym; // margin size in px
float xs, ys; // image size in px
int nc, nr; // number of rows and columns
boolean singleView = false; // single image view toggle

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


void settings() {
  loadPreferences();
  size(windowWidth, windowHeight);
}


void setup() {

  
  if(piMode && alwaysOnTop) surface.setAlwaysOnTop(true);

  imgBuffer = createGraphics(width, height);

  ws= new WebsocketServer(this,8080,"/arquivista");
  wsTimer = millis();
  
  if(piMode) {
    println("connecting arduino on " + arduinoPort);
    arduino = new Serial(this, arduinoPort, 9600);
    arduino.bufferUntil('\n');
  } else {
    selectFolder("where is the database?", "selectDataPath");
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
        arduino = new Serial(this, arduinoPort, 9600);
        arduino.bufferUntil('\n');
      }
      catch(Exception e) {
        println("no arduino connected");
      }
    } else {
      println("no arduino connected");
    }
  }

  cp5 = new ControlP5(this);
  font = loadFont(dataPath + "NotoSans-12.vlw");
  cp5.setFont(font);
  cp5.addTextfield("search").setPosition(20, height-40).getCaptionLabel().setVisible(false);   
  searchLabel = cp5.addTextlabel("searchLabel").setText("").setPosition(20, height-60);
  searchLabel.setText("loading...");

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
  setupLayout();

  if(piMode) exec("chromium-browser");

  delay(2000);
  searchLabel.setText("waiting...");
  updateLCD_word("waiting...");
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
  image(imgBuffer,0,0);

  // handle fade out/in
  if (refresh) {
    noStroke();
    rectMode(CORNER);
    fill(0, fade);
    rect(0, 0, width, height);
    if (fade > 255) {
      fade = 255; 
      updateConsole();
      refresh = false;
    }
    fade += fadeSpeed;
  } else if (fade > 0) {
    noStroke();
    rectMode(CORNER);
    fill(0, (int)fade);
    rect(0, 0, width, height);
    fade -= fadeSpeed;
  }
  
}


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

  println("image render width = " + photoWidth);
  println();

}


void loadImages(boolean highRes) {

  for(int i=0; i<imagesOnScreen(); i++) {
    int id = imageIDs.get(i + (page-1) * nr * nc);
    if(highRes) {
      println("loading image " + (i+1));
      images[i] = loadImage(dataPath + "image_highres/" + filenames[id] + ".jpg");
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

void webSocketServerEvent(String msg){
  //println(msg);
  delay(100);
  if(!ready && msg.equals("ready")) {
    ready = true;
    searchLabel.setText("ready");
    updateLCD_word("ready");
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

void randomSearch() {
  int i = (int)random(1, tags.length);
  search(tags[i]);
}

void search(String searchString) {
  searchString = searchString.toLowerCase();
  searchString = searchString.trim();
  if(refineSearch) {
    if(imageIDs.size() == 0) {
      searchTerms.remove(searchTerms.size()-1);
    }
    searchTerms.append(searchString);
  } else {
    searchTerms.clear();
    searchTerms.append(searchString);    
  }
  println(searchString);
  refresh = true;
  searchLabel.setText(allSearchTerms() + "(searching...)");
  newSearch = true;
}
 
String allSearchTerms() {
  String a = "";
  for(int i=0; i<searchTerms.size(); i++) {
    a += searchTerms.get(i);
    a += ", ";
  }
  return a;
}

void pageRight() {
  if(page<numPages) {
    page++;
    refresh = true;
  }
}

void pageLeft() {
  if(page>1) {
    page--;
    refresh = true;
  }
}

void setTextboxColor() {
  if(refineSearch)
    cp5.setColorBackground(color(#015848));  // green textbox
  else {
    cp5.setColorBackground(color(#01336F));  // blue textbox
  }
}

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
        setTextboxColor();
        break;      
      case 'S':
        if(s.charAt(1) == 'E') { // start listening
          ws.sendMessage("start");
          cp5.setColorBackground(color(#6F0108));
        }
        if(s.charAt(1) == 'D') { // stop listening
          ws.sendMessage("stop");
          setTextboxColor();
        }
        wsTimer = millis();
        break;
      case 'F':
        singleView = !singleView;
        setupLayout();
        refresh = true;
        newSearch = true;
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


void selectDataPath(File selection) {
  if (selection == null) {
    println("no path selected for database.");
    exit();
  } else {
    dataPath = selection.getAbsolutePath() + "/";
    println("loading database from " + dataPath);
  }
}


void updateConsole() {

  //String currentSearchTerm = "";
  String currentSearchTerm = searchTerms.get(searchTerms.size()-1);
      //currentSearchTerm = searchTerms.get(0);

  if(newSearch) {
    if(refineSearch) {
      getIDs(currentSearchTerm, false);
    } else {
      getIDs(currentSearchTerm, true); 
    } 
    newSearch = false;
  }

  loadImages(false);
  updateBuffer();
  
  if(imageIDs.size() > 0 ) {
    updateLCD_word(currentSearchTerm);
    searchLabel.setText(allSearchTerms() + page + " of " + numPages + " (" + imageIDs.size() + ")");
    updateLCD_pages();
  } else {
    searchLabel.setText(allSearchTerms() + "(no results)");
    updateLCD_word("(no results)");
  }

}



void updateLCD_pages() {
  arduino.write("N");
  arduino.write(nf(page));
  arduino.write(',');
  arduino.write(nf(numPages));
  arduino.write('\n');
}


void updateLCD_word(String searchString) {
  arduino.write("W");
  arduino.write(searchString);  
  arduino.write('\n');
}