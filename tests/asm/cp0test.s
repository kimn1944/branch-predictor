.data
value1:	.word	0xdeadbeef
value2: .word	0x0
.text
.global __start
__start:
lui $20, 0x41
ori $20, 0x100
addi $21, $20, 4
lw $9, 0($20)
lwc0 $5, 0($20)
swc0 $5, 0($21)
lw $6, ($21)

