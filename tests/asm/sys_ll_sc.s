.text
.global __start
.set noreorder
__start:

#$9 = malloc(0x10)
li $4, 0x10
addiu $2, $0, 4555	#Malloc
syscall
addu $9, $2, $0

#*($9) = 0xcafebabe
li $5, 0xcafebabe
sw $5, 0($9)
sw $5, 4($9)

li $6, 0xf00dcafe
lw $6, 0($0)
nop
bnez $6, failMEMB
nop

lwc0 $10, 4($9)
beqz $10, failLL
nop
addiu $10, $10, 1
swc0 $10, 4($9)
beqz $10, failSC1
nop
bne $10, 1, failSC11
nop

lwc0 $11, 0($9)
swc0 $11, 8($9)
bnez $11, failSC2
nop
nop
#nop

pass:
j pass
nop
nop
nop

failLL: 
j failLL
nop
nop
nop

failSC1: 
j failSC1
nop
nop
nop

failSC11:
j failSC11
nop
nop
nop

failSC2:
j failSC2
nop
nop
nop

failMEMB:
j failMEMB
nop
nop
nop


