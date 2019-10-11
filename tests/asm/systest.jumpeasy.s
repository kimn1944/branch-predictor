.set noreorder
#.data
#place1_location: .word place1 #0x4000f0
.text
.align 5
nop
.align 4
nop
.align 3
.global __start
__start:
bal next
nop
.align 5
next:
addi $31, $31, (place1 - next)
addi $2, $0, 4020	#getpid
syscall
jr $31
nop
addi $2, $0, 0
syscall
.align 5
place1:
addi $2, $0, 4001
syscall
