#==========================================================
# 1D String Finder
#=========================================================================
# Finds the [first] matching word from dictionary in the grid
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

grid_file_name:         .asciiz  "1dgrid.txt"
dictionary_file_name:   .asciiz  "dictionary.txt"
newline:                .asciiz  "\n"
       
#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
#
grid:                   .space 33       # Maximun size of 1D grid_file + NULL
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
        lb   $t1, grid($t0)          
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
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
# Storing the starting index of each word in the dictionary
	li $t0, 0                       #idx = 0
	li $t1, 0                       #start_idx = 0
	li $t4, 0                       #dict_idx = 0
	li $s1, 0                       #dict_num_words = 0
STORING_LOOP:
	lb $t2 dictionary($t0)          #c_input = dictioary[idx];           
	beq $t2, $0, END_STORING_LOOP #break if(c_input == '\0')
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
	addi $s1, $t4, 0
	j STRFIND



STRFIND:
	li $t1, 0                       #grid_idx = 0
STRFIND_WHILE:
	li $t0, 0                       #idx = 0
	lb $t5, grid($t1)               #grid[grid_idx]
	beq $t5, $0, PRINT_STRING       #verify if grid[grid_idx] != '\0'
STRFIND_FOR:
	bge $t0, $s1, END_STRFIND_FOR   #if condition is false then exit for=
	lw $a1, dictionary_idx($t0)     #dictionary_idx[idx]
	move $a2, $t1                   #grid + grid_idx
	la $s3, 0($a1)
	jal CONTAIN
	beq $v0, 1, PRINT
	addi $t0, $t0, 4                #idx++
	j STRFIND_FOR



PRINT:
	li, $v1, 1
	li $v0, 1                       #print_int(grid_idx)
	add $a0, $0, $t1
	syscall
	li $a0, ' '                     #print_char(' ')
	li $v0, 11  
	syscall

PRINT_WORD:
	lb $t3, dictionary($s3)         #*word
	addi $v0, $0, 10                #newline  
	beq $t3, $v0, END_PRINT_WORD
	beq $t3, $0, END_PRINT_WORD
	li $v0, 11                      #print char
	move $a0, $t3
	syscall
	addi $s3, $s3, 1                #word++
	j PRINT_WORD

END_PRINT_WORD:
	li $a0, 10                      #print_char('\n')
	li $v0, 11
	syscall
	addi $t0, $t0, 4
	j STRFIND_FOR




END_STRFIND_FOR:
	addi $t1, $t1, 1                #grid_idx++
	j STRFIND_WHILE  

 
 
 
CONTAIN:
	lb $t3, dictionary($a1)
	lb $t4, grid($a2)
	bne $t3, $t4, END_CONTAIN       #*string != *word
	addi $a1, $a1, 1                #word++
	addi $a2, $a2, 1                #string++
	j CONTAIN
	
END_CONTAIN:
	addi $v0, $0, 10
	seq $v0, $t3, $v0
	jr $ra




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


	
	
	
