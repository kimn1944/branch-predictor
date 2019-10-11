#include <string>
#include <string.h>
#include "sm_txtload.h"
#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdio>
#include <unistd.h>
#include "sm_memory.h"
#include "sm_heap.h"
#include "sm_syscalls.h"
#include "sm_execinfo.h"

using namespace std;

struct execinfo exec; // this should be moved to sm_execinfo.cpp

static map<int,string> offset;

//DETERMINES ELF FILE SEGMENT OFFSETS BY READING ELF HEADER FILE
void getSegmentOffsets(std::string str, std::string str2){
  ifstream readFile1( str.c_str() );
  std::string word;
  int flag = 0;
  std::vector<std::string> words;
  if ( !readFile1 ) cerr << "File couldn't be opened" << endl;
  if (readFile1.is_open()) 
  {
	  while (!readFile1.eof() ) 
	  {
		  getline (readFile1,word);
		  if( word.find("[19]")!=std::string::npos){offset[19] = word.substr(52,4);}
		  else if( word.find("[20]")!=std::string::npos){offset[20] = word.substr(52,4);}
		  else if( word.find("[21]")!=std::string::npos){offset[21] = word.substr(52,4);}
		  else if( word.find("[22]")!=std::string::npos){offset[22] = word.substr(52,4);}
		  else if( word.find("[23]")!=std::string::npos){offset[23] = word.substr(52,4);}
		  else if( word.find("[24]")!=std::string::npos){offset[24] = word.substr(52,4);}
		  else if( word.find("[25]")!=std::string::npos){offset[25] = word.substr(52,4);}
		  else if( word.find("[26]")!=std::string::npos){offset[26] = word.substr(52,4);}
		  else if( word.find("[27]")!=std::string::npos){offset[27] = word.substr(52,4);}
		  else if( word.find("[29]")!=std::string::npos){offset[29] = word.substr(52,4);}
		  else if( word.find("[30]")!=std::string::npos){offset[30] = word.substr(52,4);}
		  else if( word.find("[31]")!=std::string::npos){offset[31] = word.substr(52,4);}
		  else if( word.find("[32]")!=std::string::npos){offset[32] = word.substr(52,4);}
		  else if( word.find("[33]")!=std::string::npos){offset[33] = word.substr(52,4);}
	  }
  }	
  readFile1.close();
  int counter=0;
  for(int i=0; i<=33; i++)
    {
      std::stringstream s;
      s<<i;
      std::string a = str2.substr(0,6)+ "_" + s.str() + ".txt";
      std::string newline = "\n";
      std::ifstream readFile2(a.c_str() );
      if (readFile2.is_open()) 
	{
	  while (!readFile2.eof() ) 
	    {
	      getline (readFile2,word);
	      if ( word.find("has no data to dump.")!=string::npos ) remove(a.c_str());
	      else if(word.find("Hex dump of section")==string::npos)
		{
		  if (counter == 1)
		    {
		      if( i>=19 && i!=28 && i!=29 )
			{
			  word.erase(0,12);
			  word.insert(0,"  0x0000"+offset[i]);
			}
		    }
		  words.push_back(word);
		  counter++;
		}
	    }
	  counter=0;
	  readFile2.close();
	  remove(a.c_str());
	  ofstream writeFile1(a.c_str());
	  for(int j=0; j<words.size(); j++)
	    {
	      writeFile1.write(words[j].c_str(),words[j].size());
	      writeFile1.write(newline.c_str(),newline.size());
	    }
	  writeFile1.close();
	  words.clear();
	}
    }
}

void getArguments(string str, int GSP){
	std::vector<int> ARGUMENT_VECTOR;

	//for noio
	ARGUMENT_VECTOR.push_back(1);//+0
	ARGUMENT_VECTOR.push_back(0);//+4
	ARGUMENT_VECTOR.push_back(0xf7021fd4);
	ARGUMENT_VECTOR.push_back(0);//+12
	ARGUMENT_VECTOR.push_back(0);//+16
	ARGUMENT_VECTOR.push_back(0x6e6f696f);/**/

	//for hello world
	/*ARGUMENT_VECTOR.push_back(1);//+0
	ARGUMENT_VECTOR.push_back(0);//+4
	ARGUMENT_VECTOR.push_back(0xf603DFD4);//+8
	ARGUMENT_VECTOR.push_back(0);//+12
	ARGUMENT_VECTOR.push_back(0);//+16
	ARGUMENT_VECTOR.push_back(0x66616374);//+20
	ARGUMENT_VECTOR.push_back(0x31320000);//+24/**/

	std::string temp = str.substr(0,str.find(".txt"));
	std::vector<std::string> local_argument_vector;
	int flag=0;
	for(int i=0; i<local_argument_vector.size(); i++) {
		//convert first 4 characters = 4 bytes or one word
		int tempInt=0;
		//convert word to integer
		for(int j=0; j<local_argument_vector[i].size(); j++) {
			string c = local_argument_vector[i].substr(j,1);
			char *cs = new char[c.size() + 1];
			strcpy ( cs, c.c_str() );
			char a = *cs; 
			int as = a;
			tempInt = (tempInt + (as<<(24-j*8)));
		}
		ARGUMENT_VECTOR.push_back(tempInt);
	}
	for(int i=0; i<=ARGUMENT_VECTOR.size()-1; i++) {
		loadSingleHEX(ARGUMENT_VECTOR[i],GSP+(i*4),0,0);
	}
}


//ELF LOADER
void LoadMemory(string str){
	std::vector<int> V;										//temperary vector
	std::vector<std::string> tempV;									//temperary vector
	std::vector<std::string> tempVect;
	std::vector<std::string> words;
	string word;
	int offset=0;
	std::ifstream getFile( str.c_str(),ios::in ); 			//open the file and cut out anything unwanted if neccessary
		if (getFile.is_open()) 
		{
			while (!getFile.eof() ) 
			{
				getline (getFile,word);
				if(word.find("Hex")==string::npos) tempVect.push_back(word.substr(0,48));
			}
		}
		getFile.close();
		std::ofstream putFile( str.c_str(),ios::trunc );						//reopen the file to be written to (truncating old contents)
		for(int f=0; f<tempVect.size(); f++) putFile << tempVect[f] << endl;
		putFile.close();
	
	//open the file to be read into memory
	ifstream inClientFile( str.c_str(),ios::in );
		if ( !inClientFile ) cerr << "File couldn't be opened" << endl;			//test if instruction file can be opened
		while (inClientFile >> word){words.push_back(word);}				//capture raw code from file
		const int wordCount=words.size();						//determine most efficient sizing for vectors
		tempV.reserve(wordCount);							//size vector
		for(int i=0; i<wordCount; i++) {	
			if (i==0 && words[i].length()==10){ tempV.push_back(words[i]);}		//include first word to obtain data offset (memory insertion point)
			if (words[i].length()==8 && words[i].find(".")==string::npos && words[i].find(".")==string::npos ){ tempV.push_back(words[i]);}//cut out undesired strings from vector
		}
		for( int y=2; y<10; y++) offset+=hexCharValue(tempV[0][y])<<(4*(9-y));		//convert offset from hex to decimal
		tempV.erase(tempV.begin());							//delete offset from vector
		V.resize(tempV.size());								//resize vector
		for( int j=0; j<tempV.size(); j++ ) {						//convert string hex to numerical decimal
			for( int y=0; y<8; y++) V[j]+=hexCharValue(tempV[j][y])<<(4*(7-y)); 	//convert hex into int
				loadSingleHEX(tempV[j],4*j+offset,0,0); 		//insert element into memory
		}
		//PC_START = offset-4; // PC_START is never used
}

void LoadOSMemoryTXT(string FILE_ARG){

	// load exec info
	exec.GSP = 0xf7021fc0;//for noio
	if (FILE_ARG.find("fact12")!=string::npos){
	//if (FILE_ARG.find("noio")==string::npos){
		exec.GSP = 0xf603dcf8+712;//forfact12
	}
	if (FILE_ARG.find("file")!=string::npos){
		// delete out.txt
		unlink("./out.txt");
	}

	exec.GRA = 0x1006a244;//for noio

	exec.GPC_START = 0x100000b0;//268435636-8; // this is the wrong value. should be 100000b0
	exec.HEAPSTART = 0xee036000; //3993198592;
	exec.BREAKSTART =0x20000000;
	exec.GPC_START = 0x100000b0;//268435636; // This seems like a wrong value, but on startup, IF adds 4, so it works out == 100000b0

	exec.GP = 0xFFFFFFFF;	//We don't set it for txtload

	// now we load the OS memory.  I hope these files are correct and lay out memory correctly.
	// otherwise this is impossible.
	getArguments("app_obj/"+FILE_ARG+".txt",exec.GSP);								//captures arguments for initializing stack
	getSegmentOffsets("app_obj/readelf"+FILE_ARG+".txt",FILE_ARG+".txt");				//determines offset of elf segments
	functionBypass("app_obj/"+FILE_ARG+".txt");								//captures function addressing
	LoadMemory("app_obj/"+FILE_ARG+"_1.txt");								//reginfo
	LoadMemory("app_obj/"+FILE_ARG+"_2.txt");								//init
	LoadMemory("app_obj/"+FILE_ARG+"_3.txt");								//text
	LoadMemory("app_obj/"+FILE_ARG+"_4.txt");								//__libc_freeres_fn
	LoadMemory("app_obj/"+FILE_ARG+"_5.txt");								//fini
	LoadMemory("app_obj/"+FILE_ARG+"_6.txt");								//rodata
	LoadMemory("app_obj/"+FILE_ARG+"_7.txt");								//data
	LoadMemory("app_obj/"+FILE_ARG+"_8.txt");								//__libc_subfreeres
	LoadMemory("app_obj/"+FILE_ARG+"_9.txt");								//__libc_atexit
	LoadMemory("app_obj/"+FILE_ARG+"_10.txt");								//eh_frame
	LoadMemory("app_obj/"+FILE_ARG+"_11.txt");								//gcc_except_table
	LoadMemory("app_obj/"+FILE_ARG+"_12.txt");								//ctors
	LoadMemory("app_obj/"+FILE_ARG+"_13.txt");								//dtors
	LoadMemory("app_obj/"+FILE_ARG+"_14.txt");								//jcr
	if (FILE_ARG.find("noio")==string::npos)LoadMemory("app_obj/"+FILE_ARG+"_15.txt");		//got
	LoadMemory("app_obj/"+FILE_ARG+"_19.txt");								//comment
	LoadMemory("app_obj/"+FILE_ARG+"_20.txt");								//debug_aranges
	LoadMemory("app_obj/"+FILE_ARG+"_21.txt");								//debug_pubnames
	LoadMemory("app_obj/"+FILE_ARG+"_22.txt");								//debug_info
	LoadMemory("app_obj/"+FILE_ARG+"_23.txt");								//debug_abbrev
	LoadMemory("app_obj/"+FILE_ARG+"_24.txt");								//debug_line
	if (FILE_ARG.find("noio")==string::npos)LoadMemory("app_obj/"+FILE_ARG+"_25.txt");		//debug_frame
	LoadMemory("app_obj/"+FILE_ARG+"_26.txt");								//debug_str
	LoadMemory("app_obj/"+FILE_ARG+"_27.txt");								//pdr
	LoadMemory("app_obj/"+FILE_ARG+"_28.txt");								//note.ABI-tag
	if (FILE_ARG.find("noio")==string::npos)LoadMemory("app_obj/"+FILE_ARG+"_30.txt");		//debug_ranges
	if (FILE_ARG.find("noio")==string::npos)LoadMemory("app_obj/"+FILE_ARG+"_31.txt");		//shstrtab
	if (FILE_ARG.find("noio")==string::npos)LoadMemory("app_obj/"+FILE_ARG+"_32.txt");		//symtab

	fill_syscall_redirects();

}


