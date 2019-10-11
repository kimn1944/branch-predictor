.set noat
.text
.global __start
.global main
__start:
main:
ADDI $3, $0, 3
MULT $3, $3
MFLO $9

ADDI $2, $0, 2
MULT $2, $2
MFLO $4

ADDI $3, $0, 3
ADDI $19, $0, 19
DIV $0, $19, $3
MFLO $6
MFHI $1

MTHI $3
MTLO $4
ADDI $3, $0, 0
ADDI $4, $0, 0
MFLO $4
MFHI $3
