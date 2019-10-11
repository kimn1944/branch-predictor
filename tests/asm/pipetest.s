.set noat
.text
.global __start
.global main
__start:
main:
LUI $31, 0xffff
ADDI $1, $0, 1
ADD $2, $1, $1
ADD $4, $2, $2
ADD $6, $2, $4
ADD $8, $6, $2
sw $8, 0x10($0)
lw $9, 0x10($0)
nop
beq $8, $9, done
failed: j failed
done: j done
