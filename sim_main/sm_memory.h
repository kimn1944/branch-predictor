#ifndef SM_MEMORY_H
#define SM_MEMORY_H

#include <map>
#include <string>
#include <cstdio> 
#include <iostream>
#include <sstream>
#include <set>
#include <bitset>
#include <stdint.h>


enum {WORD,BYTE,HALFWORD};

// logging option
extern bool MONITOR_MEMORY;

// main memory map
// each index stores 4 bits (single digit of hex)
extern std::map<int,uint8_t>   MAIN_MEMORY;

// bit representation translation functions
char *itob(int x);
std::string mem2Str(int start, int length);
std::string num2Str(uint32_t b);
std::string num2Str(uint16_t b);
std::string num2Str(uint8_t b);
std::string num2Str3(uint32_t b);

// memory access functions
uint32_t readWord(int location);
uint16_t readHalfWord(int location);
uint8_t readByte(int location);
void writeByte(int location, uint8_t val);
void writeHalfWord(int location, uint16_t val);
void writeWord(int location, uint32_t val);
void memLog(std::string s);

// old memory manipulation functions ------

//CONVERTS SINGLE HEX CHARACTER to 4-bit integer
inline int hexCharValue(const char ch){
  if (ch>='0' && ch<='9')return ch-'0';
  if (ch>='a' && ch<='f')return ch-'a'+10;
  return 0;
}


// memory manipulation functions
void loadSingleHEX(std::string newValue, int location, int comment, int bh_word);
void loadSingleHEX(int newValue, int location, int comment, int bh_word);

#endif
