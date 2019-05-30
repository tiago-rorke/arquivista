#include <DebounceInput.h>
#include <LiquidCrystal_I2C.h>
#include "portuguese_chars.h"

#define COLS  20  // LCD columns
#define ROWS  4   // LCD rows
LiquidCrystal_I2C lcd(0x27, COLS, ROWS);

#if defined(ARDUINO) && ARDUINO >= 100
#define printByte(args)  write(args);
#else
#define printByte(args)  print(args,BYTE);
#endif


#define LOCK  12  // yellow
#define PTT   11  // green
#define RIGHT 10  // blue    // up
#define FAST  9   // purple  // not in use but connected
#define LEFT  8   // grey    // down

DebouncedInput lock;
DebouncedInput ptt;
DebouncedInput left;
DebouncedInput right;
DebouncedInput fast;


// placeholders for LCD funcionality
String inString;
boolean stringComplete;
int n = 0; // current page
int p = 0; // total number of pages


void setup() {
  Serial.begin(115200);
  lcd.init();
  lcd.backlight();
  lcd.setCursor(0,0);
  lcd.print("loading...");

  pinMode(LOCK, INPUT_PULLUP);
  pinMode(PTT, INPUT_PULLUP);
  pinMode(RIGHT, INPUT_PULLUP);
  pinMode(LEFT, INPUT_PULLUP);
  pinMode(FAST, INPUT_PULLUP);

  lock.attach(LOCK);
  ptt.attach(PTT);
  left.attach(LEFT);
  right.attach(RIGHT);
  fast.attach(FAST);

}


void loop() {

  lock.read();
  ptt.read();
  left.read();
  right.read();
  fast.read();

  if(lock.falling()) {
    Serial.println("LE"); // "lock" enable refine search
  }
  if(lock.rising()) {
    Serial.println("LD"); // "unlock" disable refine search
  }
  if(ptt.falling()) {
    Serial.println("SE"); // start listening
  }
  if(ptt.rising()) {
    Serial.println("SD"); // stop listening
  }
  if(left.falling()) {
    Serial.println('<'); // page left
  }
  if(right.falling()) {
    Serial.println('>'); // page right
  }
  if(fast.falling()) {
    Serial.println('F'); // "fast" toggle single view
  }
  
  while (Serial.available() > 0) {
    char inChar = Serial.read();
    inString += inChar;
    if (inChar == '\n') { // read string until newline character
      stringComplete = true;
      break;
    }
  }
  
  if (stringComplete) {
    switch(inString.charAt(0)) {

      case 'M': {
          // UI message
          inString = inString.substring(1);
          inString.trim();
          for(int h=0; h<COLS; h++) {
            lcd.setCursor(h, ROWS-1);
            lcd.print(' ');
          }
          int x = 0;
          int i = 0;
          for(int h = 0; h < inString.length(); h++) {
            lcd.setCursor(x, ROWS-1);
            x += print_char(inString.charAt(h), &i);
            if(x >= COLS) {
              break;
            }
          }
        } break;

      case 'W': {
          // search terms
          inString = inString.substring(1);
          inString.trim();
          int max = COLS*(ROWS-1);
          if(inString.length() > max) {
            inString = inString.substring(inString.length() - max);
          }
          for(int j=0; j<ROWS-1; j++) { // clear the lines
            for(int h=0; h<COLS; h++) {
              lcd.setCursor(h,j);
              lcd.print(' ');
            }
          }
          int x = 0;
          int y = 0;
          int i = 0;
          for(int h = 0; h < inString.length(); h++) {
            lcd.setCursor(x, y);
            x += print_char(inString.charAt(h), &i);
            if(x >= COLS) {
              x = 0;
              y++;
            }
            if(y >= ROWS-1) {
              break;
            }
          }
        } break;

      case 'N':  { // pages
          int i = inString.indexOf(',');
          String ns = inString.substring(1, i);
          String ps = inString.substring(i+1);
          n = ns.toInt();
          p = ps.toInt();
          for(int h=0; h<COLS; h++) {// clear the line
            lcd.setCursor(h,ROWS-1);
            lcd.print(' ');
          }
          lcd.setCursor(0,ROWS-1);
          lcd.print(n);
          lcd.print(" / ");
          lcd.print(p);
        } break;
    }
    inString = "";
    stringComplete = false;    
  } 
  
}


int print_char(char in_char, int* i) {

  //Serial.println(in_char, HEX);  // debugging char hex codes

  switch(byte(in_char)) {

    case 0xC3:
      return 0;
    
    case 0xA0: // à - a_grave
      lcd.printByte(*i);
      lcd.createChar(*i, a_grave);
      break;

    case 0xA1: // á - a_acute
      lcd.printByte(*i);
      lcd.createChar(*i, a_acute);
      break;

    case 0xA2: // â - a_circum
      lcd.printByte(*i);
      lcd.createChar(*i, a_circum);
      break;

    case 0xA3: // ã - a_tilde
      lcd.printByte(*i);
      lcd.createChar(*i, a_tilde);
      break;

    case 0xA7: // ç - c_cedilha
      lcd.printByte(*i);
      lcd.createChar(*i, c_cedilha);
      break;

    case 0xA9: // é - e_acute
      lcd.printByte(*i);
      lcd.createChar(*i, e_acute);
      break;

    case 0xAA: // ê - e_circum
      lcd.printByte(*i);
      lcd.createChar(*i, e_circum);
      break;

    case 0xAD: // í - i_acute
      lcd.printByte(*i);
      lcd.createChar(*i, i_acute);
      break;

    case 0xB3: // ó - o_acute
      lcd.printByte(*i);
      lcd.createChar(*i, o_acute);
      break;

    case 0xB4: // ô - o_circum
      lcd.printByte(*i);
      lcd.createChar(*i, o_circum);
      break;

    case 0xB5: // õ - o_tilde
      lcd.printByte(*i);
      lcd.createChar(*i, o_tilde);
      break;

    case 0xBA: // ú - u_acute
      lcd.printByte(*i);
      lcd.createChar(*i, u_acute);
      break;

    case 0x80: // À - A_grave
      lcd.printByte(*i);
      lcd.createChar(*i, A_grave);
      break;

    case 0x81: // Á - A_acute
      lcd.printByte(*i);
      lcd.createChar(*i, A_acute);
      break;

    case 0x82: // Â - A_circum
      lcd.printByte(*i);
      lcd.createChar(*i, A_circum);
      break;

    case 0x83: // Ã - A_tilde
      lcd.printByte(*i);
      lcd.createChar(*i, A_tilde);
      break;

    case 0x87: // Ç - C_cedilha
      lcd.printByte(*i);
      lcd.createChar(*i, C_cedilha);
      break;

    case 0x89: // É - E_acute
      lcd.printByte(*i);
      lcd.createChar(*i, E_acute);
      break;

    case 0x8A: // Ê - E_circum
      lcd.printByte(*i);
      lcd.createChar(*i, E_circum);
      break;

    case 0x8D: // Í - I_acute
      lcd.printByte(*i);
      lcd.createChar(*i, I_acute);
      break;

    case 0x93: // Ó - O_acute
      lcd.printByte(*i);
      lcd.createChar(*i, O_acute);
      break;

    case 0x94: // Ô - O_circum
      lcd.printByte(*i);
      lcd.createChar(*i, O_circum);
      break;

    case 0x95: // Õ - O_tilde
      lcd.printByte(*i);
      lcd.createChar(*i, O_tilde);
      break;

    case 0x9A: // Ú - U_acute
      lcd.printByte(*i);
      lcd.createChar(*i, U_acute);
      break;
    
    default:
      //Serial.println(in_char);
      lcd.print(in_char);
      break;

  }

  switch(byte(in_char)) {
    case 0xA0:
    case 0xA1:
    case 0xA2:
    case 0xA3:
    case 0xA7:
    case 0xA9:
    case 0xAA:
    case 0xAD:
    case 0xB3:
    case 0xB4:
    case 0xB5:
    case 0xBA:
    case 0x80:
    case 0x81:
    case 0x82:
    case 0x83:
    case 0x87:
    case 0x89:
    case 0x8A:
    case 0x8D:
    case 0x93:
    case 0x94:
    case 0x95:
    case 0x9A:
      *i += 1; // for some reason, ++ doesn't work here ?!
      if(*i>7) *i=7;
      break;
  }

  return 1;
}
