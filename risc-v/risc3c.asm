.eqv	print_int	1
.eqv 	print_string	4
.eqv 	read_string	8
.eqv	terminate_program	10
.eqv 	print_char	11
.eqv	INPUT_SIZE	80
.eqv	ZERO		48 	# '0' ascii code
.eqv	SPACE		32	# ' ' ascii code

	.data
input:	.space INPUT_SIZE
prompt:	.asciz "\nInput string       > "
msg1:	.asciz "\nConversion results > "
test:	.asciz "flip flop and fly"

	.text

main:

# display the input prompt
#    li a7, print_string		# system call for print_string
#    la a0, prompt		# address of string 
#    ecall

# read the input string
#    li a7, read_string	# system call for read_string
#    li a1, INPUT_SIZE	# max length
#    la a0, input	# address of buffer    
#    ecall

    li a7, print_string		# system call for print_string
    la a0, test		# address of string 
    ecall	

# string modification
    la a0, test
    jal modify_string_start

# display the output prompt and the string
    li a7, print_string		# system call for print_string
    la a0, msg1			# address of string 
    ecall
    li a7, print_string		# system call for print_string
    la a0, test		# address of string 
    ecall

exit:	
    li 	a7, terminate_program	# Terminate the program
    ecall
    
    
modify_string_start:
	mv t0, zero	# word length counter
	mv t1, a0	# input read pointer
	mv t2, a0	# input write pointer
	li t5, 10
	li t6, SPACE	# space register for comparision purposes
	
	
modify_string:
	lbu t3, (t1)
	addi t0, t0, 1
	addi t1, t1, 1
	beqz t3, print_digits_start
	beq t3, t6, print_digits_start
	b modify_string
	
print_digits_start:
	addi t0, t0, -1
	mv t4, t0
	
modulo:
	bltu t4, t5, print_digits
	addi t4, t4, -10
	b modulo
	
	
print_digits:
	addi t4, t4, ZERO
	
print_digits_loop:
	addi t2, t2, 1
	addi t0, t0, -1
	sb t4, -1(t2)
	bnez t0, print_digits_loop
	beqz t3, modify_string_exit
	addi t2, t2, 1
	li t4, SPACE
	sb t4, -1(t2)
	b modify_string
	
	
modify_string_exit:
	mv t4, zero
	sb t4, (t2)
	jr ra
