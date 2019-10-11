.set noat
.set noreorder
.text
.global __start
.global main
__start:
main:
ADDI $1, $0, 1
ADD $2, $1, $1
ADD $4, $2, $2
ADD $6, $2, $4
ADD $8, $6, $2
SUB $5, $6, $1
SUB $3, $4, $1
MULT $3, $3
MFLO $9

XOR $2,$1,$1
XOR $3,$1,$1
XOR $4,$1,$1
XOR $5,$1,$1
XOR $6,$1,$1
XOR $7,$1,$1
XOR $9,$1,$1


SLL $4, $1, 2
SRL $2, $4, 1

XOR $1,$1,$1
XOR $2,$1,$1
XOR $4,$1,$1

ADDI $3, $0, 3
ADDI $19, $0, 19
DIV $0, $19, $3
MFLO $6
MFHI $1
