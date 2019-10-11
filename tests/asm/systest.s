.text
.global __start
__start:
addi $2, $0, 4020	#getpid
syscall
addi $2, $0, 4132	#getpid
syscall
addi $2, $0, 4024	#getuid
syscall
addi $2, $0, 4047	#getgid
syscall
addi $2, $0, 4049	#geteuid
syscall
addi $2, $0, 4050	#getegid
syscall
addi $2, $0, 4064	#getppid
syscall
addi $2, $0, 4065	#getpgrp
syscall
addi $2, $0, 4076	#getrlimit
syscall
addi $2, $0, 4077	#getrusage
syscall
addi $2, $0, 4078	#getTimeofDay
syscall
addi $2, $0, 4122	#uname
syscall
addi $2, $0, 4001	#exit	#also 4246
syscall
fail: j fail

