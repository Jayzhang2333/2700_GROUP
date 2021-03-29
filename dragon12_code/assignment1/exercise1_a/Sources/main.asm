;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data

; variable/data section

            ORG RAMStart
 ; Insert here your data definition.
output_string   ds.b 16 ; allocates 16 bytes to the address of output string
input_string    fcc "Hello World"; string to be altered
end_sign        dc.b 0 ; set end sign after string 
test_hex        ds.b 1 ; one byte to store the hex code for the bit mask
test_count      ds.b 1;  one byte to store the count 
string_length   ds.b 1; one byte for string length
 

; code section
            ORG    ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI
            
                                 ; enable interrupts
                                 
            ldx #input_string           ; load string to register x

            
            

mainLoop:

            ldaa #$20     ; load bit mask into A
            staa test_hex   ; store in test_hex
            
            ldaa  #0
            staa test_count ; store test_count as 0
            
            ldaa #$10 ; store the value 16 as length of string
            staa string_length
            
            ldy #output_string  
             
            
            
innerLoop:
            ldab 1,X+             ;load to B value in register X and increment by 1 on next loop
            
            ;cmpb #$00
            
            ;bne mainLoop
            
            ; to change from upper to lower case,change the 32_bit to be 1
            
            orab test_hex ; perform an OR operation to change bit 32 to be 1 of the value in B
            
            stab 0,y ; store new value in B into y
            
            inc test_count ; incerement test_count
            
            iny ; increment y
            
            ;deca ;decrement a 
            
            
            
            bne innerLoop
            
            bra mainLoop ; return to main loop
            
            
upper2lower:

upper:
            


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
