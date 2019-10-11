#include "sm_memory.h"
#include <limits.h>
#include <string>
#include <unistd.h>
#include <cstdio> 
#include <iostream>
#include <sstream>
#include <set>
#include <bitset>
#include <iomanip>
#include <fstream>

using namespace std;

bool MONITOR_MEMORY = 1;

extern int CLOCK_COUNTER;	//from sim_main.cpp

std::map<int,uint8_t>  MAIN_MEMORY;
// output file
ofstream memwrite("./memwrite.txt");

string num2Str(uint32_t b){
	stringstream s;	
	s << std::right << std::setfill('0') << std::setw(8)<<hex << b;	
	return s.str();
}
string num2Str(uint16_t b){
	stringstream s;	
	s << std::right << std::setfill('0') << std::setw(4)<<hex << b;	
	return s.str();
}
string num2Str(uint8_t b){
	stringstream s;	
	s << std::right << std::setfill('0') << std::setw(2)<<hex << ((uint16_t)b);	
	return s.str();
}
string num2Str3(uint32_t b){
	stringstream s;
	s << std::right << std::setfill('0') << std::setw(6)<<hex << b;
	return s.str();
}

string mem2Str(int start, int length){
	stringstream s;	

	for(int i = start; i<start+length; i+=4){
		s << "0x"<< num2Str(readWord(i));	
		s <<' ';
		if((i-start)%8!=0){
			s << endl;
		}
	}
	return s.str();
}


//CONVERTS INTEGER TO BINARY CHARACTERS
char *itob(int x){
  static char buff[sizeof(int) * CHAR_BIT + 1];
  int i;
  int j = sizeof(int) * CHAR_BIT - 1;
  buff[j] = 0;
  for(i=0;i<sizeof(int) * CHAR_BIT; i++)
    {
      if(x & (1 << i)) buff[j] = '1';
      else buff[j] = '0';
      j--;
    }
  return buff;
}

uint32_t readWord(int location){
	uint32_t val = 0;
	val+=MAIN_MEMORY[location+0];
	val = val<<8;
	val+=MAIN_MEMORY[location+1];
	val = val<<8;
	val+=MAIN_MEMORY[location+2];
	val = val<<8;
	val+=MAIN_MEMORY[location+3];
	if(MONITOR_MEMORY){memwrite << "ReadW:\t" << num2Str(val)<<" at "<<num2Str((uint32_t)location)<<endl; }
	return val;
}

uint16_t readHalfWord(int location){
	uint16_t val = 0;
	val+=MAIN_MEMORY[location+0];
	val = val<<8;
	val+=MAIN_MEMORY[location+1];
	if(MONITOR_MEMORY){memwrite << "ReadH:\t" << num2Str(val)<<" at "<<num2Str((uint32_t)location)<<endl; }
	return val;
}

uint8_t readByte(int location){
	uint8_t val = 0;
	val+=MAIN_MEMORY[location+0];
	if(MONITOR_MEMORY){memwrite << "ReadB:\t" << num2Str(val)<<" at "<<num2Str((uint32_t)location)<<endl; }
	return val;
}

void writeByte(int location, uint8_t val){	
	MAIN_MEMORY[location]=val;
	if(MONITOR_MEMORY){memwrite << "WriteB:\t" << num2Str(val)<<" at "<<num2Str((uint32_t)location)<<endl; }
}

void writeHalfWord(int location, uint16_t val){	
	MAIN_MEMORY[location]=val>>8; // msb
	MAIN_MEMORY[location+1]=val & 0xff; // lsb
	if(MONITOR_MEMORY){memwrite << "WriteH:\t" << num2Str(val)<<" at "<<num2Str((uint32_t)location)<<endl; }
}

void writeWord(int location, uint32_t val){	
	MAIN_MEMORY[location]=val>>24; // msb
	MAIN_MEMORY[location+1]=val>>16 & 0xff; 
	MAIN_MEMORY[location+2]=val>>8 & 0xffff; 
	MAIN_MEMORY[location+3]=val & 0xffffff; // lsb
	if(MONITOR_MEMORY){memwrite << "WriteW:\t" << num2Str(val)<<" at "<<num2Str((uint32_t)location)<<endl; }
	//The clock counter has been removed because its output is unreliable.
	//"@"<<((uint32_t)CLOCK_COUNTER)<<endl; }
}

void memLog(std::string s){
	if(MONITOR_MEMORY){memwrite << s <<endl; }
}

//STORES VALUE IN MEMORY (STRING ARGUMENT)
void loadSingleHEX(std::string newValue, int location, int comment, int bh_word){
	switch (bh_word) {
		case 0:{												//store word	
			/*HEX_MAIN_MEMORY[location+0] = newValue.substr(0,2);							//msb
			HEX_MAIN_MEMORY[location+1] = newValue.substr(2,2);
			HEX_MAIN_MEMORY[location+2] = newValue.substr(4,2);
			HEX_MAIN_MEMORY[location+3] = newValue.substr(6,2);							//lsb*/
			MAIN_MEMORY[location+0] = ((hexCharValue(newValue[1])) + (hexCharValue(newValue[0])<<4));		//msb
			MAIN_MEMORY[location+1] = ((hexCharValue(newValue[3])) + (hexCharValue(newValue[2])<<4));
			MAIN_MEMORY[location+2] = ((hexCharValue(newValue[5])) + (hexCharValue(newValue[4])<<4));
			MAIN_MEMORY[location+3] = ((hexCharValue(newValue[7])) + (hexCharValue(newValue[6])<<4));		//lsb
			//if(MONITOR_MEMORY){memwrite << "WriteWhx:\t" <<newValue<<" at "<<num2Str((uint32_t)location)<<endl; }
			break;}
		case 1:{												//store byte
			//HEX_MAIN_MEMORY[location] = newValue.substr(0,2);
			MAIN_MEMORY[location] = ((hexCharValue(newValue[1])) + (hexCharValue(newValue[0])<<4));
			//if(MONITOR_MEMORY){memwrite << "WriteBhx:\t" <<newValue<<" at "<<num2Str((uint32_t)location)<<endl; }
			break;}
		case 2:{												//store halfword
			/*HEX_MAIN_MEMORY[location]   = newValue.substr(0,2);							//msB
			HEX_MAIN_MEMORY[location+1] = newValue.substr(2,2);							//lsB*/
			MAIN_MEMORY[location]   = (hexCharValue(newValue[0]) + hexCharValue(newValue[1])<<4);			//msB
			MAIN_MEMORY[location+1] = (hexCharValue(newValue[3]) + hexCharValue(newValue[2])<<4);			//lsB
			//if(MONITOR_MEMORY){memwrite << "WriteHhx:\t" <<newValue<<" at "<<num2Str((uint32_t)location)<<endl; }
			break;}
		default:{break;}
	}
} 
//STORES VALUE IN MEMORY (INTEGER ARGUMENT)
void loadSingleHEX(int newValue, int location, int comment, int bh_word){
	string newBinValue = itob(newValue);										//convert integer value to its (string) binary equivalent
	stringstream s;													//for binary conversion
	switch (bh_word) {
		case 0:	{												//store word	
			stringstream temp;
			string binary_str(newBinValue.substr(0,32));								//convert binary string to bitset
			bitset<32> set(binary_str);										
			temp << hex << set.to_ulong();
			while((temp.str()).size() < 8) {									//every byte, dump contents into stream
				s << "0";
				temp << "0";
			}
			s << hex << set.to_ulong();										//convert set 
			/*HEX_MAIN_MEMORY[ location + 3 ] = s.str().substr(6,2);							//lsb
			HEX_MAIN_MEMORY[ location + 2 ] = s.str().substr(4,2);
			HEX_MAIN_MEMORY[ location + 1 ] = s.str().substr(2,2);
			HEX_MAIN_MEMORY[ location + 0 ] = s.str().substr(0,2);	*/						//msb
			MAIN_MEMORY[    location + 3 ] = (hexCharValue((s.str().substr(6,2))[0])<<4) + (hexCharValue((s.str().substr(6,2))[1]));//lsb
			MAIN_MEMORY[    location + 2 ] = (hexCharValue((s.str().substr(4,2))[0])<<4) + (hexCharValue((s.str().substr(4,2))[1]));
			MAIN_MEMORY[    location + 1 ] = (hexCharValue((s.str().substr(2,2))[0])<<4) + (hexCharValue((s.str().substr(2,2))[1]));
			MAIN_MEMORY[    location + 0 ] = (hexCharValue((s.str().substr(0,2))[0])<<4) + (hexCharValue((s.str().substr(0,2))[1]));//msb
			//if(MONITOR_MEMORY){memwrite << "WriteWhx:\t" <<num2Str((uint32_t)newValue)<<" at "<<num2Str((uint32_t)location)<<endl; }
			break;}
		case 1: {												//store byte
			stringstream temp;
			string binary_str(newBinValue.substr(24,8));
			bitset<8> set(binary_str);
			temp << hex << set.to_ulong();
			while((temp.str()).size() < 2) {
				s << "0";
				temp << "0";
			}
			s << hex << set.to_ulong();
			//HEX_MAIN_MEMORY[location] = s.str();
			MAIN_MEMORY[location] = (hexCharValue((s.str())[0])<<4) + (hexCharValue((s.str())[1]));
			//if(MONITOR_MEMORY){memwrite << "WriteBhx:\t" <<num2Str((uint8_t)newValue)<<" at "<<num2Str((uint32_t)location)<<endl; }
			break;
		}
		case 2: {												//store halfword
			stringstream temp;
			string binary_str(newBinValue.substr(16,16));
			bitset<16> set(binary_str);
			temp << hex << set.to_ulong();
			while((temp.str()).size() < 4) {
				s << "0";
				temp << "0";
			}
			s << hex << set.to_ulong();
			//HEX_MAIN_MEMORY[location+1] = s.str().substr(0,2);							//msB
			//HEX_MAIN_MEMORY[location] = s.str().substr(2,2);								//lsB
			MAIN_MEMORY[location+1] = (hexCharValue((s.str())[0])<<4) + (hexCharValue((s.str())[1]));		//msb
			MAIN_MEMORY[location] = (hexCharValue((s.str())[2])<<4) + (hexCharValue((s.str())[3]));			//lsb
			//if(MONITOR_MEMORY){memwrite << "WriteHhx:\t" <<num2Str((uint16_t)newValue)<<" at "<<num2Str((uint32_t)location)<<endl; }
			break;
		}
		default:{break;}
	}
	s.str("");
}
