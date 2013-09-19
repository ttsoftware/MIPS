.data
	# Remember to update arraysize when selecting a new array to test.
	#vector: .word 1, 4, 1, 3, 2
	#vector: .word 56, 54, 32, 78, 59, 32, 16 1, 77, -17
	vector: .word 3, 2, 4, 1, 7
	#vector: .word 1, 2, 3, 4, 5
	#vector: .word 5, 4, 3, 2, 1
	arraysize: .word 5
	
	.align 2
	text:  .asciiz "Sorteret array: "
	.align 2
	newLine: .byte		10,0
	.align 2
	negative: .asciiz "-"
	.align 2
	leftP: .asciiz "("
	.align 2
	rightP: .asciiz ")"
	.align 2
	comma: .asciiz ","

.text
# register overview:
	# a1 = left (start index of array)
	# a2 = right (length of array -1)
	# a3 = i (only semi global, as it is reset in every loop) 
	# s1 = last
	# ra = return address stored by jal

# instruction overview
	# add = used for finding the pivot value
	# addi = used for incrementing i, left and right
	# bge = used for the loop condition
	# bgt = used for the if control statement inside the loop
	# div = used for deciding the pivot value
	# jal = used for jumping to a label recursively (returning afterwards)
	# jr = used for jumping to return address set by the previous qsort call.
	# j = used for jumping to terminate.
	# lw = used for loading values from the array
	# move = used for assigning register values
	# mul = used for finding the correct address
	# nop = used for terminating the program
	# subi = used for finding the correct stack pointer address, and subsequent return address.
	# sw = used for storing values in the array, and the stack pointer

main: 
	addi $a1, $0, 0 # $a1 = left
	addi $a2, $0, 4 # $a2 = right
	j qsort
	
qsort:
	# add $ra to the stack pointer, in order to be able to reuse it 
	sw $ra, ($sp) 
	subi $sp, $sp, 4 
	
	bge $a1, $a2, stack_control # left >= right
	
	mul $t0, $a1, 4 # align adress
	
	lw $t1, vector($t0) # tmp = v[left]	$t0 = tmp
	add $t2, $a1, $a2 # $s0 = (left + right)
	div $t2, $t2, 2 # $s0 = (left + right) / 2
	mul $t2, $t2, 4 # get correct address by multiplying with 4
	
	lw $t3, vector($t2) # $t1 = vector((left + right) / 2) 
	sw $t3, vector($t0) # vector(left) = vector((left + right) / 2)
	sw $t1, vector($t2) # vector((left + right) / 2) = tmp
	
	move $s1, $a1 # last = left	$s1 = last
	mul $a3, $a1, 4 # i = left	$a3 = i
	
	j loop
	
loop:
	addi $a3, $a3, 4 # increment i so we take left+1 into account
	mul $t0, $a2, 4 # multiply right by 4, to get the correct size relative to i
	
	# loop condition	i <= right
	bge $t0, $a3, loop_body
	
	mul $t2, $a1, 4 # multiply left to get byte address
	mul $t3, $s1, 4 # multiply last to get byte address
	
	# loop finished
	lw $t0, vector($t2) # $t0 = tmp
	lw $t1, vector($t3) # $t1 = v[last]
	sw $t1, vector($t2) # v[left] = v[last]
	sw $t0, vector($t3) # v[last] = tmp

	# save temp variable before the two loops
	move $t1, $a2 # $t2 = right

	addi $a2, $s1, -1 # right = last - 1
	jal qsort # right-side recursive call
	
	move $a2, $t1 # restore value from temp before recursive call
	
	addi $a1, $s1, 1 # left = last + 1
	jal qsort # left-side recursive call
		
	j terminate
	
loop_body:
	lw $t0, vector($a3) # $t0 = vector[i]
	
	mul $t4, $a1, 4 # align adress
	
	lw $t1, vector($t4) # $t1 = vector[left]	
	bgt $t0, $t1, loop # if v[i] > v[left] -> loop
	
	addi $s1, $s1, 1 # last++
	mul $t3, $s1, 4 # last x 4 to get byte address
	lw $t0, vector($a3) # $t0 = vector[i]
	lw $t1, vector($t3) # $t1 = vector[last]
	
	sw $t0, vector($t3) # v[last] = v[i]
	sw $t1, vector($a3) # v[i] = v[last]
	j loop # start next loop iteration
	
stack_control:
	# use the return address previously stored in the stack pointer, to return to the correct address.
	addi $sp, $sp 4
	lw $ra, ($sp)
	jr $ra
	
terminate:
	nop # vector now contains the sorted array.

callPrint:
	la $a0, vector
	lw $a1 arraysize
	#add $a1, $zero, arraysize
	jal print
	li $v0, 10			# 'exit' system call
	syscall
	jr $ra

## Det er denne funktion der er tilt�nkt i kan bruge til at printe jeres array ud for nemt at se om det er sorteret
print: 	#Printer string der gives i argument a0 med l�ngden gemt i a1	
	addi $sp, $sp, -12
	sw $s1, 0($sp)
	sw $s2, 4($sp)
	sw $ra, 8($sp)
	
	move $s1, $a0			# indeholder starten af array
	move $s2, $a1			# indeholder l�ngen af array
	
	la $a0, text			# Print text
	li $v0, 4
	syscall
	
	la $a0, newLine			# Print \n
	li $v0, 4
	syscall
		
	la $a0, leftP			# Print (
	li $v0, 4
	syscall

startPrintArrayLoop:
	beqz $s2 EndPrintArrayLoop
	lw $a0, ($s1)		# Hent tallet ud
	jal printSingleNumber
	beq $s2, 1, skipComma	# skip comma for last element
	la $a0, comma			# Print ,
	li $v0, 4
	syscall
skipComma:
	addi $s1, $s1, 4	# n�ste tal i array
	addi $s2, $s2, -1	# brug l�ngden som counter
	j startPrintArrayLoop
EndPrintArrayLoop:
		
	la $a0, rightP			# Print )
	li $v0, 4
	syscall
	
	lw $s1, 0($sp)
	lw $s2, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

printSingleNumber:	#a0 er int der skal printes
	addi $sp, $sp, -12 # til at gemme tal i
	move $t1, $a0
	move $t5, $sp	#hvor vi er i vores array
	
	bgt $t1, -1, positive		#check for negative number
	neg $t1, $t1

	# add - til strengen
	addi $t2, $zero, 45
	sb $t2, ($t5) 
	addi $t5, $t5, 1 
	
positive: #when we come here the number is positive
	addi $t2, $zero, 1000000000
	move $t4, $zero	#bruges som flag til at teste om 
	# Loop and see if t2 is != 0, otherwise keep looping
startPositiveLoop:
	beqz $t2, exitPositiveLoop
	divu $t1, $t2
	mflo $t3
	mfhi $t1
	beq  $t3, $t4, skipZero
	addi $t4, $t4, -1 # er nu under 0 og skip ville ikke blive taget
	addi $t3, $t3, 48 # ascii 0
	sb $t3, 0($t5)
	addi $t5, $t5, 1
skipZero:	
	divu $t2, $t2, 10
	j startPositiveLoop
exitPositiveLoop:
	sb $zero, ($t5)			# null terminer
	move $a0, $sp			# Print tal
	li $v0, 4
	syscall
	
	addi $sp, $sp, 12
	jr $ra
