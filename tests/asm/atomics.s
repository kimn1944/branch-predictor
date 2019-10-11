.text
.set noreorder
.global __start
__start:
li $v0, 4001
syscall
_ZN9__gnu_cxx18__exchange_and_addEPVii:
lw $2, 0($4)
nop
addu $3, $5, $2
sw $3, 0($4)
jr $ra
addiu $3, $0, 1
_ZN9__gnu_cxx12__atomic_addEPVii:
lw $2, 0($4)
nop
addu $2, $5, $2
sw $2, 0($4)
jr $ra
addiu $2, $0, 1
