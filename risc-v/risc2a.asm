.eqv	print_int	1
.eqv 	print_string	4
.eqv	terminate_program	10
.eqv 	print_char	11

	.data
test1: .asciz "Wind On The Hill\n"
ans:	.space 100
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
	la a0, ans	#address of string 
	ecall
	
exit:	
    li 	a7, terminate_program	#Terminate the program
    ecall
	
modify_string:
	mv t0, zero
	la t1, ans
	
modify_string_loop:
	lbu t2, (a0)
	addi a0, a0, 1
	addi t0, t0, 1
	bnez t2, modify_string_loop
	addi a0, a0, -2
	addi t0, t0, -1
	mv t3, t0
	
modify_string_h:
	beqz t3, modify_string_exit
	addi t3, t3, -1
	addi t1, t1, 1
	lbu t2, (a0)
	sb t2, -1(t1)
	addi a0, a0, -1
	b modify_string_h	

modify_string_exit:
	mv a0, t0
	jr ra
