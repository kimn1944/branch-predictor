/*
 * sm_regfile.h
 *
 *  Created on: Dec 9, 2013
 *      Author: isaac
 */

#ifndef SM_REGFILE_H_
#define SM_REGFILE_H_

#include <stdint.h>
#ifndef OOO
#include "VMIPS_RegFile.h"
#include "VMIPS_EXE.h"
#else
#include "VMIPS_PhysRegFile.h"
#include "VMIPS_RetireCommit.h"
#endif

#ifndef OOO
void init_register_access(VMIPS_RegFile *rf, VMIPS_EXE *exe);
#else
void init_register_access(VMIPS_PhysRegFile *prf, VMIPS_RetireCommit *rc);
#endif

uint32_t read_register(uint32_t regno);
uint32_t register_arch_to_phys(uint32_t regno);
void write_register(uint32_t regno, uint32_t value);



#endif /* SM_REGFILE_H_ */
