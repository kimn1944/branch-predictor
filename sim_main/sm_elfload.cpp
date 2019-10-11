//#include <string.h>
//#include "sm_txtload.h"

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#include "sm_memory.h"
#include "sm_heap.h"
#include "sm_syscalls.h"
#include "sm_execinfo.h"

#include "elf/elf_reader.h"

#include <iostream>

using namespace std;


//void getSegmentOffsets(){
//	void init_syscalls();
//	/*
//	syscalls.GETGID_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.GETPID_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.GETEUID_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.UNAME_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.LIBC_MALLOC_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.CFREE_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.FXSTAT64_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.MMAP_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.LIBC_WRITE_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.MUNMAP_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.EXIT_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.LIBC_READ_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		syscalls.LIBC_OPEN_ADDRESS="zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
//		*/
//}

int LoadOSMemoryELF (const char * FILE_ARG){
	int elf_fd;
	char * elf_data;
	// read ELF into buffer

	elf_fd = open(FILE_ARG, 0);
	if (elf_fd == -1) {
		return -1;
	}
	struct stat file_stat;
	if (lstat(FILE_ARG, &file_stat)) {
		close(elf_fd);
		return -2;
	}
	elf_data = (char*)mmap(NULL, file_stat.st_size, PROT_READ,
	MAP_PRIVATE, elf_fd, 0);
	if (elf_data == MAP_FAILED) {
		close(elf_fd);
		return -3;
	}
	Exe_Format exeFormat;
/*
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
 */
	init_syscalls();
//	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__getgid"), &syscalls.GETGID_ADDRESS));
//	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__getegid"), &syscalls.GETEGID_ADDRESS));
//	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__getpid"), &syscalls.GETPID_ADDRESS));
//	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__geteuid"), &syscalls.GETEUID_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__uname"), &syscalls.UNAME_ADDRESS));
//	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__getuid"), &syscalls.GETUID_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__libc_malloc"), &syscalls.LIBC_MALLOC_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__cfree"), &syscalls.CFREE_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__fxstat64"), &syscalls.FXSTAT64_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__mmap"), &syscalls.MMAP_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__libc_write"), &syscalls.LIBC_WRITE_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__munmap"), &syscalls.LIBC_WRITE_ADDRESS));
//	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("_exit"), &syscalls.EXIT_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__libc_read"), &syscalls.LIBC_WRITE_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__libc_open"), &syscalls.LIBC_OPEN_ADDRESS));
//	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("__libc_close"), &syscalls.LIBC_CLOSE_ADDRESS));
#ifndef NO_EMULATE_LL_SC
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("_ZN9__gnu_cxx18__exchange_and_addEPVii"), &syscalls.CXX_EX_AND_ADD_ADDRESS));
	exeFormat.function_pointers.insert(std::pair<std::string, unsigned int*>(std::string("_ZN9__gnu_cxx12__atomic_addEPVii"), &syscalls.CXX_ATOMIC_ADD_ADDRESS));
#endif
	int rv = parse_elf(elf_data, file_stat.st_size, exeFormat);

	if(rv) {
		munmap(elf_data, file_stat.st_size);
		close(elf_fd);
		printf("\nERROR READING ELF!!!! (%d)\n", rv);
		return rv;
	}

	puts("\n-----ELF SUMMARY------\n");
	printf("Num segments %d\n",exeFormat.numSegments);
	printf("entry point %8x\n\n",exeFormat.entryAddr);

	// TODO: clean this
	// for each section
	int maxAddr = 0;
	for(int i =0; i<exeFormat.segmentList.size(); i++){
		// read section into memory
		// j = offset from start
	printf("Segment %d ---\n",i);
	printf("startaddr 0x%8x\n",exeFormat.segmentList[i].startAddress);
	printf("length %d\n",exeFormat.segmentList[i].lengthInFile);
	printf("type 0x%8x\n", exeFormat.segmentList[i].type);
		int j = 0;
		for(int j = 0; j<exeFormat.segmentList[i].lengthInFile; j++){
			MAIN_MEMORY[j+exeFormat.segmentList[i].startAddress]
				=elf_data[j+exeFormat.segmentList[i].offsetInFile];
		}
		if(j+exeFormat.segmentList[i].startAddress>maxAddr){
			maxAddr = j+exeFormat.segmentList[i].startAddress;
		}
#ifdef DUMP_ELF_LOADED_MEMORY
		cout<<mem2Str(exeFormat.segmentList[i].startAddress,exeFormat.segmentList[i].lengthInFile)<<endl<<endl;
#endif
	}

	munmap(elf_data, file_stat.st_size);
	close(elf_fd);

	// store exec offsets -----------------------
	exec.GPC_START = exeFormat.entryAddr;

	// set heap beyond the scope of our addressing, and align to a page.
	exec.BREAKSTART = 0x80000000;//(exeFormat.maxUsedAddr + ((exeFormat.maxUsedAddr & 0xFFF)?0x1000:0)) & ~0xFFF;
	exec.HEAPSTART = 0xC0000000;//0xEE036000;//exec.BREAKSTART + MAX_BREAK_SIZE;

	// not sure yet how to get these from ELF
	exec.GSP = 0xf7021fc0;//for noio
	exec.GRA = 0x1006a244;//for noio, but we don't really need it

	exec.GP = exeFormat.globalPointer;

//	// store syscalls
//	getSegmentOffsets();
	
	puts("\n-----FINISHED ELF LOAD------\n");
//	delete [] buffer;

	fill_syscall_redirects();
	return 0;
}











