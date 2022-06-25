.eqv	print_int	1
.eqv 	print_string	4
.eqv 	read_string	8
.eqv	terminate_program	10
.eqv 	print_char	11
.eqv	INPUT_SIZE	80

	.data
input:	.space INPUT_SIZE
prompt:	.asciz "\nInput string       > "
msg1:	.asciz "\nConversion results > "

	.text

main:

# display the input prompt
    li a7, print_string		# system call for print_string
    la a0, prompt	# address of string 
    ecall

# read the input string
    li a7, read_string	# system call for read_string
    li a1, INPUT_SIZE	# max length
    la a0, input	# address of buffer    
    ecall

# string modification
#    li a0, input
#    jal modify_string_start

# display the output prompt and the string
    li a7, print_string		# system call for print_string
    la a0, msg1		# address of string 
    ecall
    li a7, print_string		# system call for print_string
    la a0, input	# address of string 
    ecall

exit:	
    li 	a7, terminate_program	# Terminate the program
    ecall
    
    
modify_string_start:
	mv t0, zero
	mv t1, input
