.text
.global __start
__start:
.align 5
addiu $0, $0, 0xdead
.align 5
j CONTINUE1
FAILED_jump_miss:
li $v0, 4020
syscall
move $a0, $v0
li $a1, 9
li $v0, 4037
syscall
CONTINUE1:
.align 5
addiu $0, $0, 0xdead
.align 4
nop
nop
nop
j CONTINUE2
FAILED_delay_slot_miss:
li $v0, 4020
syscall
move $a0, $v0
li $a1, 9
li $v0, 4037
syscall
CONTINUE2:
li $v0, 4001
syscall

