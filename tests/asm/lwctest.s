.set noat
.text
.global __start
.global main
__start:
main:

LUI $25, 0xdeca
ori $1, $25, 0xde01
LUI $25, 0xcafe
ori $2, $25, 0xbabe

SWC0 $1, 0($0)
LW $5, 0($0)
SWC0 $2, 4($0)
LWC0 $3, 0($0)
LWC0 $4, 4($0)

bne $2, $4, fail_c1
nop
bne $1, $3, fail_c2
nop
bne $1, $5, fail_c3
nop
j all_done
nop

fail_c1:j fail_c1
fail_c2:j fail_c2
fail_c3:j fail_c3

all_done:
j all_done
