.set noat
.text
.global __start
.global main
__start:
main:
la $31, cont1
jr $31
failed1:
j failed1
cont1:
LUI $31, 0xffff
ADDI $1, $0, 1
ADD $2, $1, $1
ADD $4, $2, $2
ADD $6, $2, $4
ADD $8, $6, $2
ADD $9, $8, $1
beq $9, $9, done
failed: j failed
done: j done
