
#=========================================================================
# 2D String Finder 
#=========================================================================
# Finds the matching words from dictionary in the 2D grid
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2019
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

grid_file_name:         .asciiz  "2dgrid.txt"
dictionary_file_name:    .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
        
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
grid:                   .space 1057     # Maximun size of 2D grid_file + NULL (((32 + 1) * 32) + 1)
.align 4                                # The next field will be aligned
dictionary:             .space 11001    # Maximum number of words in dictionary *
                                        # ( maximum size of each word + \n) + NULL
# You can add your data here!
.align 4
dictionary_idx:         .space 4004   

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, grid_file_name        # grid file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # grid[idx] = c_input
        la   $a1, grid($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(grid_file);
        blez $v0, END_LOOP              # if(feof(grid_file)) { break }
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP 
END_LOOP:
        sb   $0,  grid($t0)            # grid[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(grid_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from  file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)                             
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


# You can add your code here!
	li $t0, 0                       #idx = 0
	li $t1, 0                       #start_idx = 0
	li $t4, 0                       #dict_idx = 0
	li $s1, 0                       #dict_num_words = 0
STORING_LOOP:
	lb $t2 dictionary($t0)          #c_input = dictioary[idx];         
        beq $t2, $0, END_STORING_LOOP 	#break if(c_input == '\0')
        addi $v0, $0, 10
        beq $t2, $v0, BRANCH1           #if(c_input == '\n);
        j END_BRANCH1
BRANCH1: 
	sw $t1, dictionary_idx($t4)     #dictionary_idx[dict_idx] = start_idx
	addi $t4, $t4, 4                #dict_idx ++
	addi $t1, $t0, 1                #start_idx = idx + 1
END_BRANCH1:
	addi $t0, $t0, 1                #idx += 1
	j STORING_LOOP
END_STORING_LOOP:
	move $s1, $t4
	li $s6, 0                       #no_lines
	li $t0, 0                       #length = 0
		
NO_LINES_FUNCTION:
	lb $t8, grid($t7)
	beq $0, $t8, LENGTH_FUNCTION
	addi $v0, $0, 10
	beq $v0, $t8, INC_NO_LINES      #if(grid[chr] == '\n')
	addi $t7, $t7, 1                #chr++
	j NO_LINES_FUNCTION
INC_NO_LINES:
	addi, $s6, $s6, 1               #no_lines++
	addi $t7, $t7, 1                    
	j NO_LINES_FUNCTION		
LENGTH_FUNCTION:
	lb $t0, grid($s2)               #grid[length]
	addi $v0, $0, 10
	beq $t0, $v0, STRFIND           #grid[length] != '\n'       
	addi $s2, $s2, 1                #length++
	j LENGTH_FUNCTION	
	
	
STRFIND:
	li $t3, 0                       #chr = 0
	li $t4, 0                       #line = 0
	li $t5, 0                       #col = 0
STRFIND_WHILE:
	lb $s7, grid($t3)               #grid[chr]
	beq $s7, $0, PRINT_STRING       #verify if grid[chr] != '\0'
	li $t0, 0                       #idx = 0 
	addi $v0, $0, 10
	beq $s7, $v0, INC_LINE          #if grid[chr] == '\n'
	j STRFIND_FOR
INC_LINE:	
	addi $t4, $t4, 1                #line++
	li $t5, 0                       #col = 0
	addi $t3, $t3, 1                #chr++
	j STRFIND_WHILE
STRFIND_FOR:
	                                #idx is less than dict_num_words
	bge $t0, $s1, END_STRFIND_FOR   #if condition is false then exit for
	lw $t7, dictionary_idx($t0)     #dictionary_idx[idx]
FOR_CONTAIN_H:
	la $t8, dictionary              #address of dictionary
	add $t8, $t8, $t7               #word = dictionary + dictionary_idx[idx]
        la $t9, grid                    #address of grid
	add $t9, $t9, $t3               #grid + chr
	move $a1, $t8
	move $a2, $t9
	la $s3, 0($a1)                  #address of word to print if correct
	jal CONTAIN_H
FOR_CONTAIN_V:
	la $t8, dictionary              #address of dictionary
	add $t8, $t8, $t7               #word = dictionary + dictionary_idx[idx]
        la $t9, grid                    #address of grid
	add $t9, $t9, $t3               #grid + chr
	move $a1, $t8
	move $a2, $t9
	la $s3, 0($a1)                  #address of word to print if correct
	jal CONTAIN_V
FOR_CONTAIN_D:
	la $t8, dictionary              #address of dictionary
	add $t8, $t8, $t7               #word = dictionary + dictionary_idx[idx]
        la $t9, grid                    #address of grid
	add $t9, $t9, $t3               #grid + chr
	move $a1, $t8
	move $a2, $t9
	la $s3, 0($a1)                  #address of word to print if correct     
	jal CONTAIN_D       
NEXT:
	addi $t0, $t0, 4                #idx++
	j STRFIND_FOR
END_STRFIND_FOR:
	addi $t3, $t3, 1                #chr++
	addi $t5, $t5, 1                #col++
	j STRFIND_WHILE    
	
	
	
	
CONTAIN_H:
	lb $t8, 0($a1)
	lb $t9, 0($a2)	
	bne $t8, $t9, END_CONTAIN_H     #*string != *word
	addi $v0, $0, 10
	beq $t9, $v0, END_CONTAIN_H     #*string == '\n'
	addi $a1, $a1, 1                #word++
	addi $a2, $a2, 1                #string++	
	j CONTAIN_H
END_CONTAIN_H:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_H           #if(*word == '\n') print
	jr $ra
	
	
	
	
CONTAIN_V:
	lb $t8, 0($a1)                  #word
	lb $t9, 0($a2)	                #string
	bne $t8, $t9, END_CONTAIN_V     #*string != *word
	addi $v0, $0, 10
	beq $t9, $v0, END_CONTAIN_V     #*string == '\n'
	la $t1, grid
	sub $t1, $a2, $t1               #string - grid
	addi $t1, $t1, 1
	add $t1, $t1, $s2               #string - grid + length + 1
	addi $t2, $s2, 1            
	mul $t2, $t2, $s6               #(length + 1)*no_lines             
	bge $t1, $t2, BR2_V
BR1_V:
	addi $a1, $a1, 1                #word++
	addi $a2, $a2, 1
	add $a2, $a2, $s2               #string = string + length + 1;
	j CONTAIN_V
BR2_V:
	addi $a1, $a1, 1                #word++	
	lb $t8, 0($a1)
	j END_CONTAIN_V
END_CONTAIN_V:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_V           #if(*word == '\n') print
	jr $ra
	
	
	
	
		
CONTAIN_D:
	lb $t8, 0($a1)
	lb $t9, 0($a2)	
	bne $t8, $t9, END_CONTAIN_D     #*string != *word
	addi $v0, $0, 10
	beq $t9, $v0, END_CONTAIN_D     #*string == '\n'
	la $t1, grid
	sub $t1, $a2, $t1               #string - grid
	addi $t1, $t1, 2
	add $t1, $t1, $s2               #string - grid + length + 1
	addi $t2, $s2, 1            
	mul $t2, $t2, $s6               #(length + 1)*no_lines             
	bge $t1, $t2, BR2_D
BR1_D:
	addi $a1, $a1, 1                #word++
	addi $a2, $a2, 2
	add $a2, $a2, $s2               #string = string + length + 2;
	j CONTAIN_D
BR2_D:
	addi $a1, $a1, 1                #word++	
	lb $t8, 0($a1)
	j END_CONTAIN_D
END_CONTAIN_D:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_D           #if(*word == '\n') print
	j NEXT
	
	
	
	
	
	
	
PRINT_H:
	li $v1, 1                       #ok = true
	li $v0, 1                       #print_int(line)
	add $a0, $0, $t4
	syscall
	li $a0, ','                     #print_char(',')
	li $v0, 11  
	syscall
	li $v0, 1                       #print_int(col)
	add $a0, $0, $t5
	syscall
	li $a0, ' '                     #print_char(' ')
	li $v0, 11  
	syscall
	li $a0, 'H'                     #print_char('H')
	li $v0, 11  
	syscall
	li $a0, ' '                     #print_char(' ')
	li $v0, 11  
	syscall
	j PRINT_WORD_H
PRINT_V:
	li $v1, 1                       #ok = true
	li $v0, 1                       #print_int(line)
	add $a0, $0, $t4
	syscall
	li $a0, ','                     #print_char(',')
	li $v0, 11  
	syscall
	li $v0, 1                       #print_int(col)
	add $a0, $0, $t5
	syscall
	li $a0, ' '                     #print_char(' ')
	li $v0, 11  
	syscall
	li $a0, 'V'                     #print_char('V')
	li $v0, 11  
	syscall
	li $a0, ' '                     #print_char(' ')
	li $v0, 11  
	syscall
	j PRINT_WORD_V
PRINT_D:
	li $v1, 1                       #ok = true
	li $v0, 1                       #print_int(line)
	add $a0, $0, $t4
	syscall
	li $a0, ','                     #print_char(',')
	li $v0, 11  
	syscall
	li $v0, 1                       #print_int(col)
	add $a0, $0, $t5
	syscall
	li $a0, ' '                     #print_char(' ')
	li $v0, 11  
	syscall
	li $a0, 'D'                     #print_char('D')
	li $v0, 11  
	syscall
	li $a0, ' '                     #print_char(' ')
	li $v0, 11  
	syscall
	j PRINT_WORD_D
PRINT_WORD_H:
	lb $t6, 0($s3)                  #*word
	addi $v0, $0, 10                #newline  
	beq $t6, $v0, END_PRINT_WORD_H
	beq $t6, $0, END_PRINT_WORD_H
	li $v0, 11                      #print char 
	move $a0, $t6
	syscall
	addi $s3, $s3, 1                #word++ 
	j PRINT_WORD_H
PRINT_WORD_V:
	lb $t6, 0($s3)                  #*word
	addi $v0, $0, 10                #newline  
	beq $t6, $v0, END_PRINT_WORD_V
	beq $t6, $0, END_PRINT_WORD_V
	li $v0, 11                      #print char 
	move $a0, $t6
	syscall
	addi $s3, $s3, 1                #word++ 
	j PRINT_WORD_V
PRINT_WORD_D:
	lb $t6, 0($s3)                  #*word
	addi $v0, $0, 10                #newline  
	beq $t6, $v0, END_PRINT_WORD_D
	beq $t6, $0, END_PRINT_WORD_D
	li $v0, 11                      #print char 
	move $a0, $t6
	syscall
	addi $s3, $s3, 1                #word++ 
	j PRINT_WORD_D
END_PRINT_WORD_H:
     	li $a0, 10                      #print_char('\n')
	li $v0, 11 
	syscall
	j FOR_CONTAIN_V
END_PRINT_WORD_V:
     	li $a0, 10                      #print_char('\n')
	li $v0, 11 
	syscall
	j FOR_CONTAIN_D
END_PRINT_WORD_D:
     	li $a0, 10                      #print_char('\n')
	li $v0, 11 
	syscall
	j NEXT
PRINT_STRING:
	beq $v1, 1, main_end            #if ok = true then do not print -1
        li $a0, -1                      #print -1 and newline
	li $v0, 1 
	syscall
	li $a0, '\n'
	li $v0, 11 
	syscall
	j main_end	
 
 
 
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------

