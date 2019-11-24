
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
	li $t0, 0                       #length = 0
	li $s6, -1                      #no_lines
	li $t7, 0                       #chr = 0
	
	
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
	li $t1, 0	                #i = 0
	li $t2, 0                       #j = 0
	li $t3, 0                       #chr = 0
	li $t4, 0                       #line = 0
	li $t5, 0                       #col = 0
STRFIND_WHILE:
	li $t0, 0                       #idx = 0 
	lb $s7, grid($t3)               #grid[chr]
	addi $v0, $0, 10
	beq $s7, $v0, INC_LINE          #if grid[chr] == '\n'
	beq $s7, $0, PRINT_STRING       #verify if grid[chr] != '\0'
	j STRFIND_FOR
INC_LINE:	
	addi $t4, $t4, 1                #line++
	li $t5, 0                       #col = 0
	addi $t3, $t3, 1                #chr++
	j STRFIND_WHILE
STRFIND_FOR:
	slt $t2, $t0, $s1               #set value true or false if idx is less than dict_num_words
	beq $t2, $0, END_STRFIND_FOR    #if condition is false then exit for
	lw $t7, dictionary_idx($t0)     #dictionary_idx[idx]
FOR_CONTAIN_H:
	la $t8, dictionary              #address of dictionary
	add $t8, $t8, $t7               #word = dictionary + dictionary_idx[idx]
        la $t9, grid                    #address of grid
	add $t9, $t9, $t3               #grid + chr
	move $a1, $t8
	move $a2, $t9
	la $s3, 0($a1)                  #address of word to print if correct
	j CONTAIN_H
FOR_CONTAIN_V:
	la $t8, dictionary              #address of dictionary
	add $t8, $t8, $t7               #word = dictionary + dictionary_idx[idx]
        la $t9, grid                    #address of grid
	add $t9, $t9, $t3               #grid + chr
	move $a1, $t8
	move $a2, $t9
	la $s3, 0($a1)                  #address of word to print if correct
	j CONTAIN_V
FOR_CONTAIN_D:
	la $t8, dictionary              #address of dictionary
	add $t8, $t8, $t7               #word = dictionary + dictionary_idx[idx]
        la $t9, grid                    #address of grid
	add $t9, $t9, $t3               #grid + chr
	move $a1, $t8
	move $a2, $t9
	la $s3, 0($a1)                  #address of word to print if correct     
	j START_CONTAIN_D       
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
	addi $v0, $0, 10
	beq $t9, $v0, NEW_STRING_H         #if(*string == '\n')
AFTER_NEW_STRING_H:
	lb $t9, 0($a2)
	bne $t9, $t8, END_CONTAIN_H        #if (*string != *word)
	addi $a1, $a1, 1                   #word++
	addi $a2, $a2, 1                   #string++
	j CONTAIN_H
NEW_STRING_H:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_H              #if (*word == '\n')
	sub $a2, $a2, $s2                  #string = string - length
	j AFTER_NEW_STRING_H	
END_CONTAIN_H:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_H              #if (*word == '\n')
	j FOR_CONTAIN_V			
				
											
							
							
		
CONTAIN_V:
	lb $t8, 0($a1)
	lb $t9, 0($a2)					
        la $a3, grid                    #address of grid
	sub $v0, $a2, $a3               #string - grid
	addi $s6, $s6, 1
	addi, $s2, $s2, 1
	mul $v1, $s2, $s6               #length * no_lines
	addi $s6, $s6, -1
	addi, $s2, $s2, -1
	bge $v0, $v1, NEW_STRING_V	#if(string - grid > length*no_lines)		
AFTER_NEW_STRING_V:
	lb $t9, 0($a2)
	bne $t9, $t8, END_CONTAIN_V     #*string != *word
	addi $a1, $a1, 1                #word++
	addi $a2, $a2, 1
	add $a2, $a2, $s2               #string = string + length + 1
	j CONTAIN_V
NEW_STRING_V:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_V           #if (*word == '\n')
	add $a2, $a3, $t5               #string = grid + col
	j AFTER_NEW_STRING_V	
END_CONTAIN_V:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_V           #if (*word == '\n')
	j FOR_CONTAIN_D									
										
																
					
START_CONTAIN_D:
	move $s0, $t4                   #copy line
	move $a3, $t5                   #copy col
CONTAIN_D:
	lb $t8, 0($a1)
	lb $t9, 0($a2)			
	beq $a3, $s2, NEW_STRING_D      #if(col == length)
	addi $v0, $s6, 1
	beq $s0, $v0, NEW_STRING_D      #if(line == no_lines+1)	
AFTER_NEW_STRING_D:
	lb $t9, 0($a2)
	bne $t9, $t8, END_CONTAIN_D     #*string != *word
	addi $a1, $a1, 1                #word++
	addi $a2, $a2, 2                #string += 2
	add $a2, $a2, $s2               #string = string + length
	addi $s0, $s0, 1                #line++
	addi $a3, $a3, 1                #col++
	j CONTAIN_D
NEW_STRING_D:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_D           #if (*word == '\n')
	j MINIM
MINIM:
	li $k1, 0
	la $v0, grid                    #address of grid
	sub $v0, $a2, $v0               #string - grid
	addi $k1, $s2, 1                #length + 1
	div $v0, $k1                    #(string - grid)/(length + 1)
	mfhi $v0                        #set remainder
	mflo $a0                        #set quotient
	ble $v0, $a0, MINIM_GETS        #$k1 gets the minimum between the remainder and the quotient
	move $k1, $a0
	j END_MINIM
MINIM_GETS:
	move $k1, $v0
	j END_MINIM
END_MINIM:	
	addi $v0, $s2, 2                #length + 2
	mul $v0, $k1, $v0               #minim * (length + 2)
	sub $a2, $a2, $v0               #string -= minim * (length + 2)
	sub $s0, $s0, $k1               #line -= minim
	sub $a3, $a3, $k1               #col -= minim
	j AFTER_NEW_STRING_D	
END_CONTAIN_D:
	addi $v0, $0, 10
	beq $t8, $v0, PRINT_D           #if (*word == '\n')
	j NEXT								
							
		
		
		
		
		
	
PRINT_H:
	li $k0, 1                       #ok = true
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
	li $k0, 1                       #ok = true
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
	li $k0, 1                       #ok = true
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
	beq $k0, 1, main_end            #if ok = true then do not print -1
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

