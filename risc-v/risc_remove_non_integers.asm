.eqv	print_int	1
.eqv 	print_string	4
.eqv	terminate_program	10
.eqv 	print_char	11
	

	.data
test: .asciz "7*8=56"
ans:	.space 100
	.text
main:
	li a7, print_string	#system call for print_string
	la a0, test	#address of string 
	ecall
	
	li a0, '\n'
	li a7, print_char
	ecall
	
	la a0, test
	jal modify_string
	
	li a7, print_string	#system call for print_string
	ecall
	
	li a0, '\n'
	li a7, print_char
	ecall
	
	li a7, print_int
	mv a0, a1
	ecall
	
exit:	
    li 	a7, terminate_program	#Terminate the program
    ecall

modify_string:
	mv t0, zero	# string length
	mv t1, a0	# read pointer
	mv t2, a0	# write pointer
	li t5, '0'
	li t6, '9'
	
	
modify_main:
	addi t1, t1, 1
	lbu t3, -1(t1)
	beqz t3, modify_string_exit
	blt t3, t5, not_number
	bge t3, t6, not_number
	addi t0, t0, 1

number:
	sb t3, (t2)
	addi t2, t2, 1

not_number:
	b modify_main

modify_string_exit:
	sb t3, (t2)
	mv a1, t0
	jr ra


