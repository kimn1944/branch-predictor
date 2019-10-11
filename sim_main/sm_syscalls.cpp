#include "sm_syscalls.h"
#include "sm_memory.h"
#include <string>
#include <iostream>
#include <fstream>
#include <vector>
#include <stdlib.h>

#include <sys/utsname.h>
#include <stddef.h>

struct syscall_addresses syscalls; 

using namespace std;

bool EMULATE_LLSC = 1;

uint32_t hex_str_to_uint32(std::string str) {
	return (uint32_t)strtol(str.c_str(),NULL, 16);
}

void init_syscalls() {
	syscalls.CFREE_ADDRESS = 0xFFFFFFF0;
	syscalls.EXIT_ADDRESS = 0xFFFFFFF0;
	syscalls.FXSTAT64_ADDRESS = 0xFFFFFFF0;
	syscalls.GETEGID_ADDRESS = 0xFFFFFFF0;
	syscalls.GETEUID_ADDRESS = 0xFFFFFFF0;
	syscalls.GETGID_ADDRESS = 0xFFFFFFF0;
	syscalls.GETPID_ADDRESS = 0xFFFFFFF0;
	syscalls.GETUID_ADDRESS = 0xFFFFFFF0;
	syscalls.LIBC_MALLOC_ADDRESS = 0xFFFFFFF0;
	syscalls.LIBC_OPEN_ADDRESS = 0xFFFFFFF0;
	syscalls.LIBC_READ_ADDRESS = 0xFFFFFFF0;
	syscalls.LIBC_WRITE_ADDRESS = 0xFFFFFFF0;
	syscalls.MMAP_ADDRESS = 0xFFFFFFF0;
	syscalls.MUNMAP_ADDRESS = 0xFFFFFFF0;
	syscalls.UNAME_ADDRESS = 0xFFFFFFF0;
	syscalls.CXX_EX_AND_ADD_ADDRESS = 0xFFFFFFE0;
	syscalls.CXX_ATOMIC_ADD_ADDRESS = 0xFFFFFFE0;
}

void fill_syscall(uint32_t address, uint16_t call) {
	printf("Writing syscall %hd at address %x\n", call, address);
	writeWord(address + 0x0, 0x24020000 | call);	//li $2, call
	writeWord(address + 0x4, 0xc);					//syscall
	writeWord(address + 0x8, 0x03e00008);			//jr $31
	writeWord(address + 0xc, 0x0);					//nop
}

void fill_ex_and_add(uint32_t address) {
	printf("Writing Exchange and Add at address %x\n", address);
	writeWord(address + 0x00, 0x8c820000);	//lw	v0,0(a0)
	writeWord(address + 0x04, 0x00000000);	//nop
	writeWord(address + 0x08, 0x00a21821);	//addu	v1,a1,v0
	writeWord(address + 0x0c, 0xac830000);	//sw	v1,0(a0)
	writeWord(address + 0x10, 0x03e00008);	//jr	ra
	writeWord(address + 0x14, 0x24030001);	//li	v1,1
}

void fill_atomic_add(uint32_t address) {
	printf("Writing Atomic Add at address %x\n", address);
	writeWord(address + 0x00, 0x8c820000);	//lw	v0,0(a0)
	writeWord(address + 0x04, 0x00000000);	//nop
	writeWord(address + 0x08, 0x00a21021);	//addu	v1,a1,v0
	writeWord(address + 0x0c, 0xac820000);	//sw	v1,0(a0)
	writeWord(address + 0x10, 0x03e00008);	//jr	ra
	writeWord(address + 0x14, 0x24020001);	//li	v0,1
}

void fill_syscall_redirects() {
	fill_syscall(syscalls.CFREE_ADDRESS, 4091);
	fill_syscall(syscalls.EXIT_ADDRESS, 4001);
	fill_syscall(syscalls.FXSTAT64_ADDRESS, 4028);
	fill_syscall(syscalls.LIBC_MALLOC_ADDRESS, 4555);
	fill_syscall(syscalls.LIBC_OPEN_ADDRESS, 4005);
	fill_syscall(syscalls.LIBC_READ_ADDRESS, 4003);
	fill_syscall(syscalls.LIBC_WRITE_ADDRESS, 4004);
	fill_syscall(syscalls.MMAP_ADDRESS, 4090);
	fill_syscall(syscalls.MUNMAP_ADDRESS, 4091);
	fill_syscall(syscalls.UNAME_ADDRESS, 4122);
	if(EMULATE_LLSC) {
		fill_ex_and_add(syscalls.CXX_EX_AND_ADD_ADDRESS);
		fill_atomic_add(syscalls.CXX_ATOMIC_ADD_ADDRESS);
	}
}

//BYPASSES NATIVE FUNCTIONS BY DETERMINING MEMORY LOCATION IN OBJDUMP OF EACH FUNCTION CALL
void functionBypass(std::string str){
	ifstream readFile1( str.c_str() );					//open the elf header file
	string word;								//variable for streaming file
	int flag = 0;								//prevents multiple tag detection
	vector<string> words;							
	if ( !readFile1 ) cerr << "File couldn't be opened" << endl;		//error if the file doesn't exist
	if (readFile1.is_open()) { 						//traverse file
		while (!readFile1.eof() ) { 						//until the end of the file is reached...
			getline (readFile1,word);						//look for tag names and store them if found
			if ( flag == 1 ) flag = 0;
			if( word.find("getgid")!=string::npos){ syscalls.GETGID_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("getegid")!=string::npos){ syscalls.GETEGID_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("getpid")!=string::npos){ syscalls.GETPID_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("geteuid")!=string::npos){ syscalls.GETEUID_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("uname")!=string::npos){ syscalls.UNAME_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("getuid")!=string::npos){ syscalls.GETUID_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<__libc_malloc>")!=string::npos){ syscalls.LIBC_MALLOC_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<__cfree>")!=string::npos){ syscalls.CFREE_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<___fxstat64>")!=string::npos){ syscalls.FXSTAT64_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<__mmap>")!=string::npos){ syscalls.MMAP_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<__libc_write>")!=string::npos){ syscalls.LIBC_WRITE_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<__munmap>")!=string::npos){ syscalls.MUNMAP_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<_exit>")!=string::npos){ syscalls.EXIT_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<__libc_read>")!=string::npos){ syscalls.LIBC_READ_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<__libc_open>")!=string::npos){ syscalls.LIBC_OPEN_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			//else if( word.find("<__libc_close>")!=string::npos){ syscalls.LIBC_CLOSE_ADDRESS=word.substr(0,8); flag = 1;}
			else if( word.find("<_ZN9__gnu_cxx18__exchange_and_addEPVii>:")!=string::npos) { syscalls.CXX_EX_AND_ADD_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
			else if( word.find("<_ZN9__gnu_cxx12__atomic_addEPVii>:")!=string::npos) { syscalls.CXX_ATOMIC_ADD_ADDRESS=hex_str_to_uint32(word.substr(0,8)); flag = 1;}
		}
	}
	readFile1.close();
}

// implementation of fxstat64 system call
// who knows what it's loading into memory?
// Not Joe.
void fxstat64(int sp)
{
	memLog("fxstat64 "+num2Str((uint32_t)sp));
	loadSingleHEX("00000009",sp +32,0,0);
	loadSingleHEX("00000000",sp +48,0,0);
	loadSingleHEX("00000002",sp +52,0,0);
	loadSingleHEX("00002190",sp +56,0,0);
	loadSingleHEX("00000001",sp +60,0,0);
	loadSingleHEX("00001fb3",sp +64,0,0);
	loadSingleHEX("00000005",sp +68,0,0);
	loadSingleHEX("00008800",sp +72,0,0);
	loadSingleHEX("00000000",sp +88,0,0);
	loadSingleHEX("00000000",sp +92,0,0);
	loadSingleHEX("00000400",sp +120,0,0);
	loadSingleHEX("00000000",sp +128,0,0);
	loadSingleHEX("00000000",sp +132,0,0);	
}

#ifndef NOOP_LOOP
#define NOOP_LOOP	7
#endif
#ifdef NO_NOOP
#undef NOOP_LOOP
#define NOOP_LOOP	0
#endif
void write_instruction(uint32_t *address, uint32_t instruction) {
	writeWord(*address, instruction);
	printf("Writing 0x%08x to 0x%08x", instruction, *address);
	(*address)+=4;
	int i;
	for(i = 0; i < NOOP_LOOP; i++) {
		writeWord(*address, 0x0);
//		printf(";nop@0x%08x", *address);
		(*address)+=4;
	}
	printf("\n");
}

void write_load_immediate(uint32_t *address, uint32_t regno, uint32_t value) {
/*
	printf("write_load_immediate(0x%08x, %u, 0x%08x)\n", *address, regno, value);
	printf("Instr_base: 0x%08x\n", 0x3C000000);
	printf("Instr_regno: 0x%08x\n", (regno << 16));
	printf("upper_value = 0x%04x\n", ((value >> 16) & 0xFFFF));
*/
	write_instruction(address, 0x3C000000 |
			(regno << 16) |
			((value >> 16) & 0xFFFF));
/*
	printf("Instr_base: 0x%08x\n", 0x34000000);
	printf("Instr_regno: 0x%08x\n", (regno << 21));
	printf("Instr_regno: 0x%08x\n", (regno << 16));
	printf("lower_value = 0x%04x\n", (value & 0xFFFF));
*/
	write_instruction(address, 0x34000000 |
			(regno << 21) |
			(regno << 16) |
			(value & 0xFFFF));
}

void write_initialization_vector(uint32_t sp, uint32_t gp, uint32_t start) {
	printf("Initializing sp=0x%08x; gp=0x%08x; start=0x%08x\n", sp, gp, start);
	uint32_t current_address = 0xBFC00000;
	write_load_immediate(&current_address, 29, sp);
	if(gp != 0xFFFFFFFF) {
		write_load_immediate(&current_address, 28, gp);
	}
	write_load_immediate(&current_address, 31, start);
	write_instruction(&current_address, 0x3E00008);	//jr ra
	write_instruction(&current_address, 0x0);	//nop [branch delay]
}

void copy_string_to_sim(uint32_t base_addr, const char * str) {
	while(*str) {
		writeByte(base_addr, *str);
		str++;
		base_addr++;
	}
	writeByte(base_addr, '\0');
}

#ifdef USE_MODERN_GLIBC
//
//Needed only for modern glibc -- we're using an ancient one
//
#define _UTSNAME_LENGTH	65
void sm_uname_ex(uint32_t addr) {
	printf("running sm_uname version 2\n");
	printf("offset of release=0x%08x\n", offsetof(struct utsname, release));
	copy_string_to_sim(addr + offsetof(struct utsname, sysname), "DanSnyderLinux");
	copy_string_to_sim(addr + offsetof(struct utsname, nodename), "VMIPS");
	copy_string_to_sim(addr + offsetof(struct utsname, release), "2.6.16");
	copy_string_to_sim(addr + offsetof(struct utsname, version), "5");
	copy_string_to_sim(addr + offsetof(struct utsname, machine), "ECE 401 Simulator");
}
#else

// uname syscall implementation (for 2.4 kernel)
void sm_uname(int sp){
	/*insert into stack...
		"SescLinux"
		"sesc"
		"2.4.18"
		"#1 SMP Tue Jun 4 16:05:29 CDT 2002"
		"mips"*/
	printf("running sm_uname\n");
	
memLog("uname "+ num2Str((uint32_t)sp));

	/*writeWord(sp +348,0x6d697073);
	writeWord(sp +316,0x32000000);
	writeWord(sp +312,0x20323030);
	writeWord(sp +308,0x20434454);
	writeWord(sp +304,0x353a3239);
	writeWord(sp +300,0x31363a30);
	writeWord(sp +296,0x6e203420);
	writeWord(sp +292,0x65204a75);
	writeWord(sp +288,0x50205475);
	writeWord(sp +284,0x3120534d);
	writeWord(sp +280,0x00000023);
	writeWord(sp +220,0x342e3138);
	writeWord(sp +216,0x0000322e);
	writeWord(sp +156,0x63000000);
	writeWord(sp +152,0x00736573);
	writeWord(sp +96,0x78000000);
	writeWord(sp +92,0x4c696e75);
	writeWord(sp +88,0x53657363);*/

	loadSingleHEX("6d697073",sp +348,0,0);
	loadSingleHEX("32000000",sp +316,0,0);
	loadSingleHEX("20323030",sp +312,0,0);
	loadSingleHEX("20434454",sp +308,0,0);
	loadSingleHEX("353a3239",sp +304,0,0);
	loadSingleHEX("31363a30",sp +300,0,0);
	loadSingleHEX("6e203420",sp +296,0,0);
	loadSingleHEX("65204a75",sp +292,0,0);
	loadSingleHEX("50205475",sp +288,0,0);
	loadSingleHEX("3120534d",sp +284,0,0);
	loadSingleHEX("00000023",sp +280,0,0);
	loadSingleHEX("342e3138",sp +220,0,0);
	loadSingleHEX("0000322e",sp +216,0,0);
	loadSingleHEX("63000000",sp +156,0,0);
	loadSingleHEX("00736573",sp +152,0,0);
	loadSingleHEX("78000000",sp +96,0,0); 
	loadSingleHEX("4c696e75",sp +92,0,0);
	loadSingleHEX("53657363",sp +88,0,0);
	printf("exiting sm_uname\n");

}
#endif
