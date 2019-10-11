.text
.global __start
__start:
addi $2, $0, 4001
nop
syscall
fail: j fail

