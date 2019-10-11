/*
 * superscalar.s
 *
 *  Created on: Aug 4, 2014
 *      Author: irichter
 */
.set noat
.set noreorder
.data
data1: 		.word	0xdeadbeef
data2: 		.word	0xcafebabe
data3: 		.word	0xf00dfeed
number11:	.word	11
number12:	.word	12
number13:	.word	13
.text
.global __start
.global main
__start:
main:
addi $1, $0, 1	/*cycle 1*/
addi $2, $0, 2	/*cycle 1*/
addi $3, $0, 3	/*cycle 2*/
add $4, $3, $1	/*cycle 3 (gets postponed)*/
nop				/*cycle 3*/
nop				/*cycle 4*/
nop				/*cycle 4*/
add $6, $3, $3	/*cycle 5*/
add $5, $2, $3	/*cycle 5*/
add $7, $2, $5	/*cycle 6 (no postponement)*/
lui $28, 0x100	/*cycle 6*/
add $8, $5, $3	/*cycle 7*/
lw $11, 0($28)	/*cycle 7 (no postponement)*/
lw $12, 12($28)	/*cycle 9*/
nop				/*cycle 9*/
add $11, $12, $0/*cycle 11 (needs to wait for delay slot)*/
lw $13, 20($28)	/*cycle 11*/
lw $12, 16($28) /*cycle 12*/




