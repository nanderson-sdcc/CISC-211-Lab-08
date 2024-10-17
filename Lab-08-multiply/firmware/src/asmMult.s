/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/
    
    /* Initializing all variables to 0 */
    MOV r2, 0
    
    LDR r3, =a_Multiplicand
    STR r2, [r3]
    
    LDR r3, = b_Multiplier
    STR r2, [r3]
    
    LDR r3, =rng_Error
    STR r2, [r3]
    
    LDR r3, =a_Sign
    STR r2, [r3]
    
    LDR r3, =b_Sign
    STR r2, [r3]
    
    LDR r3, =prod_Is_Neg
    STR r2, [r3]
    
    LDR r3, =a_Abs
    STR r2, [r3]
    
    LDR r3, =b_Abs
    STR r2, [r3]
    
    LDR r3, =init_Product
    STR r2, [r3]
    
    LDR r3, =final_Product
    STR r2, [r3]
    
    /* Copy the values of r0 and r1 into multiplicand and multiplier memory */
    LDR r2, =a_Multiplicand
    STR r0, [r2]
    
    LDR r3, =b_Multiplier
    STR r1, [r3]
    
    /* Check if any values are greater than 16 bit range */
    LDR r6, =0x00007FFF @this is the upper bound for 16 bit signed int
    CMP r0, r6 @checking signed upper bound for r0
    BGT out_of_range
    
    CMP r0, 0xFFFF8000 @checking signed lower bound for r0
    BLT out_of_range
    
    LDR r6, =0x00007FFF
    CMP r1, r6 @checking signed upper bound for r1
    BGT out_of_range
    
    CMP r1, 0xFFFF8000 @checking signed lower bound for r1
    BLT out_of_range
    
    /* Store the signed values in the correct memory locations */
    MOV r2, 0b00000000000010000000000000000000 @I will use hex next time, just wanted to see if this works
    TST r0, r2
    BEQ is_a_zero_a @checking if 16th bit is zero or not for a
    BNE is_a_one_a

check_b_sign:
    MOV r2, 0x00008000 @same comparison as with a (i used hex here though to make it more readable)
    TST r1, r2
    BEQ is_a_zero_b
    BNE is_a_one_b
    
is_a_zero_a:
    /* This directive assigns the sign for a in memory as positive and saves the absolute value*/
    LDR r2, =a_Sign
    MOV r3, 0
    STR r3, [r2]
    
    LDR r2, =a_Abs @store the absolute value of r0
    STR r0, [r2]
    
    B check_b_sign
    
is_a_one_a:
    /* This directive assigns the sign for a as negative in memory and saves the absolute value */
    LDR r2, =a_Sign
    MOV r3, 1
    STR r3, [r2]
    
    @Doing 2's compliment backward to get abs value
    EOR r4, r0, 0xFFFFFFFF @flip the bits
    ADD r4, r4, 1 @add 1
    
    LDR r5, =a_Abs
    STR r4, [r5]
    
    B check_b_sign
    
is_a_zero_b:
    /* This directive assigns the sign for b as positive in memory and stores the absolute value*/
    LDR r2, =b_Sign
    MOV r3, 0
    STR r3, [r2]
    
    @store the absolute value (easy since it is positive)
    LDR r4, =b_Abs
    STR r1, [r4]
    
    B check_product_sign
    
is_a_one_b:
    /* This directive assigns the sign for b as negative in memory and stores the absolute value */
    LDR r2, =b_Sign
    MOV r3, 1
    STR r3, [r2]
    
    @Doing 2's compliment backward to get abs value
    EOR r4, r1, 0xFFFFFFFF @flip the bits
    ADD r4, r4, 1 @add 1
    
    LDR r5, =b_Abs
    STR r4, [r5]
    
    B check_product_sign

check_product_sign:
    /* This directive handles the product sign of the two numbers */
    @first, check if either input was zero, since the output should be treated as positive if so
    CMP r0, 0
    BEQ output_is_positive
    CMP r1, 0
    BEQ output_is_positive
    
    LDR r2, =a_Sign @get the sign bits from both
    LDR r3, =b_Sign
    LDR r4, [r2]
    LDR r5, [r3]
    
    CMP r4, r5
    BEQ output_is_positive @same signs = positive output
    BNE output_is_negative
    
output_is_positive:
    MOV r2, 0
    LDR r3, =prod_Is_Neg
    STR r2, [r3]
    B multiply_setup
    
output_is_negative:
    MOV r2, 1
    LDR r3, =prod_Is_Neg
    STR r2, [r3]
    B multiply_setup   

out_of_range:
    /* This directive is responsible for setting rng_error to 1 if the inputs were
     out of the 16bit signed range */
    LDR r2, =rng_Error
    MOV r3, 1
    STR r3, [r2]
    B done
 
multiply_setup:
    /* This directive does the shift and add process for the absolute value of the numbers */
    LDR r2, =a_Abs
    LDR r0, [r2] @absolute of a is stored in r0
    
    LDR r2, =b_Abs
    LDR r1, [r2] @absolute of b is stored in r1
    
    MOV r2, 0 @set running sum as 0
    MOV r3, 16 @set a loop counter

multiply_loop:
    @product will be stored in r2
    @loop coutner is stored in r3
  
    @check LSB of multiplier
    TST r1, 1
    BEQ no_add @if it is a 0, do not add anything
    
    ADD r2, r0, r2

no_add:
    /* Since we don't add, we finish our shifts before looping again */
    LSL r0, r0, 1
    LSR r1, r1, 1
    
    SUBS r3, r3, 1 @decrement the counter by 1
    BEQ finished_multiplying @finish program is counter is 0
    B multiply_loop @go back to multiply loop otherwise
    
finished_multiplying:
    /* Done multiplying, so now we clean up and store the results */
    LDR r4, =init_Product @storing initial product
    STR r2, [r4]
    
    @check if result should be + or -
    LDR r4, =prod_Is_Neg
    LDR r5, [r4]
    CMP r5, 0
    BGT negative_answer
    
    @if not a negative answer, store the final product
    LDR r6, =final_Product
    STR r2, [r6]
    MOV r0, r2
    B done
    
negative_answer:
    @convert our answer in r2 to a negative
    EOR r2, r2, 0xFFFFFFFF
    ADD r2, r2, 1
    
    @ set final answer
    LDR r6, =final_Product
    STR r2, [r6]
    MOV r0, r2
    B done
    
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




