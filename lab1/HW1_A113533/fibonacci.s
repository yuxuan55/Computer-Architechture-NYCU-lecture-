.data
	input_msg:	.asciiz "Please input a number: "
	output_msg:	.asciiz "The result of fibonacci(n) is "
.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg on the console interface
	li      $v0, 4			# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0 
	
# jump to procedure fibonacci
	jal 	fibonacci
	move 	$t0, $v0		# save return value in t0 
	
# print output_msg 
	li      $v0, 4			# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure fibonacci 
	move	$a0, $t0			
	li 	$v0, 1				
	syscall 

# exit the program
	li 	$v0, 10			# call system call: exit
	syscall				# run the syscall
	
#------------------------- procedure fibonacci -----------------------------
# load argument n in $a0, return value in $v0. 
.text
fibonacci:	
	addi 	$sp, $sp, -8		
	sw 	$ra, 4($sp)
	sw 	$a0, 0($sp)		
		
	bne	$a0, $zero, L1
	add 	$v0, $zero, $zero	# return 0 when n = 0			
	
	lw 	$a0, 0($sp)
	lw 	$ra, 4($sp)
	addi 	$sp, $sp, 8		
	jr 	$ra					
L1:
	addi	$t0, $a0, -1		
	bne	$t0, $zero, L2
	addi 	$v0, $zero, 1		# return 1 when n = 1					
	
	lw 	$a0, 0($sp)
	lw 	$ra, 4($sp)
	addi 	$sp, $sp, 8		
	jr 	$ra				
L2:	
	addi	$a0, $a0, -1		# n-1
	jal	fibonacci		# fib(n-1)			
	
	#add	$t1, $v0, $zero		# store fib(n-1) in t1	
	addi 	$sp, $sp, -4		
	sw	$v0, 0($sp)
							
	lw 	$a0, 4($sp)
	addi	$a0, $a0, -2		# n-2
	jal	fibonacci		# fib(n-2)
	lw	$t1, 0($sp)
	addi 	$sp, $sp, 4				
	add 	$v0, $t1, $v0		# return fib(n-1) + fib(n-2) when n >= 2
	
	lw 	$a0, 0($sp)
	lw 	$ra, 4($sp)
	addi 	$sp, $sp, 8
	jr 	$ra			
	
