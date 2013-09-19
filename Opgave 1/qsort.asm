.data
#vector: .word 1, 4, 1, 3, 2
#vector: .word 56, 54, 32, 78, 59, 32, 16 1, 77, -17
#vector: .word 3, 2, 4, 1, 7
#vector: .word 1, 2, 3, 4, 5
vector: .word 5, 4, 3, 2, 1

.text
# register overview:
	# a1 = left (start index of array)
	# a2 = right (length of array -1)
	# a3 = i (only semi global, as it is reset in every loop) 
	# s1 = last
	# ra = return address stored by jal

main: 
	addi $a1, $0, 0 # $a1 = left
	addi $a2, $0, 4 # $a2 = right
	jal qsort
	
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
	
	jal loop
	
loop:
	addi $a3, $a3, 4 # increment i so we take left+1 into account
	mul $t0, $a2, 4 # multiply right by 4, to get the correct size relative to i
	
	# loop condition	
	bge $t0, $a3, loop_body
	
	mul $t2, $a1, 4 # multiply left to get byte address
	mul $t3, $s1, 4 # multiply last to get byte address
	
	# loop finished
	lw $t0, vector($t2) # $t0 = tmp
	lw $t1, vector($t3) # $t1 = v[last]
	sw $t1, vector($t2) # v[left] = v[last]
	sw $t0, vector($t3) # v[last] = tmp

	# save temp variables before double loop
	move $t1, $a2 # $t2 = right

	addi $a2, $s1, -1 # right = last - 1
	jal qsort
	
	move $a2, $t1 # restore value before recursive call above
	
	addi $a1, $s1, 1 # left = last + 1
	jal qsort
		
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
	jal loop
	
stack_control:
	# use the return address previously stored in the stack pointer, to return to the correct address.
	addi $sp, $sp 4
	lw $ra, ($sp)
	jr $ra
	
terminate:
	nop # vector now contains the sorted array.
