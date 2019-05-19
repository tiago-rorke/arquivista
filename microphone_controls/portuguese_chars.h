
/*
à - 0xe0 - a_grave
á - 0xe1 - a_acute
â - 0xe2 - a_circum
ã - 0xe3 - a_tilde
ç - 0xe7 - c_cedilha
é - 0xe9 - e_acute
ê - 0xea - e_circum
í - 0xed - i_acute
ó - 0xf3 - o_acute
ô - 0xf4 - o_circum
õ - 0xf5 - o_tilde
ú - 0xfa - u_acute
À - 0xc0 - A_grave
Á - 0xc1 - A_acute
Â - 0xc2 - A_circum
Ã - 0xc3 - A_tilde
Ç - 0xc7 - C_cedilha
É - 0xc9 - E_acute
Ê - 0xca - E_circum
Í - 0xcd - I_acute
Ó - 0xd3 - O_acute
Ô - 0xd4 - O_circum
Õ - 0xd5 - O_tilde
Ú - 0xda - U_acute
*/


// ------------------------------------------------------------------------- //

const char a_grave[8] PROGMEM = { // à // 0xe0
	B01000,
	B00100,
	B00000,
	B01110,
	B00001,
	B01111,
	B10001,
	B01111
};

const char a_acute[8] PROGMEM = { // á // 0xe1
	B00010,
	B00100,
	B00000,
	B01110,
	B00001,
	B01111,
	B10001,
	B01111
};

const char a_circum[8] PROGMEM = { // â // 0xe2
	B00100,
	B01010,
	B00000,
	B01110,
	B00001,
	B01111,
	B10001,
	B01111
};

const char a_tilde[8] PROGMEM = { // ã // 0xe3
	B01101,
	B10010,
	B00000,
	B01110,
	B00001,
	B01111,
	B10001,
	B01111
};

const char c_cedilha[8] PROGMEM = { // ç // 0xe7
	B00000,
	B00000,
	B01110,
	B10000,
	B10001,
	B01110,
	B00100,
	B01100
};

const char e_acute[8] PROGMEM = { // é // 0xe9
	B00010,
	B00100,
	B00000,
	B01110,
	B10001,
	B11111,
	B10000,
	B01110
};

const char e_circum[8] PROGMEM = { // ê // 0xea
	B00100,
	B01010,
	B00000,
	B01110,
	B10001,
	B11111,
	B10000,
	B01110
};


const char i_acute[8] PROGMEM = { // í // 0xed
	B00010,
	B00100,
	B00000,
	B00100,
	B01100,
	B00100,
	B00100,
	B01110
};

const char o_acute[8] PROGMEM = { // ó // 0xf3
	B00010,
	B00100,
	B00000,
	B01110,
	B10001,
	B10001,
	B10001,
	B01110
};

const char o_circum[8] PROGMEM = { // ô // 0xf4
	B00100,
	B01010,
	B00000,
	B01110,
	B10001,
	B10001,
	B10001,
	B01110
};

const char o_tilde[8] PROGMEM = { // õ // 0xf5
	B01101,
	B10010,
	B00000,
	B01110,
	B10001,
	B10001,
	B10001,
	B01110
};

const char u_acute[8] PROGMEM = { // ú // 0xfa
	B00010,
	B00100,
	B00000,
	B10001,
	B10001,
	B10001,
	B10011,
	B01101
};

const char A_grave[8] PROGMEM = { // À // 0xc0
	B01000,
	B00100,
	B00100,
	B01010,
	B10001,
	B11111,
	B10001,
	B10001
};

const char A_acute[8] PROGMEM = { // Á // 0xc1
	B00010,
	B00100,
	B00100,
	B01010,
	B10001,
	B11111,
	B10001,
	B10001
};

const char A_circum[8] PROGMEM = { // Â // 0xc2
	B00100,
	B01010,
	B00000,
	B01110,
	B10001,
	B11111,
	B10001,
	B10001
};

const char A_tilde[8] PROGMEM = { // Ã // 0xc3
	B01101,
	B10010,
	B00000,
	B01110,
	B10001,
	B11111,
	B10001,
	B10001
};

const char C_cedilha[8] PROGMEM = { // Ç // 0xc7
	B01110,
	B10001,
	B10000,
	B10000,
	B10001,
	B01110,
	B00010,
	B00110
};

const char E_acute[8] PROGMEM = { // É // 0xc9
	B00010,
	B00100,
	B00000,
	B11111,
	B10000,
	B11110,
	B10000,
	B11111
};

const char E_circum[8] PROGMEM = { // Ê // 0xca
	B00100,
	B01010,
	B00000,
	B11111,
	B10000,
	B11110,
	B10000,
	B11111
};

const char I_acute[8] PROGMEM = { // Í // 0xcd
	B00010,
	B00100,
	B00000,
	B01110,
	B00100,
	B00100,
	B00100,
	B01110
};

const char O_acute[8] PROGMEM = { // Ó // 0xd3
	B00010,
	B00100,
	B01110,
	B10001,
	B10001,
	B10001,
	B10001,
	B01110
};

const char O_circum[8] PROGMEM = { // Ô // 0xd4
	B00100,
	B01010,
	B00000,
	B01110,
	B10001,
	B10001,
	B10001,
	B01110
};

const char O_tilde[8] PROGMEM = { // Õ // 0xd5
	B01101,
	B10010,
	B00000,
	B01110,
	B10001,
	B10001,
	B10001,
	B01110
};

const char U_acute[8] PROGMEM = { // Ú // 0xda
	B00010,
	B00100,
	B10001,
	B10001,
	B10001,
	B10001,
	B10001,
	B01110
};
