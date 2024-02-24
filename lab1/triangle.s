.data
	input_msg1:	.asciiz "Please enter option (1: triangle, 2: inverted triangle): "
	input_msg2:	.asciiz "Please input a triangle size: "
	output_msg1:	.asciiz " "
	output_msg2:	.asciiz "*"
	output_msg3:	.asciiz "\n"
	
.text
.globl main
#------------------------- main -----------------------------
main:
# print ----- input_msg1 ----- on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, input_msg1		# load address of string into $a0
	syscall                 	# run the syscall
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $s0, $v0      		# s0 = op
	
# print ----- input_msg2 ----- on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $s1, $v0      		# s1 = n
	
# for i = 0 to n-1 do:
	add	$s2, $zero, $zero	# s2 = i = 0
L0:	
	slt	$s4, $s2, $s1		# s4 = 1 if i<n
	beq	$s4, $zero, exit	
	addi	$s3, $s0, -1		# s3 = op-1
	
	#bne	$s1, $zero, L1
	bne	$s3, $zero, L1
	add	$s5, $s1, $zero		# s5: first argument
	#bne	$s5, $zero, L1
	add	$s6, $s2, $zero		# s6: second argument
	jal 	print_layer
	j	L2
L1:
	#add	$a0, $a2, $zero
	add	$s5, $s1, $zero		# s5: first argument
	sub	$s6, $s1, $s2		
	subi	$s6, $s6, 1		# s6: second argument
	jal 	print_layer
L2:	
	addi	$s2, $s2, 1		# i += 1
	j	L0
	#slt	$s4, $s2, $s1		# s4 = 1 if i<n
	#bne	$s4, $zero, L0	
	
exit:	
# exit the program
	li 	$v0, 10			# call system call: exit
	syscall	


#------------------------- procedure print_layer -----------------------------
# load arguments in $s5, $s6
.text
print_layer:	
	addi 	$sp, $sp, -4		# adiust stack for 1 items
	sw 	$ra, 0($sp)		# save the return address
	
	addi	$t0, $zero, 1		# t0 = j = 1
	sub	$t2, $s5, $s6		# t2 = n-l
	add	$t3, $s5, $s6		# t3 = n+l
L3:
	slt	$t1, $t0, $t2		# t1 = 1 if  j < n-l
	beq	$t1, $zero, L4
	li      $v0, 4			# call system call: print string
	la      $a0, output_msg1	# load address of string into $a0
	syscall                 	# run the syscall
	addi	$t0, $t0, 1
	j	L3
L4:	
	#add	$t2, $s5, 1		# t2 = j
	slt	$t4, $t3, $t2		# t4 = 1 if  n+l < j
	bne	$t4, $zero, L5
	li      $v0, 4			# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall
	addi	$t2, $t2, 1
	j	L4
		
L5:
	li      $v0, 4			# call system call: print string
	la      $a0, output_msg3	# load address of string into $a0
	syscall                 	# run the syscall
	
	addi 	$sp, $sp, 4		# pop 1 items off stack
	jr 	$ra			# return to caller
	
