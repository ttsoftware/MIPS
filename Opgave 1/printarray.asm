	.data
	.align 2
	array: .word -1,25,323,-455,599,9999999,-99999992 # indtast jeres array p� denne m�de n�r i skal teste, label bestemmes selv.
	.align 2
	text:  .asciiz "Print array: " #nul termineret, kan �ndres til feks at sige sorteret array, ville give god mening for G1. 
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

#demonstrerer brugen af print
callPrint:
	la $a0, array
	addi $a1, $zero, 7
	jal print
	li $v0, 10			# 'exit' system call
	syscall
	


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
	
	
