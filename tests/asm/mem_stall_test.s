.set noreorder
.text
.global __start
__start:
lw $t0, 0x100($0)
j CONTINUE1
nop
FAILED1:
li $v0, 4020
syscall
move $a0, $v0
li $a1, 9
li $v0, 4037
syscall
CONTINUE1:
lw $t1, 0x204($0)
nop
j CONTINUE2
nop
FAILED2:
li $v0, 4020
syscall
move $a0, $v0
li $a1, 9
li $v0, 4037
syscall
CONTINUE2:
lw $t1, 0x304($0)
nop
nop
j CONTINUE3
nop
FAILED3:
li $v0, 4020
syscall
move $a0, $v0
li $a1, 9
li $v0, 4037
syscall
CONTINUE3:
j CONTINUE4
lw $t1, 0x404($0)
FAILED4:
li $v0, 4020
syscall
move $a0, $v0
li $a1, 9
li $v0, 4037
syscall
CONTINUE4:
li $v0, 4001
syscall

