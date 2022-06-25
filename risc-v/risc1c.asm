.eqv	print_int	1
.eqv 	print_string	4
.eqv	terminate_program	10
.eqv 	print_char	11

	.data
test1: .asciz "tel. 12-34-55\n"

	.text
main:
	li a7, print_string	#system call for print_string
	la a0, test1	#address of string 
	ecall
	
	la a0, test1
	jal modify_string


	li a7, print_int
	ecall
	
	li a0, '\n'
	li a7, print_char
	ecall
	
	li a7, print_string	#system call for print_string
	la a0, test1	#address of string 
	ecall
	
exit:	
    li 	a7, terminate_program	#Terminate the program
    ecall
	
modify_string:
	mv t0, zero
	li t1, '0'
	li t2, '9'
	li t4, '*'
	
modify_string_loop:
	lbu t3, (a0)
	beqz t3, modify_string_exit
	addi a0, a0, 1
	bgt  t3, t2, modify_string_loop
	blt  t3, t1, modify_string_loop
	sb t4, -1(a0)
	addi t0, t0, 1
	b modify_string_loop
	
modify_string_exit:
	mv a0, t0
	jr ra
