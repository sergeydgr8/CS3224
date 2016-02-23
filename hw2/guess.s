#####################################
#  Dylan Perera and Sergey Smirnov  #
#  CS 3224, NYU Poly. Spring 2016.  #
#           Homework 2.             #
#####################################

.code16                 # Use 16-bit assembly
.globl start            # This tells the linker where we want to start executing

#
#   Start of the program: initial setup of screen.
#
start:
    movw $prompt, %si   # load the offset of our message into %si
    movb $0x00, %ah     # 0x00 - set video mode
    movb $0x03, %al     # 0x03 - 80x25 text mode
    int $0x10           # call into the BIOS

#
#   Number generation using CMOS clock and division. The number is stored into
#   register BH. This is put at the top of the program so that it is never
#   called more than once.
#
generate_num:
    movb $0x00, %bh     # we zero out the register where we want to store our random number
    movb $0x00, %al     # send 0x00 to get seconds (closest-to-random element)
    out %al, $0x70      # send it to port 0x70 to signal that we want seconds form the CMOS clock
    in $0x71, %al       # get the output from 0x71 and put the seconds data into %al
    movb $0x0A, %bh     # set the divisor to decimal 10, so that remainder is between 0 and 9
    div %bh             # DIVIDE %al has the quotient, %ah has the remainder    
    movb %ah, %bh       # move the random number to %bh to free up %al and %ah

#
#   Printing the characters on the screen.
#
print_char: 
    lodsb               # loads a single byte from (%si) into %al and increments %si
    testb %al, %al      # checks to see if the byte is 0, (i.e. it's done printing the prompt).
    jz user_input       # if so, jump out (jz jumps if ZF in EFLAGS is set)
    movb $0x0E, %ah     # 0x0E is the BIOS code to print the single character
    int $0x10           # call into the BIOS using a software interrupt
    jmp print_char      # go back to the start of the loop to print the next character.

#
#   Getting user input.
#
user_input:
    movb $0x00, %ah     # we are setting AH to zero to start reading user input
    int $0x16           # interrupting at 16 to read in a single character
    movb $0x0E, %ah     # moving the input into register AH
    int $0x10           # calling into the BIOS
    sub $0x30, %al      # subtracting 0x30 from register AL
    cmp %bh, %al        # we compare BH with AL
    jne not_equal       # if BH and AL are not equal, we jump to not_equal instructions.

#
#   Function for when the user guesses the number correctly.
#
equal:
    movw $right, %si    # we move the value located at 'right' into %si
    movb $0x0D, %al     # moving the cursor to the beginning of the line
    movb $0x0E, %ah     # 0x0E is the BIOS code to print the single character
    int $0x10           # interrupting at 10, calling into BIOS
    movb $0x0A, %al     # moving the cursor to a new line
    int $0x10           # interrupting at 10, calling into BIOS

#
#   Ending the game after user guesses correctly & runs 'done'.
#
end_game:
    lodsb               # loads a single byte from (%si) into %al and increments %si
    testb %al, %al      # checks to see if the byte is 0
    jz done             # if so, jump out (jz jumps if ZF in EFLAGS is set)
    movb $0x0E, %ah     # 0x0E is the BIOS code to print the single character
    int $0x10           # call into the BIOS using a software interrupt
    jmp end_game        # go back to the start of the loop

done: 
    jmp done            # loop forever.

#
#   Function for when user guesses the number incorrectly.
#
not_equal:
    movw $wrong, %si    # we move the value located at 'wrong' into %si
    movb $0x0D, %al     # moving the cursor to the beginning of the line
    movb $0x0E, %ah     # 0x0E is the BIOS code to print the single character
    int $0x10           # interrupting at 10, calling into BIOS
    movb $0x0A, %al     # moving the cursor down one line
    int $0x10           # interrupting at 10, calling into BIOS

#
#   Output for when the user incorrectly guesses.
#
output_wrong:
    lodsb               # loads a single byte from (%si) into %al and increments %si
    testb %al, %al      # checks to see if the byte is 0
    jz try_again        # if so, jump out (jz jumps if ZF in EFLAGS is set)
    movb $0x0E, %ah     # 0x0E is the BIOS code to print the single character
    int $0x10           # call into the BIOS using a software interrupt
    jmp output_wrong    # loops back to the start of this function.

try_again:
    movw $prompt, %si   # moving the prompt into %si
    movb $0x0D, %al     # Moving the cursor to the beginning of the line
    movb $0x0E, %ah     # printing a single character
    int $0x10           # calling into BIOS
    movb $0x0A, %al     # moving the cursor down one line
    int $0x10           # calling into BIOS
    jmp print_char      # jumping back to the beginning of the program to have user guess a number.

#
# The .string command inserts an ASCII string with a null terminator.
# The names are self-explanatory.
#
prompt:
    .string    "What number am I thinking of (0-9)? "
wrong:
    .string    "Wrong!"
right:
    .string    "Right! Congratulations."

# This pads out the rest of the boot sector and then puts
# the magic 0x55AA that the BIOS expects at the end, making sure
# we end up with 512 bytes in total.
# 
# The somewhat cryptic "(. - start)" means "the current address
# minus the start of code", i.e. the size of the code we've written
# so far. So this will insert as many zeroes as are needed to make
# the boot sector 510 bytes log, and 

.fill 510 - (. - start), 1, 0
.byte 0x55
.byte 0xAA
