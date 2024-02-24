.data
	input_msg0:	.asciiz "Please enter option (1: add, 2: sub, 3: mul): "
	input_msg1:	.asciiz "Please enter the first number: "
	input_msg2:	.asciiz "Please enter the second number: "
	output_msg:	.asciiz "The calculation result is: "
.text
.globl main
#------------------------- main -----------------------------
main:
# print -----input_msg0----- on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, input_msg0		# load address of string into $a0
	syscall                 	# run the syscall
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t0, $v0      		# store input in $t0 

# print -----input_msg1----- on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, input_msg1		# load address of string into $a0(can't $a1!,need to be a0)
	li      $v0, 4			# call system call: print string
	syscall                 	# run the syscall
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t1, $v0      		# store input in $t1

# print -----input_msg2----- on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t2, $v0      		# store input in $t2
	
# start calculate
	addi	$t3, $zero, 1		# t3 = 1
	bne 	$t0, $t3, L1
	add	$t4, $t1, $t2	
	j	L3
L1:	
	addi	$t3, $t3, 1		# t3 = 2
	bne 	$t0, $t3, L2
	sub	$t4, $t1, $t2
	j	L3
L2:
	addi	$t3, $t3, 1		# t3 = 3
	bne 	$t0, $t3, L3
	mul	$t4, $t1, $t2	
	
L3:	
# print output_msg
	li      $v0, 4			# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall 
	
# print the result of calculation on the console interface
	move 	$a0, $t4			
	li 	$v0, 1				
	syscall 
	
# exit the program
	li 	$v0, 10			# call system call: exit
	syscall	
