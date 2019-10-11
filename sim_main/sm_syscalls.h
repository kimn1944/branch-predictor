#ifndef SM_SYSCALLS_H
#define SM_SYSCALLS_H

#include <string>
#include <stdint.h>

extern bool EMULATE_LLSC;

struct syscall_addresses {

	uint32_t LIBC_OPEN_ADDRESS;
	uint32_t LIBC_READ_ADDRESS;
	uint32_t EXIT_ADDRESS;
	uint32_t MUNMAP_ADDRESS;
	uint32_t GETEUID_ADDRESS;
	uint32_t GETUID_ADDRESS;
	uint32_t UNAME_ADDRESS;
	uint32_t GETPID_ADDRESS;
	uint32_t GETGID_ADDRESS;
	uint32_t GETEGID_ADDRESS;
	uint32_t LIBC_MALLOC_ADDRESS;
	uint32_t CFREE_ADDRESS;
	uint32_t FXSTAT64_ADDRESS;
	uint32_t MMAP_ADDRESS;
	uint32_t BRK_ADDRESS;
	uint32_t LIBC_WRITE_ADDRESS;
	uint32_t CXX_EX_AND_ADD_ADDRESS;
	uint32_t CXX_ATOMIC_ADD_ADDRESS;

};

extern struct syscall_addresses syscalls; 

extern void init_syscalls();
extern void fill_syscall_redirects();
extern void functionBypass(std::string str);
extern void write_instruction(uint32_t *address, uint32_t instruction);
extern void write_initialization_vector(uint32_t sp, uint32_t gp, uint32_t start);
extern void sm_uname_ex(uint32_t addr);
extern void sm_uname(int sp);
extern void fxstat64(int sp);

#endif
