#ifndef EXECINFO_H
#define EXECINFO_H

#define MAX_BREAK_SIZE	0x10000000

struct execinfo{

	// all values here are big endian
	// since they mirror what's in the CPU

	int GSP;	// global stack pointer
	int GRA; // global return address
	int GPC_START;	// starting PC
	int HEAPSTART;  // start of heap
	int BREAKSTART;	// start of break
	int GP;	//Global Pointer (r28)
};

extern struct execinfo exec;

#endif
