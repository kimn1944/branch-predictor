/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
|        WRAPPER PROGRAM: Emulating OS for MIPS I Processor (MIPS32 ABI)                         |
|           This program automates the process of generating a binary                            |
|           and loading the hex dump of that program into a verilog processor                    |
|           memory map.  This wrapper also acts as the clock generator for                       |
|           the processor.                                                                       |
|        Written by Dan Snyder                                                                   |
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

/*
 * Made actually usable (and reasonable) by Joe Israelevitz
 *
 * Polish by Isaac Richter
 *
 */

#include <bitset>
#include <cstdio>
#include <cstdlib>
#include <errno.h>
#include <fstream>
#include <getopt.h>
#include <iomanip>
#include <iostream>
#include <istream>
#include <limits.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>
#include <vector>
#include <verilated.h>		//verilator lib
#ifdef SUPPORT_VCD
#include "verilated_vcd_c.h"
#endif
#include "VMIPS.h"		//for access to verilog parent module
#include "VMIPS_MIPS.h"		//for access to verilog submodules

#ifndef OOO
#include "VMIPS_ID.h"
#else
#include "VMIPS_RetireCommit.h"
#include "VMIPS_RegRead.h"
#endif


// moved some functionality out of here
#include "sm_memory.h"
#include "sm_heap.h"
#include "sm_txtload.h"
#include "sm_syscalls.h"
#include "sm_execinfo.h"
#include "sm_elfload.h"
#include "sm_regfile.h"
/*
 * MIPS syscall definitions can be found here
#include "asm/sgidefs.h"
#define _MIPS_SIM	_MIPS_SIM_ABI32
#define __mips_soft_float
#include "asm/syscall.h"
*/

using namespace std;

static unsigned int MAINTIME = 0;
static float IPC=0;
static int INSTR_COUNT=0;
#ifdef DEBUG_CACHE
static int MEM_INSTR_COUNT=0;
static int MEM_CACHE_REQ_COUNT=0;
#endif


// simulation options - can be set command line
enum {/*EXEC_TEXT,*/ EXEC_ELF};
static int elf_format=EXEC_ELF;
int ENABLE_TIMING =1;
string FILE_ARG; // path to input elf or text files
int duration = 1;

// monitoring output parameters - can be set command line
bool MONITOR_HEAP = 0;
bool MONITOR_REGS = 1;
bool MONITOR_PTRS = 1;
#ifdef DOUBLE_FETCH
#define DDF_DEFAULT 1
#else
#define DDF_DEFAULT 0
#endif
bool DEBUG_DOUBLE_FETCH = DDF_DEFAULT;
//bool MONITOR_MEMORY = 0; // parameter in sm_memory.h
bool verbose = 0;

int SINGLE_STEP_QUIT = 0;

// hardware description
int START_REG=0;
int NUMBER_OF_REGS = 32;

//Where to unconditionally drop into single-step
int BREAKPOINT=-1;

// cache output file
#ifdef DEBUG_CACHE
ofstream cachewrite("./cachewrite.txt");
#endif

// COMMAND LINE FUNCTIONS -----------------------------
extern char *optarg;
char* argv0;
void printargdef(){
	fprintf(stderr, "usage: %s [APP_NAME] <DURATION>\n", argv0);
	puts("OR");
	fprintf(stderr, "usage: %s [-f file_path] <arguments>\n", argv0);
	fprintf(stderr, "-v : verbose\n");
	//puts("-e : elf load (otherwise text)");
	fprintf(stderr, "-m [0/1]: monitor main memory (to file ./memwrite) no/yes [default=1]\n");
	fprintf(stderr, "-y [0/1]: monitor heap no/yes [default=0]\n");
	fprintf(stderr, "-r [0/1]: monitor ptrs no/yes [default=1]\n");
	fprintf(stderr, "-p [0/1]: monitor regs no/yes [default=1]\n");
	fprintf(stderr, "-d {0,9}+: duration between halts [default=0]\n");
	fprintf(stderr, "-b {value}: where we unconditionally drop into single-instruction mode\n");
	fprintf(stderr, "            may be specified in hex as 0x12345678\n");
	fprintf(stderr, "-l [0/1]: emulate LL/SC commands [default=1]\n");
	fprintf(stderr, "-2 [0/1]: monitor double-fetch [default=%d]\n", DDF_DEFAULT);
	fprintf(stderr, "-q [0/1]: quit when breaking into single-step mode [default=0]\n");
	fprintf(stderr, "-h : show usage\n");
}
void readcommandline(int argc, char** argv){
	int c;
	argv0 = argv[0];
	int numopts=0;
	bool file = 0;
	// Read command line
	while ((c = getopt (argc, argv, "f:vy:m:p:r:hd:b:l:2:q:")) != -1){
		numopts++;
		switch (c) {
			case 'f':
				FILE_ARG = optarg;
				file = 1;
		    	break;
			case 'v':
		    	verbose = 1;
		    	break;
			case 'y':
				MONITOR_HEAP = atoi(optarg);
				break;
			case 'm':
				MONITOR_MEMORY = atoi(optarg);
				break;
			case 'p':
				MONITOR_PTRS = atoi(optarg);
				break;
			case 'r':
				MONITOR_REGS = atoi(optarg);
				break;
			case 'd':
				duration = atoi(optarg);
				break;
			case 'b':
				BREAKPOINT = strtol(optarg, NULL, 0);
				break;
			case 'l':
				EMULATE_LLSC = atoi(optarg);
				break;
			case '2':
				DEBUG_DOUBLE_FETCH = atoi(optarg);
				break;
			case 'q':
				SINGLE_STEP_QUIT = atoi(optarg);
				break;
			case 'h':
				printargdef();
				exit(0);
				break;
        	}
	}
	if(numopts==0 && (argc == 3 || argc == 2)) {
		FILE_ARG = argv[1];
		file=1;
		if(argc==3) {
			duration = atoi(argv[2]);
		}
		elf_format = EXEC_ELF;
	}
	if(!file){
		fprintf(stderr, "Error: No file to load\n");
		printargdef();
		exit(0);
	}
}

/*
const char * opcode_to_instr(uint32_t instruction) {
	uint32_t op = (instruction >> 26) & 0x3F;
	uint32_t rs = (instruction >> 21) & 0x1F;
	uint32_t rt = (instruction >> 16) & 0x1F;
	uint32_t imm = instruction & 0xFFFF;
	uint32_t rd = (instruction >> 11) & 0x1F;
	uint32_t shamt = (instruction >> 6) & 0x1F;
	uint32_t funct = instruction & 0x3F;
	uint32_t target = instruction & 0x3FFFFFF;
	switch(op) {
	case 0:
		switch(funct) {
		case 0:
			return "SLL";
		case 2:
			return "SRL";
		case 3:
			return "SRA";
		case 4:
			return "SLLV";
		case 6:
			return "SRLV";
		case 7:
			return "SRAV";
		case 8:
			return "JR";
		case 9:
			return "JALR";
		case 12:
			return "SYSCALL";
		case 13:
			return "BREAK";
		case 16:
			return "MFHI";
		case 17:
			return "MTHI";
		case 18:
			return "MFLO";
		case 19:
			return "MTLO";
		case 24:
			return "MULT";
		case 25:
			return "MULTU";
		case 26:
			return "DIV";
		case 27:
			return "DIVU";
		case 32:
			return "ADD";
		case 33:
			return "ADDU";
		case 34:
			return "SUB";
		case 35:
			return "SUBU";
		case 36:
			return "AND";
		case 37:
			return "OR";
		case 38:
			return "XOR";
		case 39:
			return "NOR";
		case 42:
			return "SLT";
		case 43:
			return "SLTU";
		default:
			return "UNKNOWN SPECIAL";
		}
		break;
	case 1:
		switch(rd) {
		case 0:
			return "BLTZ";
		case 1:
			return "BGEZ";
		case 16:
			return "BLTZAL";
		case 17:
			return "BGEZAL";
		default:
			return "UNKNOWN REGIMM";
		}
		break;
	case 2:
		return "J";
	case 3:
		return "JAL";
	case 4:
		return "BEQ";
	case 5:
		return "BNE";
	case 6:
		return "BLEZ";
	case 7:
		return "BGTZ";
	case 8:
		return "ADDI";
	case 9:
		return "ADDIU";
	}
}
*/


void print_binary(uint32_t value, uint8_t length) {
	while(length > 0) {
		printf("%d", (value >> length) & 1);
		length--;
	}
}

void print_instruction(uint32_t address) {
	uint32_t instruction = readWord(address);
	uint32_t op = (instruction >> 26) & 0x3F;
	uint32_t rs = (instruction >> 21) & 0x1F;
	uint32_t rt = (instruction >> 16) & 0x1F;
	uint32_t imm = instruction & 0xFFFF;
	uint32_t rd = (instruction >> 11) & 0x1F;
	uint32_t shamt = (instruction >> 6) & 0x1F;
	uint32_t funct = instruction & 0x3F;
	uint32_t target = instruction & 0x3FFFFFF;
	printf("pc: %s \t",num2Str(address).c_str());
	printf("inst: %s \n",num2Str(instruction).c_str());
	if(op & 0x20) {
		printf("Load/Store: Op=6'b");
		print_binary(op, 6);
		printf(", rs=5'd%02u, rt=5'd%02u, offset=16'h%04X\n", rs, rt, imm);
		//Is a Load/Store instruction (I-type)
	}else if(!op) {
		printf("SPECIAL: Func=6'b");
		print_binary(funct, 6);
		printf(", rs=5'd%02u, rt=5'd%02u rd=5'd%02u, shift=5'd%02u\n", rs, rt, rd, shamt);
		//Is a special (R-type)
	}else if((op & 0x38) == 0x8) {
		printf("MathImm: Op=6'b");
		print_binary(op, 6);
		printf(", rs=5'd%02u, rt=5'd%02u, ", rs, rt);
		if(op >= 0xb) {
			printf("unsigned const=16'h%04X\n", imm);
		} else {
			printf("signed const=16'h%04X\n", imm);
		}
		//Is an [Math]Immediate (I-type)
	}else if(op == 0x01 || (op >= 0x04 && op <= 0x07)) {
		printf("Branch: Op=6'b");
		print_binary(op, 6);
		printf(", rs=5'd%02u, type=5'd%02u, offset=16'h%04x\n", rs, rt, imm);
		//Is a Branch instruction (I-type)
	}else if(op == 0x02 || op == 0x03) {
		printf("Jump: Op");
		print_binary(op, 6);
		printf(", destination=26'h%07x\n", target);
		//Is a Jump[and link] instruction (J-type)
	}else {
		printf("Unknown: ");
		print_binary(op, 6);
		printf(" ");
		print_binary(rs, 5);
		printf(" ");
		print_binary(rt, 5);
		printf(" ");
		print_binary(rd, 5);
		printf(" ");
		print_binary(shamt, 5);
		printf(" ");
		print_binary(funct, 6);
		printf("\n");
	}
}

void print_instructions(uint32_t address) {
	print_instruction(address);
	if(DEBUG_DOUBLE_FETCH) {
		printf("I2 ");
		print_instruction(address + 4);
	}
}

typedef enum block_fsm {
	MEM_FSM_IDLE = 0,
	MEM_FSM_WAIT2,
	MEM_FSM_WAIT1,
	MEM_FSM_GO,
	MEM_FSM_FINISH7,
	MEM_FSM_FINISH6,
	MEM_FSM_FINISH5,
	MEM_FSM_FINISH4,
	MEM_FSM_FINISH3,
	MEM_FSM_FINISH2,
	MEM_FSM_FINISH1,
	MEM_FSM_FINISH0,
} mem_fsm_t;

#define mem_fsm_t_last	MEM_FSM_FINISH1

static mem_fsm_t icache_fsm = MEM_FSM_IDLE;
static uint32_t	 icache_last_addr = 0;
static mem_fsm_t dcache_fsm = MEM_FSM_IDLE;
static uint32_t  dcache_last_addr = 0;

void update_mem_fsm(mem_fsm_t *fsm) {
	if(*fsm == mem_fsm_t_last) {
		*fsm = MEM_FSM_IDLE;
		printf("IDLE");
	} else if(*fsm != MEM_FSM_IDLE) {
		*fsm = static_cast<mem_fsm_t>((*fsm) + 1);
		printf("%d", *fsm);
	} else {
		printf("[still] IDLE");
	}
	puts("");
}

static void mem_request_clock(void) {
	printf("Updating icache_fsm ");
	update_mem_fsm(&icache_fsm);
	printf("Updating dcache_fsm ");
	update_mem_fsm(&dcache_fsm);
}

bool mem_process_request(mem_fsm_t *fsm, uint32_t *fsm_address, uint32_t req_address) {
	switch(*fsm) {
	case MEM_FSM_IDLE:
		*fsm_address = req_address;
		*fsm = MEM_FSM_GO;
		//Since DCache includes 1-cycle delay, this is safe to skip MEM_FSM_WAIT2,MEM_FSM_WAIT1
		//and return data for use on next clock.
		return true;
	case MEM_FSM_WAIT2:
		return false;
	case MEM_FSM_GO:
		return true;
	default:
		return false;
	}
}

int CLOCK_COUNTER=0; // number of cycles completed in the simulation

/************************************/
/*********** MAIN PROGRAM ***********/
/************************************/
// WTF - this is the one real comment in this entire program...
// and it's unnecessary.
/*
 * Historical note: When this source code was given to students in Fall 2013
 * and before, the above snark was actually correct.
 */
int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);
#ifdef SUPPORT_VCD
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
#endif
	VMIPS *top = new VMIPS;  // top is our CPU.
#ifdef SUPPORT_VCD
	top->trace (tfp, 99);
	tfp->open ("mips.vcd");
#endif
	vector<string> FDT_filename;
	vector<int> FDT_state;//1 = open, 0 = closed
	time_t seconds;
	stringstream temps;
	stringstream s;
	int FileDescriptorIndex=3;//start of non-reserved indexes
	int temp_address=0;
	int syscallIndex=0;
	int instruction=0;
	int source=0;
	int immediate=0;
	int base=0;
	int rt=0;
	int SWC_tmp=0;

	uint32_t fetch_stall_stopper;

	// used for checking for progress
	// (nontrivial after adding ICache)
	uint32_t prevInstructionAddr;
	uint32_t nextInstruction;
	uint32_t nextInstructionAddr;
	uint32_t secondInstruction;


	int FUNCTION_FLAG;  // flag to check for nops, syscalls


	// read command line arguments
	readcommandline( argc, argv);

	// load file descriptors
	// (first 3 positions reserved for stdin, stdout, and stderr)
	FDT_filename.push_back("stdin");FDT_state.push_back(0);		//reserve fildes 0 for stdin
	FDT_filename.push_back("stdout");FDT_state.push_back(0);// should this be 1??	//reserve fildes 1 for stdout
	FDT_filename.push_back("stderr");FDT_state.push_back(0);// should this be 2??	//reserve fildes 2 for stderr




	// Load ELF -------------------------------
	cout << "		*** ELF LOADING, PLEASE WAIT ***\n";

	ofstream stdoutFile("stdout.txt");
	ofstream stderrFile("stderr.txt");

	// set initial parameters
	top->Instr1_fIM = 0;
	top->CLK = 0;


	// Load ELF from text?
	/*if (elf_format==EXEC_TEXT) {
		LoadOSMemoryTXT(FILE_ARG);
	}
	else*/ if(elf_format==EXEC_ELF){
		if(LoadOSMemoryELF(FILE_ARG.c_str())<0){
			fprintf(stderr,"Unable to load file %s\n",FILE_ARG.c_str());
			return -1;
		}
	}

	write_initialization_vector(exec.GSP, exec.GP, exec.GPC_START);

	/*------------------------------------------------------------------------------------------------
	|        This section contains									 |
	|	    -MIPS object and all of the run-time displays			   		 |
	|           -Syscall interface									 |
	|           -Low level test interface (load instructions manually)				 |
	------------------------------------------------------------------------------------------------*/
	cout << "		      *** PROGRAM EXECUTING ***\n";
	seconds  = time (NULL);

#ifndef OOO
	init_register_access(top->v->ID->RegFile, top->v->EXE);
#else
	init_register_access(top->v->RegRead->PhysRegFile, top->v->RetireCommit);
#endif

	// boot sequence
	puts("########################################\n");
	puts("### Boot Sequence###\n");
	top->RESET = 1;
	top->eval();
	top->RESET = 0;
	top->eval();
	top->RESET = 1;
	top->Instr1_fIM = readWord(top->Instr_address_2IM);

	top->eval();
	memLog("Finished Boot");
	puts("### Finished Boot ###\n");
	if(MONITOR_PTRS){
		puts("--PTR DUMP-------------------------");
		print_instructions(top->v->Instr_address_2IC);
		printf("sp: %s \t",num2Str(read_register(29)).c_str());
		printf("ra: %s \t",num2Str(read_register(31)).c_str());
		printf("cycle: %d",CLOCK_COUNTER);
		puts("\n");
	}
	puts("########################################\n");

	while (!Verilated::gotFinish()){
		top->CLK=!(top->CLK);									//generate a clock that pulses on eval()
		MAINTIME++;										//increment time
#ifdef SUPPORT_VCD
		tfp->dump (MAINTIME);
#endif
		s.str("");									//for instruction processing

		// MEMORY ACCESSES
		if(top->MemRead_2DM) {		//read from memory
			top->data_read_fDM=readWord(top->data_address_2DM & 0xfffffffc );
			printf("Reading data %08x from location %08x\n", readWord(top->data_address_2DM & 0xfffffffc ), top->data_address_2DM & 0xfffffffc);
		}
		if(top->MemWrite_2DM) {
			printf("Mem Write:");
			switch(top->data_write_size_2DM) {
				case 0:
					printf("word %08x to %08x\n",top->data_write_2DM,top->data_address_2DM);
					writeWord(top->data_address_2DM,top->data_write_2DM);
					break;
				case 1:
					printf("byte %02hhx to %08x\n",(uint8_t)(top->data_write_2DM),top->data_address_2DM);
					writeByte(top->data_address_2DM,top->data_write_2DM);
					break;
				case 2:
					printf("halfword %04hx to %08x\n",(uint16_t)(top->data_write_2DM),top->data_address_2DM);
					writeHalfWord(top->data_address_2DM,top->data_write_2DM);
					break;
				case 3:
					printf("0.75word %06x to %08x\n",(top->data_write_2DM & 0xffffff),top->data_address_2DM);
					writeByte(top->data_address_2DM,top->data_write_2DM>>16);
					writeHalfWord(top->data_address_2DM+1,top->data_write_2DM & 0xffff);
					break;
			}
		}

#ifdef DEBUG_CACHE
		if(top->v->data_valid_fDC && top->CLK) {
			if(top->v->read_2DC) {
				cachewrite << "ReadW:\t" << num2Str(top->v->data_read_fDC)<<" at "<<num2Str((uint32_t)top->v->data_address_2DC)<<"\tcycle:"<<((uint32_t)CLOCK_COUNTER)<<endl;
			}
			if(top->v->write_2DC) {
				switch(top->v->data_write_size_2DC) {
				case 0:
					cachewrite << "WriteW:\t" << num2Str(top->v->data_write_2DC)<<" at "<<num2Str((uint32_t)top->v->data_address_2DC)<<"\tcycle:"<<((uint32_t)CLOCK_COUNTER)<<endl;
					break;
				case 1:
					cachewrite << "WriteB:\t      " << num2Str((uint8_t)top->v->data_write_2DC)<<" at "<<num2Str((uint32_t)top->v->data_address_2DC)<<"\tcycle:"<<((uint32_t)CLOCK_COUNTER)<<endl;
					break;
				case 2:
					cachewrite << "WriteH:\t    " << num2Str((uint16_t)top->v->data_write_2DC)<<" at "<<num2Str((uint32_t)top->v->data_address_2DC)<<"\tcycle:"<<((uint32_t)CLOCK_COUNTER)<<endl;
					break;
				case 3:
					cachewrite << "Write3:\t  " << num2Str3((uint32_t)((uint32_t)top->v->data_write_2DC) & 0xffffff)<<" at "<<num2Str((uint32_t)top->v->data_address_2DC)<<"\tcycle:"<<((uint32_t)CLOCK_COUNTER)<<endl;
					break;
				}
			}
			if(top->v->flush_2DC) {
				cachewrite << "Flush" <<"\tcycle:"<<((uint32_t)CLOCK_COUNTER)<< endl;
			}
		}
#endif

		////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		s << hex << top->v->Instr_address_2IM << endl;		//gets the next instruction ready for processing, needed for syscalls???



		//normal instruction supply (no function call or special instruction call)
		// (no ICACHE)
		nextInstructionAddr = top->v->Instr_address_2IC;
		nextInstruction = readWord(nextInstructionAddr);
		secondInstruction = readWord(nextInstructionAddr+4);

		// check for progress, and set counters
		if(prevInstructionAddr != nextInstructionAddr){
#ifdef DEBUG_CACHE
			// check for cache miss in uncached variant
			if((0xC0000000 & nextInstruction) == 0x80000000) {
				printf("!!!MemInstruction0x%x\n",nextInstruction);
				MEM_INSTR_COUNT++;
			}
#endif
			/*if(((nextInstruction & 0xF0000000)==0x80000000)){ // LB, LH, LWL, LW
				printf("!!!MemRead0x%x\n",nextInstruction);
				//MEM_INSTR_COUNT++;
			}else if (((nextInstruction & 0xF0000000)==0x90000000)){ // LBU, LHU, LWR, LWU
				printf("!!!MemReadEx0x%x\n",nextInstruction);
				//MEM_INSTR_COUNT++;
			}else if (((nextInstruction & 0xF0000000)==0xA0000000)){ // SB, SH, SWL, SW
				printf("!!!MemWrite0x%x\n",nextInstruction);
				//MEM_INSTR_COUNT++;
			}else if (((nextInstruction & 0xF0000000)==0xB0000000)){ // SDL, SDR, SWR, CACHE
				printf("!!!MemWriteEx0x%x\n",nextInstruction);
				//MEM_INSTR_COUNT++;
			}*/

			INSTR_COUNT++;
			prevInstructionAddr=nextInstructionAddr;

		}

#ifdef DEBUG_CACHE
		if(top->v->data_valid_fDC && top->CLK) {
			if(top->v->write_2DC) {
				printf("!!!MemCacheWrite\n");
				MEM_CACHE_REQ_COUNT++;
				//MEM_INSTR_COUNT++;
			}
			if(top->v->read_2DC) {
				printf("!!!MemCacheRead\n");
				MEM_CACHE_REQ_COUNT++;
				//MEM_INSTR_COUNT++;
			}
			if(top->v->flush_2DC) {
				printf("!!!MemCacheFlush\n");
				MEM_CACHE_REQ_COUNT++;
				//MEM_INSTR_COUNT++;
			}
		}
#endif

		// check for illegal instructions
		uint32_t opcode = (nextInstruction & 0xfc000000);
		if((nextInstruction & 0xF36003FF) == 0x40000000){		// m[ft]cz
			fprintf(stderr,"Illegal opcode mfc/mtc at %8x\n",nextInstructionAddr);
			return -1;
		}
		if((nextInstruction & 0xD0000000) == 0xC0000000){		// [ls]wc[0123]
			printf("LWCz/SWCz at %8x\n",nextInstructionAddr);
			if((nextInstruction & 0xC000000) != 0x0) {	//But we don't want [ls]wc0
				fprintf(stderr,"Illegal opcode mfc/mtc at %8x\n",nextInstructionAddr);
				exit(-1);
			}
		}
		opcode = (secondInstruction & 0xfc000000);
		if((secondInstruction & 0xF36003FF) == 0x40000000){		// m[ft]cz
			fprintf(stderr,"Illegal opcode mfc/mtc at %8x\n",nextInstructionAddr+4);
			return -1;
		}
		if((secondInstruction & 0xD0000000) == 0xC0000000){		// [ls]wc[0123]
			printf("LWCz/SWCz at %8x\n",nextInstructionAddr+4);
			if((secondInstruction & 0xC000000) != 0x0) {	//But we don't want [ls]wc0
				fprintf(stderr,"Illegal opcode mfc/mtc at %8x\n",nextInstructionAddr+4);
				exit(-1);
			}
		}
		// provide next instruction to CPU
		if(top->Instr_address_2IM) {
			if(top->Instr_address_2IM == top->v->Instr_address_2IC) {
				top->Instr1_fIM = nextInstruction;
				top->Instr2_fIM = secondInstruction;
			} else {
				top->Instr1_fIM = readWord(top->Instr_address_2IM);
				top->Instr2_fIM = readWord(top->Instr_address_2IM + 4);
			}
		} else {
			top->Instr1_fIM = 0;
			top->Instr2_fIM = 0;
		}
	//}
		if(MAINTIME%2==0) {									//when the clock is positive do the following
			CLOCK_COUNTER ++;
//BREAKPOINT == top->v->Instr_address_2IM ||
			if(BREAKPOINT == nextInstructionAddr) {
				printf("******  HIT BREAKPOINT  ******\n");
				duration=CLOCK_COUNTER;
			}
			if((nextInstructionAddr < 0x400000) && CLOCK_COUNTER>1){
				printf("******  Jumped near 0  ******\n");
				duration=CLOCK_COUNTER;
			}

#ifdef DEBUG_FETCH_STALL
			if(top->v->Fetch->want_fetch_stall) {
				fetch_stall_stopper ++;
			} else {
				fetch_stall_stopper = 0;
			}
			if(fetch_stall_stopper > 500) {
				duration=CLOCK_COUNTER;
				printf("******  Fetch Stall Function broke something.  ******\n");
				printf("****** Check 500 cycles ago (it started then.) ******\n");
			}
#endif


			/*------------------------------------------------------------------------------------------------
			|				       DISPLAYS		  				          |
			------------------------------------------------------------------------------------------------*/
			if(CLOCK_COUNTER>=duration) {
				puts("########################################\n");
				printf("### @ Start of Cycle %d ###\n",CLOCK_COUNTER);
				if(MONITOR_HEAP){
					puts("--HEAP DUMP-------------------------\n");
					heapDump();
					puts("\n");
				}
				if(MONITOR_REGS){
#ifndef OOO
					puts("--REG DUMP------------------------- ");
					for (int j=START_REG; j < NUMBER_OF_REGS; j++) {
						printf("REG[%2d]: %s (%d)",j,num2Str(read_register(j)).c_str(),read_register(j));
						if(j%2==0){printf("\t\t");}
						else{printf("\n");}
					}
					printf("REG[LO]: %s (%d)\t\tREG[HI]: %s (%d)",num2Str(read_register(33)).c_str(),read_register(33),num2Str(read_register(34)).c_str(),read_register(34));
					puts("\n");
#else
					puts("--REG DUMP------------------------- [Arch:Phys]");
					for (int j=START_REG; j < NUMBER_OF_REGS; j++) {
						printf("REG[%2d:%2d]: %s (%d)",j,register_arch_to_phys(j),num2Str(read_register(j)).c_str(),read_register(j));
						if(j%2==0){printf("\t\t");}
						else{printf("\n");}
					}
					printf("REG[LO:%2d]: %s (%d)\t\tREG[HI:%2d]: %s (%d)",register_arch_to_phys(33),num2Str(read_register(33)).c_str(),read_register(33),register_arch_to_phys(34),num2Str(read_register(34)).c_str(),read_register(34));
					puts("\n");
#endif
				}
				if(MONITOR_PTRS){
					puts("--PTR DUMP-------------------------");
					print_instructions(nextInstructionAddr);
/*
					printf("next pc: %s \t",num2Str(top->v->Instr_address_2IC).c_str());
					printf("next inst: %s \n",num2Str(readWord(top->v->Instr_address_2IC)).c_str());
*/
					if(!MONITOR_REGS) {
						printf("sp: %s \t",num2Str(read_register(29)).c_str());
						printf("ra: %s \t",num2Str(read_register(31)).c_str());
						printf("cycle: %d",CLOCK_COUNTER);
						puts("\n");
					}
				}
				printf("### finished output for Cycle %d ###\n",CLOCK_COUNTER);
				puts("########################################\n");
			}
			else{
				printf("cycle %d\n",CLOCK_COUNTER);
			}

			/*
			if(((nextInstructionAddr & 0xFFFFFF00) != 0xBFC00000) && (read_register(28) != exec.GP)) {
				printf("!!!GP Tampering!!!\n");
				duration = CLOCK_COUNTER;
			}
*/
			if(((nextInstructionAddr & 0xFFFFFF00) != 0xBFC00000) && (!read_register(28))) {
				printf("!!!GP Tampering (==0) @ 0x%08x!!!\n", nextInstructionAddr);
				duration = CLOCK_COUNTER;
			}

			mem_request_clock();

			//Handle cache reads
			if(top->iBlkRead) {
				int i;
				for(i = 0; i < 8; i++) {
					top->block_read_fIM[7-i] = readWord(top->Instr_address_2IM + (i*4));
				}
				top->block_read_fIM_valid = mem_process_request(&icache_fsm, &icache_last_addr, top->Instr_address_2IM);
				if(top->block_read_fIM_valid) {
					printf("Processed iRead from 0x%08x, read values:\n", top->Instr_address_2IM);
					for(i = 0; i < 8; i++) {
						printf("%08x",top->block_read_fIM[7-i]);
					}
					printf("\n");
				}
			}
			else{top->block_read_fIM_valid = 0;}

			if(top->dBlkRead) {
				int i;
				for(i=0;i<8;i++) {
					top->block_read_fDM[7-i] = readWord(top->data_address_2DM + (i*4));
				}
				top->block_read_fDM_valid = mem_process_request(&dcache_fsm, &dcache_last_addr, top->data_address_2DM);
			} else {top->block_read_fDM_valid = 0;}

			//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			/*------------------------------------------------------------------------------------------------
			|						SYSCALLS													 |
			------------------------------------------------------------------------------------------------*/

			syscallIndex = read_register(2);	//get syscall number from register 2
			if (top->SYS==1) {					//if a syscall is detected
				printf("in SYSCALL: %d\n", syscallIndex);
				printf("in syscall processing:\n");
				switch (syscallIndex) {
					case 4246:
					case 4001:{	cout << "Exit at time:" << CLOCK_COUNTER << endl;										//exit
						if(ENABLE_TIMING){
							seconds  = time(NULL) - seconds;
							cout << "*********************************" << endl;
							cout << "Simulation time : " << seconds << " sec" << endl;
							cout << "Total cycles: " << CLOCK_COUNTER << endl;
#ifdef DEBUG_CACHE
							uint32_t uncached_cycles = INSTR_COUNT*10 + MEM_INSTR_COUNT*10;
							cout << "Total cycles (uncached): "<<uncached_cycles <<endl;
							cout << "Memory Instructions:" << MEM_INSTR_COUNT <<endl;
							cout << "Memory [Cache] Requests:" << MEM_CACHE_REQ_COUNT <<endl;
#endif
							cout << "Total instructions: " <<INSTR_COUNT << endl;
							IPC = (float)INSTR_COUNT/((float)CLOCK_COUNTER);
							cout << "IPC: " << IPC << endl;
#ifdef DEBUG_CACHE
							cout << "IPC(uncached): " << (float)INSTR_COUNT/(float)uncached_cycles<<endl;
#endif
						}
						 stdoutFile.close();
						 stderrFile.close();
#ifdef SUPPORT_VCD
						tfp->close();
#endif
#ifdef DEBUG_CACHE
						 cachewrite.close();
#endif
						syscall(SYS_exit, read_register(4));
					break;}
					case 4003:{cout << "ReadFile at time:" << CLOCK_COUNTER << endl;										//read
						//duration = 0;
						string input1;
						string input;
						int addr,i;
						addr = read_register(5);						//memory entry pointed to by argument
						if(read_register(4)==0) cin >> input;					//if STDIN use stdio
						else {												//otherwise must be a file
							ifstream indata(FDT_filename[read_register(4)].c_str());	//stream in contents of file
							while(!indata.eof()){									//until eof
								getline (indata,input1);
								input = input + input1;								//accumulate string
							}
						}
						if (input.size()>70)input.insert(70,"\n");							//syscall reads 70 chars at a time
						for (i=addr;i<=addr+input.size();i++) loadSingleHEX(input[i-addr],i,0,1);			//load content to memory
						loadSingleHEX("0a",i-1,0,1);									//end block with "0a"
						if (read_register(4)==0) {						//if STDIN && open
							if (FDT_state[read_register(4)]!=0){					//close file when done
								write_register(2,i-addr);									//return number of chars read
								FDT_state[read_register(4)]=0;					//set state bit
							}else write_register(2,i-addr);									//if STDIN && closed
						}
						else {												//if fildes > 2 ( !(STD(IN,OUT,ERR) )
							if (FDT_state[read_register(4)]!=0){					//close file when done
								write_register(2,i-addr);									//return number of chars read
								FDT_state[read_register(4)]=0;					//set state bit
							}else write_register(2,0);									//if fildes > 2 && closed
						}
					break;}
					case 4004:{										//write
						//duration = 0;
						cout << "WriteToFile at time:" << CLOCK_COUNTER << endl;
						int convert;									//accumulator for filename char convert
						int flag = 0;									//loop break flag
						int byte_offset;
						unsigned int k=read_register(5);						//start at specified element
						unsigned int length=read_register(6);
						int i = k;
						if (read_register(4)!=1 && read_register(4)!=2) {
							ofstream _file;
							printf("WriteToFile char %02x, %02x\n",(char)MAIN_MEMORY[i], (char)MAIN_MEMORY[i+1]);
							_file.open(FDT_filename[read_register(4)].c_str(), ios::out | ios::app );
							while (length != 0) {
								length--; _file << (char)MAIN_MEMORY[i];
								i++;
							}
							_file.close();
						}
						else {
							while (MAIN_MEMORY[i]!=00) {
								length--; cout<<(char)MAIN_MEMORY[i];
								if(read_register(4)==1) {
									stdoutFile << (char)MAIN_MEMORY[i];
								} else {
									stderrFile << (char)MAIN_MEMORY[i];
								}
								i++; if(length == 0)break;
							}
							if(read_register(4)==1) {
								stdoutFile.flush();
							} else {
								stderrFile.flush();
							}
							cout.flush();
						}
						i++;
						write_register(2,i-k-1);
					break;}
					case 4005:{		 									//open file
						//duration = 0;
						cout << "OpenFile at time:" << CLOCK_COUNTER << endl;
						string filename;
						int k=(read_register(4));
						while ( MAIN_MEMORY[k]!=0 ) { filename = filename + (char)MAIN_MEMORY[k]; k++; }
					 	FDT_filename.push_back(filename);			        			//add new filename to newest location
						FDT_state.push_back(1);									//add new open indicator to newest location
						write_register(2,FileDescriptorIndex);						//place file descriptor into register
						FileDescriptorIndex++;									//ready the next file descriptor
						ofstream _file;
						_file.open(filename.c_str(), ios::out | ios::trunc);	//And truncate it (since that's what file.cpp wants)
						_file.close();
						duration = CLOCK_COUNTER;
					break;}
					case 4006:{cout << "CloseFile at time:" << CLOCK_COUNTER << endl;FDT_state[read_register(4)]=0;write_register(2,0);						//duration = 0;
break;}			//close file
					case 4018:{cout << "Stat at time:" << CLOCK_COUNTER << endl;									//stat
					//duration = 0;
						write_register(4,read_register(5));
						write_register(5,read_register(6));
						struct stat buf;
						write_register(2,stat(FDT_filename[read_register(4)].c_str(),&buf));
						fxstat64(read_register(29));
					break;}
					case 4020:{cout << "Getpid at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getpid));break;}		//getpid
					case 4024:{cout << "Getuid at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getuid));break;}		//getuid
					case 4028:{	cout << "FStat at time:" << CLOCK_COUNTER << endl;										//fstat
						//duration = 0;
						write_register(4,read_register(5));
						write_register(5,read_register(6));
						struct stat buf;
						write_register(2,fstat(read_register(4),&buf));
						fxstat64(read_register(29));
					break;}
					case 4037:{cout << "Kill at time:" << CLOCK_COUNTER << endl;write_register(2,kill(read_register(4),read_register(5)));break;}			//kill
					case 4045:{cout << "brk at time: " << CLOCK_COUNTER << endl;
						uint32_t value = read_register(4);
						uint32_t result = mm_sbrk(value);
						cout << "sbrk(" << value << ")=" << result << endl;
						write_register(2, result);
						break;}
					case 4047:{cout << "Getgid at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getgid));break;}		//getgid
					case 4049:{cout << "Geteuid at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_geteuid));break;}
						//			CLOCK_COUNTER-=3;break;} // no idea why we would do this
					case 4050:{cout << "Getegid at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getegid));break;}		//getegid
					case 4064:{cout << "Getppid at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getppid));break;}		//getppid
					case 4065:{cout << "Getpgrp at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getpgrp));break;}		//getpgrp
					case 4076:{cout << "Getrlimit at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getrlimit));break;}		//getrlimit
					case 4077:{cout << "Getrusage at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getrusage));break;}		//getrusage
					case 4078:{cout << "GetTimeofDay at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_gettimeofday,NULL,NULL));break;}		//gettimeofday
					case 4090:{cout << "MMap at time:" << CLOCK_COUNTER << endl;
					//duration = 0;
						uint32_t size = read_register(5)*(1+read_register(4));
						if(size < 32){size = 32;}
						uint32_t ans = mm_malloc(size);
						cout << "MMap: " << ans << endl; //101807 jump to zero in sort
						write_register(2,ans);
						break;}
					case 4091:{cout << "Munmap at time:" << CLOCK_COUNTER << endl;
						mm_free(read_register(4));
						break;}
					case 4122:{cout << "Uname at time:" << CLOCK_COUNTER << endl;
#ifndef USE_MODERN_GLIBC
						sm_uname(read_register(29));
#else
						sm_uname_ex(read_register(4));
#endif
						write_register(2,0);
					break;}
					case 4132:{cout << "Getpid at time:" << CLOCK_COUNTER << endl;write_register(2,syscall(SYS_getpgid));break;}		//getpgid
					//4246 (Exit/IO Destroy) is handled by 4001
					case 4555:{cout << "Malloc at time:" << CLOCK_COUNTER << endl;
						int size = read_register(4);
						if(size < 32){size = 32;}
						uint32_t ans = mm_malloc(size);
						cout << "MMap: " << num2Str(ans) << endl;
						cout << dec;
						write_register(2,ans);
					break;}
/*
 * Original LL/SC implementation used syscalls since the verilog couldn't
 *      handle that. This is no longer true.
 * (Some verilog can handle LL/SC; also we can rewrite the methods that needed
 *      LL/SC.
 *
 *      This code actually prompted some very hellish on-the-fly code
 *      rewriting in the sim_main instruction fetch to replace the LL and SC
 *      calls with SYSCALLs. Such code was probably not very robust for LL
 *      and SC instances near cache line boundaries.
 *
 *      LL and SC are only used in two functions of GLIBC, and those functions
 *      are replaced with versions that don't use LL or SC.
 *
 *      On a proper MIPS Linux system that doesn't include the LL and SC
 *      instructions, the processor would throw an illegal instruction
 *      exception. The Linux kernel provides an exception handler that
 *      emulates the instructions.
 *      )
 */
/*
				case 4556:{cout << "LL at time:" << CLOCK_COUNTER << endl;
				//duration = 0;
							instruction = readWord(top->v->Instr_address_2IM);
							source = (instruction << 12)>>28;
							immediate = (instruction << 16)>>16;
							base = (instruction << 6)>>26;
							write_register(2,readWord(read_register(4)+immediate));
							break;}
					case 4557:{cout << "SC at time:" << CLOCK_COUNTER << endl;
					//duration = 0;
							instruction = readWord(top->v->Instr_address_2IM);
							base = (instruction << 6)>>26;
							immediate = (instruction << 16)>>16;
							if(SWC_tmp==0x83)rt = 3;
							else  if(SWC_tmp==0x82)rt = 2;
							writeWord(read_register(4)+immediate,read_register(rt));
							if(MAIN_MEMORY[top->v->Instr_address_2IM+1] == 0x82)write_register(2,1);
							else if(MAIN_MEMORY[top->v->Instr_address_2IM+1] == 0x83)write_register(3,1);
					break;}
*/
					default: { cout << "Sorry, syscall " << syscallIndex << " has not been implemented. Process terminated at cycle " << MAINTIME/2 << "..." << endl; return 0; }
				}
			} else {
				//Handle bulk cache writes on negedge of clk to allow fast cache response.
				if(top->dBlkWrite) {
					int i;
					for(i=0;i<8;i++) {
						writeWord(top->data_address_2DM + (i*4), top->block_write_2DM[7-i]);
					}
					top->block_write_fDM_valid = 1;
/*
	#ifdef DEBUG_CACHE
					cachewrite << "WriteLine to: " << num2Str(top->data_address_2DM) << "\tcycle " << ((uint32_t)CLOCK_COUNTER) << endl;
	#endif
*/
				} else {top->block_write_fDM_valid = 0;}
			}

			//prevents next instruction traversal until user input (any key pressed)
			if(CLOCK_COUNTER >= duration) {
				string input;
				std::getline (std::cin,input);
				if(SINGLE_STEP_QUIT || input == "exit" || input == "q") {
					stdoutFile.close();
					stderrFile.close();
#ifdef SUPPORT_VCD
	tfp->close();
#endif
#ifdef DEBUG_CACHE
					cachewrite.close();
#endif
					exit(42);
				}
				if(input.length()!=0){
					BREAKPOINT = strtol(input.c_str(), NULL, 0);
					duration = 1000000;
				}
			}
		}
		top->eval();							//assert c++ to verilog modules
	}
}
