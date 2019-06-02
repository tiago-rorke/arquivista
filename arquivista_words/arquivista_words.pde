
boolean shuffle = false;
boolean drawGuides = false;
boolean export = false;
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

int fadeinInterval = 200; // interval in milliseconds between triggering word changes
int fadeinSpeed = 50;
int fadeoutInterval = 10;
int fadeoutSpeed = 150;
long fadeout_delay = 1000; // also the exit delay

// state flags
boolean done = false;     // all words are visible
boolean fade_out = false; // fadeout_delay has passed

int interval = fadeinInterval; 
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
    if(!fade_out) {          // if not fading out
      if(visible[i]) {         // if flagged to appear
        opa[i] += fadeinSpeed;   // increase the opacity
        if(opa[i] > 255) {     // limit the opacity to 255
          opa[i] = 255;
        }
      }
    } else {                 // if fading out
      if(!visible[i]) {
        opa[i] -= fadeoutSpeed;
        if(opa[i] < 0) {
          opa[i] = 0;
        }
      }
    }
    fill(color(255, opa[i]));            // generate the color based on the opacity list 
    text(words[i], pos[i].x, pos[i].y);  // draw the word
  }

  // once the interval time has passed
  if(!done && millis() - timer > interval) {

    if(!fade_out) { // if not fading out
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
        
    } else { // if fading out
      int i = 0;
      while(!visible[i]) {
        i = (int)random(0, num_words);
      }
      visible[i] = false;
      timer = millis();

      // check if all the words have disappeared yet
      done = true;
      for(int h=0; h<num_words; h++) {
        if(visible[h]) {
          done = false;
          break;
        }
      }

    }

  // if all the words are visible and the fadeout_delay has passed
  } else if(done && millis() - timer > fadeout_delay && !fade_out) {
    fade_out = true;
    interval = fadeoutInterval;
    done = false;

  // if fading out and all the words are hidden and the fadeout_delay has passed
  } else if(fade_out && done && millis() - timer > fadeout_delay) {
    exit();
  } 

  if(export) {
    saveFrame(export_folder + "/#####.tga");
  }

}



void initialise() {

  if(shuffle) {
    shuffle_list();
  }

  // coordinates for first word
  float y = margin_yt;
  float x = margin_xl;

  // calc width of text area
  float w = width - (margin_xr + margin_xl);

  int i = 0;  // index of current word
  int i2 = 0; // index of first word of current row

  while(y < height - margin_yb) {
    // set parameters for current word
    words[i] = word_list[i];
    opa[i] = 0;
    visible[i] = false;
    pos[i] = new PVector(x,y);
    
    float a = textWidth(words[i]);  // get width of current word
    x += word_spacing + a;          // increment x position accordingly for next word
    i++;                            // increment word index
    num_words = i;

    // stop if we reach the end of the word list
    if(i >= word_list.length) {
      break;
    }

    // get width of next word
    float b = textWidth(word_list[i]);

    // check if we have reached the end of the line or not
    if(x + word_spacing + b > w + margin_xl) {

      float r = w + margin_xl - (x - word_spacing);  // if we have, get the size of the remaining space on the line
      r /= i - (i2+1);                               // divide by one less than the number of words on the line
      
      int j=1;                           // make index to count words on the line
      for(int h = i2+1; h < i; h++) {    // and for each of those words
        pos[h].x += j*r;                 // add this remainder*index on line to each x pos
        j++;
      }
      i2 = i;
 
      // the reset the x pos and increment the y pos
      x = margin_xl;
      y += row_height;
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