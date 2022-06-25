.eqv 	print_int	1
.eqv	print_string	4
.eqv	program_exit	10	

	.data
	
test:	.asciz "7*8=56"
source:	.asciz "Source> "
result: .asciz "\nResult> "
return: .asciz "\nReturn value: "

	.text
	
main:
	li a7, print_string
	la a0, source
	ecall
	
	la a0, test
	ecall
	
	la a0, result
	ecall
	
	la a0, test
	jal remove
	
	mv a1, a0
	la a0, test
	ecall
	
	la a0, return
	ecall
	
	mv a0, a1
	li a7, print_int
	ecall
	
	
exit:	
	li a7, program_exit
	ecall


remove:
	mv t1, a0
	mv t2, a0
	li t5, '0'
	li t6, '9'
	
remove_loop:
	addi t1, t1, 1
	lbu t3, -1(t1)
	blt t3, t5, not_number
	bge t3, t6, remove_loop
	sb t3, (t2)
	addi t2, t2, 1
	
not_number:
	bnez t3, remove_loop
	
remove_exit:
	sb t3, (t2)
	sub a0, t2, a0
	jr ra