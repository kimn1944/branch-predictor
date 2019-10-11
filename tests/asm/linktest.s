#.set noat
.text
.global __start
.global main
.global sub1
__start:
main:
jal sub1
la $2, sub2
jalr $2
nop
j end

sub1:
addi $4, $0, 4
jr $ra

sub2:
addi $8, $0, 8
jr $ra

end: li $v0, 4001
syscall
