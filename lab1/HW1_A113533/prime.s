.data
	input_msg:	.asciiz "Please input a number: "
	output_msg1:	.asciiz "It's a prime "
	output_msg2:	.asciiz "It's not a prime "
.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer in $v0
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0 (set arugument of procedure factorial)

# jump to procedure is_prime
	jal 	is_prime
	move 	$t0, $v0		# save return value in t0 (because v0 will be used by system call) 

# print output_msg1 
	beq 	$t0, $zero, L0
	li      $v0, 4			# call system call: print string
	la      $a0, output_msg1	# load address of string into $a0
	syscall                 	# run the syscall 
	li 	$v0, 10			# call system call: exit
	syscall				# run the syscall

# print output_msg2
L0:
	li      $v0, 4			# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall 
	li 	$v0, 10			# call system call: exit
	syscall				# run the syscall
	
#------------------------- procedure is_prime -----------------------------
# load argument n in $a0, return value in $v0. 
.text
is_prime:	
	addi 	$sp, $sp, -4		# adiust stack for 1 items
	sw 	$ra, 0($sp)		# save the return address
	addi	$t0, $zero, 1		# t0 = 1
	bne 	$a0, $t0, L1		# if n != 1 go to L1	
	add 	$v0, $zero, $zero	# return 0		
	addi 	$sp, $sp, 4		# pop 1 items off stack
	jr 	$ra			# return to caller
		
	add	$t1, $t0, $zero 	# t1 = 1 = i
L1:	
	addi	$t1, $t1, 1		# i += 1
	mul 	$t2, $t1, $t1		# t2 = i*i
	slt	$t3, $a0, $t2		# t3 = 1 if n < i*i
	bne	$t3, $zero, L2		# if t3 = 1 goto L2
	div	$a0, $t1		# n % i
	mfhi	$t4			# t4 = n % i
	bne	$t4, $zero, L1		# if n%i != 0 goto L1
	add 	$v0, $zero, $zero	# return 0
	addi 	$sp, $sp, 4		# pop 1 items off stack
	jr 	$ra			# return to caller
L2:	
	addi 	$v0, $zero, 1		# return 1		
	addi 	$sp, $sp, 4		# pop 1 items off stack
	jr 	$ra			# return to caller
	
