.set noat
.text
.global __start
.global main
__start:
main:
li $0, 0xdead
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
li $1, 0x5678abcd
li $2, 0x1234fedc
add $0, $1, $2
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
li $1, 0xcafebabe
mtlo $1
mflo $0
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
li $1, 0xdeadbeef
mthi $1
mfhi $0

