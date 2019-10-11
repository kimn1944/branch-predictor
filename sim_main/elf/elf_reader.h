/*
 * elf_reader.h
 *
 *  Created on: Jul 28, 2014
 *      Author: irichter
 */

#ifndef ELF_READER_H_
#define ELF_READER_H_

#include <vector>
#include <map>
#include <string>

typedef struct Exe_Segment {
	uint32_t offsetInFile; /* Offset of segment in executable file */
	uint32_t lengthInFile; /* Length of segment data in executable file */
	uint32_t startAddress; /* Start address of segment in user memory */
	uint32_t sizeInMemory; /* Size of segment in memory */
	int protFlags; /* VM protection flags; combination of VM_READ,VM_WRITE,VM_EXEC */
	uint32_t type;
} Exe_Segment;

typedef struct Exe_Format {
	std::vector<struct Exe_Segment> segmentList; /* Definition of segments */
	int numSegments; /* Number of segments contained in the executable */
	uint32_t entryAddr; /* Code entry point address */
	uint32_t globalPointer; /* initial value for global pointer (register 28) */
	uint32_t maxUsedAddr; /* maximum address allocated (relevant for bss,sbss so we know where to start the heap) */
	std::map< std::string, unsigned int*> function_pointers;
} Exe_Format;

extern int parse_elf(const char * elf_data, size_t elf_length, Exe_Format &exeFormat);


#endif /* ELF_READER_H_ */
