.set noat
.set noreorder
#.section reginfo
#.word 0xffffffff
#.word 0x00000000
#.word 0x00000000
#.word 0x00000000
#.word 0x00000000
#.word 0x00000000
.data
repeat_location: .word repeat #0x4000e8
place1_location: .word place1 #0x4000f0
.text
.global __start
.global repeat
.global place1
__start:
add $1, $0, $0
lui $9, 0x41
lw $4, 0x110($9)
nop
lw $4, 0x114($9)
nop
repeat: 
jr $4
addi $1, $1, 1
nop
place1:
addi $9,$0,42
nop
end:b
j end
nop
