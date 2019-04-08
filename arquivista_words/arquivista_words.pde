

boolean drawGuides = false;
boolean export = true;
String export_folder;

// window size and layout
int window_width = 1280;
int window_height = 720;
int margin_xl = 100;
int margin_xr = 100;
int margin_yt = 20;
int margin_yb = 20;
float font_size = 20;
int rows = 20;
float word_spacing = 10;
float row_height;

String[] word_list; // list of all imported words
String[] words;     // list of words to draw
int[] opa;          // word opacity
PVector[] pos;      // word position
boolean[] visible;  // flags to show words
int num_words;      // number of words on the screen

int interval = 50; // interval in milliseconds between triggering word changes
int fadeSpeed = 10;
int fadeout_delay = 1000;

// state flags
boolean done;     // all words are visible
int fade_out = 0; // fade out mask

int index;
long timer;
PFont font;


void settings() {
  size(window_width, window_height);
}


void setup() {

  font = loadFont("font.vlw");
  textFont(font);
  textAlign(LEFT, TOP);
  textSize(font_size);

  row_height = (height - (margin_yt + margin_yb))/rows;

  word_list = loadStrings("list.txt");
  num_words = word_list.length;

  words = new String[num_words]; 
  opa = new int[num_words]; 
  pos = new PVector[num_words]; 
  visible = new boolean[num_words];

  initialise();

  export_folder = nf(month(),2) + nf(day(),2) + "-" + nf(hour(),2) + nf(minute(),2) + nf(second(),2);

}


void draw() {

  background(0);

  if(drawGuides) {
    noFill();
    stroke(255,0,0);
    rect(margin_xl, margin_yt, width-(margin_xl + margin_xr), height-(margin_yt + margin_yb));
    for(int i=1; i<rows; i++) {
      float y = margin_yt + i*row_height;
      line(margin_xl, y, width-margin_xr, y);
    }
  }

  // go through the words[] list
  for(int i=0; i<num_words; i++) {
    if(visible[i]) {         // if flagged to appear
      opa[i] += fadeSpeed;   // increase the opacity
      if(opa[i] > 255) {     // limit the opacity to 255
        opa[i] = 255;
      }
    }
    fill(color(255, opa[i]));            // generate the color based on the opacity list 
    text(words[i], pos[i].x, pos[i].y);  // draw the word
  }

  // once the interval time has passed
  if(!done && millis() - timer > interval) {
    int i = 0;
    // keep choosing a random word from the screen
    // until we choose one that is still hidden
    while(visible[i]) {
      i = (int)random(0, num_words);
    }
    visible[i] = true;
    timer = millis();

    // check if all the words have appeared yet
    done = true;
    for(int h=0; h<num_words; h++) {
      if(!visible[h]) {
        done = false;
        break;
      }
    }

  // if all the words are visible and the fadeout_delay has passed
  } else if(done && millis() - timer > fadeout_delay && fade_out == 0) {
    fade_out = 1;
  }

  if(fade_out > 0) {
    fill(0, fade_out);
    rect(0, 0, width, height);
    fade_out += fadeSpeed;
    if(fade_out > 255) {
      //stop();
      exit();
    }
  }

  if(export) {
    saveFrame(export_folder + "/#####.tga");
  }

}



void initialise() {

  shuffle_list();

  float y = margin_yt;
  float x = margin_xl;
  int i = 0;

  while(y < height - margin_yb) {
    words[i] = word_list[i];
    opa[i] = 0;
    visible[i] = false;
    pos[i] = new PVector(x,y);
    
    float a = textWidth(words[i]);

    x += word_spacing + a;
    num_words = i;
    i++;

    if(x + word_spacing + a > width - margin_xr) {
      x = margin_xl;
      y += row_height;
    }

    if(i >= word_list.length) {
      break;
    }
  }

  index = 0;
  timer = millis();
}


void shuffle_list() {

  String[] shuffled = new String[0];

  for(int i=0; i<word_list.length; i++) {
    shuffled = splice(shuffled, word_list[i], (int)random(0,shuffled.length));
  }

  word_list = shuffled;
}


void keyPressed() {
  initialise();
}