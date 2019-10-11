#ifndef SM_HEAP_H
#define SM_HEAP_H


// heap functions
void heapDump();
uint32_t mm_malloc(uint32_t size);
void mm_free(uint32_t addr);

extern uint32_t mm_sbrk(int32_t value);

#endif
