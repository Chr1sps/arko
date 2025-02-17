#	Triangle shading program by Krzysztof Pałucki

# For the purpose of this program I define a structure which will contain important
# bitmap data for image reading from the bmp file. Its C definition would be:
#	struct {
#		char* filename;		// filename
#		unsigned char* hdrData; // bmp header array pointer
#		unsigned char* imgData; // image data array pointer
#	} imgInfo;

.eqv ImgInfo_fname	0
.eqv ImgInfo_hdrdat 	4
.eqv ImgInfo_imdat	8

.eqv IMG_WIDTH		320	# there is no padding required  as the image width is divisible by 4 already
.eqv IMG_HEIGHT		240
.eqv IMG_SIZE		307200 # 320 x 240 x 4 (pixels)

# syscall aliases
.eqv system_ExitCode 	93
.eqv system_ReadInt	5
.eqv system_PrintString 4

# triangle points' coordinates
# these coordinates must satisfy the triangle existence condition
# in order for the program to work
.eqv coord_x1 0
.eqv coord_y1 0
.eqv coord_x2 199
.eqv coord_y2 0
.eqv coord_x3 0
.eqv coord_y3 199

# various aliases for coords, constants, colours, etc.
.eqv img_l s1
.eqv img_h s2
.eqv p_x s3
.eqv p_y s4
.eqv a_x s6
.eqv a_y s7
.eqv b_x s8
.eqv b_y s9
.eqv c_x s10
.eqv c_y s11

.eqv xp t4
.eqv xk a7

.eqv color_a a1
.eqv color_b a2
.eqv color_c a3

# shift constant used in constant point calculations
# determined by trial and error
.eqv shift 6


	.data

	.align 4
imgData: 	.space	IMG_SIZE


first_prompt: .asciz "Enter first pixel.\nR:"
second_prompt: .asciz "Enter second pixel.\nR:"
third_prompt: .asciz "Enter third pixel.\nR:"
g_prompt: .asciz "G:"
b_prompt: .asciz "B:"
error_prompt: .asciz "Colour value outside of range. Stopping."

	.text
	
main:
	
	# branch used for quick testing without I/O
	li t0, 1
	bnez t0, test
	
	# reading first corner's colour
	# R
	la a0, first_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 8
	mv a1, a0
	
	# G
	la a0, g_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 16
	or a1, a1, a0
	
	# B
	la a0, b_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 24
	or a1, a1, a0
	
	# reading second corner's colour
	# R
	la a0, second_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 8
	mv a2, a0
	
	# G
	la a0, g_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 16
	or a2, a2, a0
	
	# B
	la a0, b_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 24
	or a2, a2, a0
	
	# reading third corner's colour
	
	# R
	la a0, third_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 8
	mv a3, a0
	
	# G
	la a0, g_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 16
	or a3, a3, a0
	
	# B
	la a0, b_prompt
	jal read_int_prompt
	
	slli a0, a0, 24
	srli a0, a0, 24
	or a3, a3, a0

	b run

test:
	# testing values
	li a1, 0x00C70000
	li a2, 0x0000C700
	li a3, 0x000000C7


run:

	la a0, imgData
	jal modify_file
	
#display_frame:
#	la a0, imgData
#	li a1, IMG_WIDTH
#	li a2, IMG_HEIGHT
#	li a7, 61
#	ecall
		
fin:
	
	mv zero, a0
	li a7, system_ExitCode
	ecall
	
	



# ===== read_int_prompt =====
# arguments:
#	a0 - string to print
# return value:
#	a0 - int representing one of the R, G, B components
# notes:
#	exits with code -1 if the value given isn't within 0 - 255 range
read_int_prompt:
	li a7, system_PrintString
	ecall
	li a7, system_ReadInt
	ecall
	li t0, 255
	blt a0, zero, rip_error
	bgt a0, t0, rip_error
	jr ra

rip_error:
	la a0, error_prompt
	li a7, system_PrintString
	ecall
	li a0, -1
	li a7, system_ExitCode
	ecall
	
sf_fin:
	mv a0, zero
	jr ra
	
sf_error:
	li a0, -1
	jr ra






# ===== modify_file =====
# arguments:
#	a0 - address of imgInfo struct
#	a1 - first corner's colour
#	a2 - second corner's colour
#	a3 - third corner's colour
# return value:
#	none
# notes:
#	- changes a0, a4, a5, a6, a7; can also change a1, a2, a3
#	- colours are signified by a 0x0RGB format word (where R,G,B = 8 bits)
modify_file:
	
	# preserving all saved register values onto the stack
	addi sp, sp, -48
	sw ra, 44(sp)
	sw s1, 40(sp)
	sw s2, 36(sp)
	sw s3, 32(sp)
	sw s4, 28(sp)
	sw s5, 24(sp)
	sw s6, 20(sp)
	sw s7, 16(sp)
	sw s8, 12(sp)
	sw s9, 8(sp)
	sw s10, 4(sp)
	sw s11, 0(sp)
	
	li s1, IMG_WIDTH	#img_l
	li s2, IMG_HEIGHT	#img_h
	
	mv s5, a0	# address of image data
 
	li s6, coord_x1		# a_x
	li s7, coord_y1		# a_y
	li s8, coord_x2		# b_x
	li s9, coord_y2		# b_y
	li s10, coord_x3	# c_x
	li s11, coord_y3	# c_y
	
edge_case_check:
	
	# here we check if a_y value is within b_y and c_y boundaries, as it would
	# make the interpolation algorithm not work properly
	
	# checking if y values are equal
	beq a_y, b_y, a_c_swap
	beq a_y, c_y, a_b_swap

	# checking if a_y is between
	sub t0, b_y, a_y
	sub t1, c_y, a_y
	mul t0, t0, t1
	bgt t0, zero, interpolate_save_for_calcs
	
a_c_swap:
	
	# swap a_x and c_x
	mv t0, a_x
	mv a_x, c_x
	mv c_x, t0

	# swap a_y and c_y	
	mv t0, a_y
	mv a_y, c_y
	mv c_y, t0
	
	# swap color_a and color_c
	mv t0, color_a
	mv color_a, color_c
	mv color_c, t0

	b interpolate_save_for_calcs
	
a_b_swap:
	
	# swap a_x and b_x
	mv t0, a_x
	mv a_x, b_x
	mv b_x, t0

	# swap a_y and b_y	
	mv t0, a_y
	mv a_y, b_y
	mv b_y, t0
	
	# swap color_a and color_b
	mv t0, color_a
	mv color_a, color_b
	mv color_b, t0

interpolate_save_for_calcs:
	
	# saving important constants for later interpolation calculations
	sub t5, a_y, b_y	# a_y - b_y
	sub t6, a_y, c_y	# a_y - c_y


mf_loop_y_init:	
									
	mv p_y, zero	# y coordinate (p.y)

mf_loop_y:
	
	mv p_x, zero	# x coordinate (p.x)
	
interpolate_line:
	
	# useful for later calculations
	sub a4, p_y, b_y	# p.y - b.y
	sub a5, p_y, c_y	# p.y - c.y
	sub a6, a_y, p_y	# a.y - p.y
	
	slli a4, a4, shift	# shifting
	slli a5, a5, shift
	slli a6, a6, shift
	
mf_loop_x:
	
	# using determinants to check if a point is inside the triangle
det_1:
	sub t0, p_x, b_x	# p.x - b.x
	sub t1, a_y, b_y	# a.y - b.y
	mul t0, t0, t1	
	sub t1, a_x, b_x	# a.x - b.x
	sub t2, p_y, b_y	# p.y - b.y
	mul t1, t1, t2	
	sub t0, t0, t1	
	
det_2:
	sub t1, p_x, c_x	# p.x - c.x
	sub t2, b_y, c_y	# b.y - c.y
	mul t1, t1, t2	
	sub t2, b_x, c_x	# b.x - c.x
	sub t3, p_y, c_y	# p.y - c.y
	mul t2, t2, t3	
	sub t1, t1, t2	

det_3:
	sub t2, p_x, a_x	# p.x - a.x
	sub t3, c_y, a_y	# c.y - a.y
	mul t2, t2, t3	
	sub t3, c_x, a_x	# c.x - a.x
	sub t4, p_y, a_y	# p.y - a.y
	mul t3, t3, t4	
	sub t2, t2, t3	

det_check:
	# checking if all determinants are simultaneously either >= 0 or <= 0
	blt t0, zero, det_l1
	blt t1, zero, det_l2
	blt t2, zero, det_l3
	
	b interpolate

det_l1:
	bgt t1, zero, not_in
	bgt t2, zero, not_in
	
	b interpolate

det_l2:
	bne t0, zero, not_in
	bgt t2, zero, not_in
	
	b interpolate

det_l3:
	bne t0, zero, not_in
	bne t1, zero, not_in
	
	b interpolate
	

not_in:
	# if not in then save a black pixel
	li t0, 0
	b write_pixel
	
interpolate:

	# first we have to check if the current point p has
	# coordinates equal to those of one of the vertices
	# if that's the case then the resulting intensity
	# will be equal to that of a given vertex
interpolate_check_a:
	bne p_x, a_x, interpolate_check_b
	bne p_y, a_y, interpolate_check_b
	mv t0, a1
	j write_pixel
	
	
interpolate_check_b:
	bne p_x, b_x, interpolate_check_c
	bne p_y, b_y, interpolate_check_c
	mv t0, a2
	j write_pixel

interpolate_check_c:
	bne p_x, c_x, interpolate_start
	bne p_y, c_y, interpolate_start
	mv t0, a3
	j write_pixel
	
	# main body of the interpolation function
interpolate_start:
	
	# calculating xp and xk (in case one of these is on an extension of 
	# one of the sides of the triangle)
	mv t0, a_x
	mv t1, b_x
	mv t2, c_x
	
	mul t3, t0, a4
	mul t1, t1, a6
	add t1, t1, t3
	div t4, t1, t5	# xp
	
	mul t0, t0, a5
	mul t2, t2, a6
	add t0, t0, t2
	div a7, t0, t6	# xk
	
	# checking if the width of a triangle is equal to 1
	# (therefore, if x_k and x_p are equal)
	# if so, calculations will be slightly different
	beq a7, t4, interpolate_zero
	
interpolate_r:

	# region Someregion
	# calculating Ip and Ik
	li t3, 0x00FF0000
	and t0, color_a, t3	# Ia
	and t1, color_b, t3	# Ib
	and t2, color_c, t3	# Ic

	srli t0, t0, 16
	srli t1, t1, 16
	srli t2, t2, 16
	
	
	mul t3, t0, a4
	mul t1, t1, a6
	add t1, t1, t3
	div t1, t1, t5	# Ip = ((b.y - p.y) * Ia + (a.y-p.y) * Ib)/(a.y-b.y)
	
	srai t1, t1, shift
	
	mul t0, t0, a5
	mul t2, t2, a6
	add t0, t0, t2
	div t0, t0, t6	# Ik = ((c.y - p.y) * Ia + (a.y-p.y) * Ic)/(a.y-c.y)
	
	srai t0, t0, shift
	
	mv t3, p_x
	slli t3, t3, shift	# load shifted p_x
	
	sub t2, xk, t3	
	mul t1, t1, t2 
	sub t2, t3, xp
	mul t0, t0, t2
	add t0, t0, t1 
	sub t1, xk, xp 
	div t0, t0, t1 # Is = ((x.k - p.x) * Ip + (p.x - x.p) * Ik) / (x.k - x.p)

	sb t0, 2(s5)
     # endregion


interpolate_g:

	li t3, 0x0000FF00
	and t0, color_a, t3	# Ia
	and t1, color_b, t3	# Ib
	and t2, color_c, t3	# Ic
	
	srli t0, t0, 8
	srli t1, t1, 8
	srli t2, t2, 8


	mul t3, t0, a4
	mul t1, t1, a6
	add t1, t1, t3
	div t1, t1, t5	# Ip = ((b.y - p.y) * Ia + (a.y-p.y) * Ib)/(a.y-b.y)
	
	srai t1, t1, shift
	
	mul t0, t0, a5
	mul t2, t2, a6
	add t0, t0, t2
	div t0, t0, t6	# Ik = ((c.y - p.y) * Ia + (a.y-p.y) * Ic)/(a.y-c.y)
	
	srai t0, t0, shift 
	
	
	mv t3, p_x
	slli t3, t3, shift	# load shifted p_x
	
	sub t2, xk, t3	
	mul t1, t1, t2 
	sub t2, t3, xp
	mul t0, t0, t2
	add t0, t0, t1 
	sub t1, xk, xp 
	div t0, t0, t1 # Is = ((x.k - p.x) * Ip + (p.x - x.p) * Ik) / (x.k - x.p)
	
	sb t0, 1(s5)

interpolate_b:

	li t3, 0x000000FF
	and t0, color_a, t3	# Ia
	and t1, color_b, t3	# Ib
	and t2, color_c, t3	# Ic
	
	mul t3, t0, a4
	mul t1, t1, a6
	add t1, t1, t3
	div t1, t1, t5	# Ip = ((b.y - p.y) * Ia + (a.y-p.y) * Ib)/(a.y-b.y)
	
	srai t1, t1, shift
	
	mul t0, t0, a5
	mul t2, t2, a6
	add t0, t0, t2
	div t0, t0, t6	# Ik = ((c.y - p.y) * Ia + (a.y-p.y) * Ic)/(a.y-c.y)
	
	srai t0, t0, shift
	
	mv t3, p_x
	slli t3, t3, shift	# load shifted p_x
	
	sub t2, xk, t3	
	mul t1, t1, t2 
	sub t2, t3, xp
	mul t0, t0, t2
	add t0, t0, t1 
	sub t1, xk, xp 
	div t0, t0, t1 # Is = ((x.k - p.x) * Ip + (p.x - x.p) * Ik) / (x.k - x.p)
	
	sb t0, 0(s5)
	
	j move_img_ptr

interpolate_zero:

	# calculating Ip and Ik
	li t3, 0x00FF0000
	and t0, color_a, t3	# Ia
	and t1, color_b, t3	# Ib

	srli t0, t0, 16
	srli t1, t1, 16
	
	mul t2, t0, a4
	mul t1, t1, a6
	add t1, t1, t2
	div t1, t1, t5	# Ip = ((b.y - p.y) * Ia + (a.y-p.y) * Ib)/(a.y-b.y)
	
	srai t1, t1, shift
	
	sb t1, 2(s5)

	# calculating Ip and Ik
	li t3, 0x0000FF00
	and t0, color_a, t3	# Ia
	and t1, color_b, t3	# Ib

	srli t0, t0, 8
	srli t1, t1, 8
	
	mul t2, t0, a4
	mul t1, t1, a6
	add t1, t1, t2
	div t1, t1, t5	# Ip = ((b.y - p.y) * Ia + (a.y-p.y) * Ib)/(a.y-b.y)
	
	srai t1, t1, shift
	
	sb t1, 1(s5)

	# calculating Ip and Ik
	li t3, 0x000000FF
	and t0, color_a, t3	# Ia
	and t1, color_b, t3	# Ib

	
	mul t2, t0, a4
	mul t1, t1, a6
	add t1, t1, t2
	div t1, t1, t5	# Ip = ((b.y - p.y) * Ia + (a.y-p.y) * Ib)/(a.y-b.y)
	
	srai t1, t1, shift
	
	sb t1, 0(s5)
	
	j move_img_ptr

write_pixel:

	# used when a pixel isn't inside the triangle
	sb t0, 0(s5)
	srli t0, t0, 8
	sb t0, 1(s5)
	srli t0, t0, 8
	sb t0, 2(s5)
	
move_img_ptr:
	# shifting image data pointer by 3 bytes (BGR data length)
	addi s5, s5, 4

mf_loop_x_end:
	addi p_x, p_x, 1
	bne p_x, img_l, mf_loop_x

display_frame:
	# first, preserve the existing a0-2 values
	mv t0, a0
	mv t1, a1
	mv t2, a2

	# then make the actual syscall
	la a0, imgData
	li a1, IMG_WIDTH
	li a2, IMG_HEIGHT
	li a7, 61
	ecall

	# last, restore the values
	mv a0, t0
	mv a1, t1
	mv a2, t2

mf_loop_y_end:	
	addi p_y, p_y, 1
	bne p_y, img_h, mf_loop_y
	
	
mf_fin:
	
	# popping all pushed register values
	lw s11, 0(sp)
	lw s10, 4(sp)
	lw s9, 8(sp)
	lw s8, 12(sp)
	lw s7, 16(sp)
	lw s6, 20(sp)
	lw s5, 24(sp)
	lw s4, 28(sp)
	lw s3, 32(sp)
	lw s2, 36(sp)		
	lw s1, 40(sp)	
	lw ra, 44(sp)
	addi sp, sp, 48
	jr ra


