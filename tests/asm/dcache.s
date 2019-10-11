.text
.global __start
__start:
li $t0, 0x00010203
li $t1, 0x04050607
li $t2, 0x08090a0b
li $t3, 0x0c0d0e0f
li $t4, 0x10111213
li $t5, 0x14151617
li $t6, 0x18191a1b
li $t7, 0x1c1d1e1f
move $v0, $0
sw $t0, 0($v0)
sw $t2, 8($v0)
sw $t7, 0x1c($v0)
nop
nop
nop
addiu $v0, $0, 0x20
sw $t0, 0x00($v0)
sw $t1, 0x04($v0)
sw $t2, 0x08($v0)
sw $t3, 0x0c($v0)
sw $t4, 0x10($v0)
sw $t5, 0x14($v0)
sw $t6, 0x18($v0)
sw $t7, 0x1c($v0)
nop
nop
nop
addu $t0, $t0, 0x40000000
addu $t1, $t1, 0x40000000
addu $t2, $t2, 0x40000000
addu $t3, $t3, 0x40000000
addu $t4, $t4, 0x40000000
addu $t5, $t5, 0x40000000
addu $t6, $t6, 0x40000000
addu $t7, $t7, 0x40000000
addu $v0, $0, 0x4000
sw $t0, 0x00($v0)
sw $t1, 0x04($v0)
sw $t2, 0x08($v0)
sw $t3, 0x0c($v0)
sw $t4, 0x10($v0)
sw $t5, 0x14($v0)
sw $t6, 0x18($v0)
sw $t7, 0x1c($v0)
nop
nop
nop
addu $t0, $t0, 0x10000000
addu $t1, $t1, 0x10000000
addu $t2, $t2, 0x10000000
addu $t3, $t3, 0x10000000
addu $t4, $t4, 0x10000000
addu $t5, $t5, 0x10000000
addu $t6, $t6, 0x10000000
addu $t7, $t7, 0x10000000
addu $v0, $v0, 0x4000
sw $t0, 0x00($v0)
sw $t1, 0x04($v0)
sw $t2, 0x08($v0)
sw $t3, 0x0c($v0)
sw $t4, 0x10($v0)
sw $t5, 0x14($v0)
sw $t6, 0x18($v0)
sw $t7, 0x1c($v0)
nop
nop
nop
move $v1, $v0
li $v0, 4001
sw $t0, 0x20($v1)
syscall


