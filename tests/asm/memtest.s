.set noat
.text
.global __start
.global main
__start:
main:
ADD $1, $0, 0
LW  $3, 4($1)
LH  $4, 4($1)
LB  $5, 4($1)
LHU  $7, 4($1)
LBU  $8, 4($1)

nop
nop
lui $12, 0xdead
ori $12, $12, 0xbeef
sw $12, 0x10($0)
sb $12, 0x14($0)
sb $12, 0x19($0)
sb $12, 0x1e($0)
sb $12, 0x23($0)
sh $12, 0x24($0)
sh $12, 0x29($0)
sh $12, 0x2e($0)
sh $12, 0x33($0)
swl $12, 0x34($0)
swl $12, 0x39($0)
swl $12, 0x3e($0)
swl $12, 0x43($0)
swr $12, 0x44($0)
swr $12, 0x49($0)
swr $12, 0x4e($0)
swr $12, 0x53($0)
nop
nop
#now testing
lw $13, 0x10($0)
bne $12, $13, fail_sw

lui $14, 0xef00
lw $13, 0x14($0)
nop
bne $14, $13, fail_sb0

lw $13, 0x18($0)
srl $14, $14, 8
bne $14, $13, fail_sb1

lw $13, 0x1c($0)
srl $14, $14, 8
bne $14, $13, fail_sb2

lw $13, 0x20($0)
srl $14, $14, 8
bne $14, $13, fail_sb3

j all_done
fail_sw:j fail_sw
fail_sb0:j fail_sb0
fail_sb1:j fail_sb1
fail_sb2:j fail_sb2
fail_sb3:j fail_sb3

all_done:b
j all_done
