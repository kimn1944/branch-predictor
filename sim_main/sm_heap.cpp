#include <map>
#include <unistd.h>
#include <cstdio> 
#include <iostream>
#include <unistd.h>
#include <cstdlib>
#include "sm_memory.h"
#include "sm_heap.h"
#include "sm_execinfo.h"


static uint32_t HEAP_END=0;

static std::map<uint32_t,int> HEAP_STATUS;
static uint32_t BLOCKNUM=1;

static uint32_t current_break = 0;

using namespace std;


//DISPLAYS HEAP CONTENTS
void heapDump(){
	int heapStart =  exec.HEAPSTART;
	/*int temp = exec.HEAPSTART+HEAP_STATUS.size();					//shift pointer to end of the allocated heap
	while ((unsigned)temp%4!=0) temp++;					//align pointer
	for(int i=temp; i>=exec.HEAPSTART; i-=4) {					//start from top down, print heap contents
		if (((MAIN_MEMORY[i]+MAIN_MEMORY[i+1]+MAIN_MEMORY[i+2]+MAIN_MEMORY[i+3])!=0)) {
			printf("Heap:  0x%x",i);
			printf("(+%*u): ",4,i-exec.HEAPSTART);
			//printf("0x%s ",((HEX_MAIN_MEMORY[i+3])+(HEX_MAIN_MEMORY[i+2])+(HEX_MAIN_MEMORY[i+1])+(HEX_MAIN_MEMORY[i+0])).c_str());
			printf("0x");
			printf("%s",getStringRep(MAIN_MEMORY[i+3]).c_str());
			printf("%s",getStringRep(MAIN_MEMORY[i+2]).c_str());
			printf("%s",getStringRep(MAIN_MEMORY[i+1]).c_str());
			printf("%s",getStringRep(MAIN_MEMORY[i+0]).c_str());
			cout << HEAP_STATUS[i];
			cout << HEAP_STATUS[i+1];
			cout << HEAP_STATUS[i+2];
			cout << HEAP_STATUS[i+3] << endl;
		}
	}*/
	cout << "-----Heap Dump------" << endl;
	cout << "  Heap Start: " << heapStart << endl;
	cout << "  Heap Size: " << HEAP_END-heapStart << endl;
	for(uint32_t i=heapStart; i<=HEAP_END; i++) {
		cout << num2Str (readWord(i));
		if(i%2!=0){
			cout<<endl;
		}
		else{
			cout<<"\t";
		}
	}
}

// prep heap block
void prepHeapBlock(uint32_t addr, uint32_t size){
	for(uint32_t i=addr; i<addr+size; i++){
		HEAP_STATUS[i] = BLOCKNUM;		//set heap word state variable	
	}
}

// malloc emulator
uint32_t mm_malloc(uint32_t size){
	if(size==0){return 0;}
	uint32_t heapStart =  exec.HEAPSTART;
	if(HEAP_END==0){HEAP_END=heapStart;}
	BLOCKNUM++;
	int blockCounter=0;
	for(uint32_t i=heapStart; i<=HEAP_END+size; i++) {
		// search for large enough space
		if (HEAP_STATUS[i]==0) {blockCounter++;}
		else {blockCounter=0;}
		// if large enough and aligned, prep the space
		uint32_t blockStart = i-size+1;
		if (blockCounter>=size && (blockStart%4==0)) {
		 	prepHeapBlock(blockStart,size);
			if(i>HEAP_END){HEAP_END=i;}
			memLog("Malloc returned " + num2Str(blockStart));
			return blockStart;
		}
	}
	// else, no more memory
	return 0;
}


// free() emulator
void mm_free(uint32_t addr){
	int heapStart =  exec.HEAPSTART;
	int num = HEAP_STATUS[addr];						//store the block # to be cleared
	memLog("Freeing " + num2Str(addr));
	if(addr == 0) {
		return;
	}
	if(num==0){
		fprintf(stderr,"Freeing unallocated memory at %8x!!!\n",addr);
		exit(-1);
	}
	for(uint32_t i=addr; i<=HEAP_END; i++) {			//iterate through memory resetting any states that match the block number
		if (HEAP_STATUS[i]==num)
			{HEAP_STATUS[i] = 0;}				//reset state
		else break;								//if the end of block is found break
	}
}

uint32_t mm_sbrk(int32_t value) {
	if(current_break < exec.BREAKSTART) {
		current_break = exec.BREAKSTART;
	}
	int64_t temp_break = current_break;
	temp_break += value;
	if(temp_break >= exec.BREAKSTART && temp_break < exec.HEAPSTART) {	//don't allow potential heap corruption
		current_break = temp_break;
	}
	return current_break;
}


