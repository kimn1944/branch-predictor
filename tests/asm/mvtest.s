.set noat
.set noreorder
.text
.global __start
.global main
__start:

main:
ADD $3, $0, 3
lui $21, 0x40
ori $21, $21, 0xf0
beq $3, $4, success
nop
nop
nop
nop
nop
nop 
ADD $4, $0, 4
move $25, $21
jalr $25
move $22, $4

fail: j fail
nop

success: j success
nop

