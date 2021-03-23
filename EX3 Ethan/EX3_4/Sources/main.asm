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
buffer rmb 100 ; Set input buffer to 100 bytes


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
Bit_Setting:
            movb #$00, SCI1BDH    ; Set bits to zero
            movb #156, SCI1BDL    ; Set baud rate to 9600
            movb #$4C, SCI1CR1    ; Set 8 bit word length, and wake up bit
            movb #$0C, SCI1CR2    ; Enable SCI transmission and recieving bits
            
Start:
            ldx #buffer         ; Start at $1000, where buffer is located
            jsr Input             ; Allow user input to terminal
            ; Now user should be completed with inputs
            ; Reset x to point to the start of tbe input string
            ldx #buffer
            jsr Read ; 'Read' what was input
            jsr Delay
            bra Start ; Start again
            
Input:      
            brclr SCI1SR1, mSCI1SR1_RDRF, Input ; If something has not been received then loop until something is received
            ldaa SCI1DRL ; When recieved transmission, store character in register A
            staa 1,x+ ; Store in location pointed by x, increment x
            ; Compare with carriage sign
            cmpa #$0D
            beq return
            bra Input ; If no carriage return then loop for more input characters
            
return: 
            rts ; Return from subroutine  
                        
            
Read:
            ldaa 1,x+   ; Load character pointed by X and increment x
            cmpa #$0D
            beq Write   ; If NULL return to main program, after writing the newline character
            jsr Write   ; If not NULL write character to serial  
            bra Read    ; Loop until all characters are read
                                
Write:
            brclr SCI1SR1, mSCI1SR1_TDRE, Write ; Check if there has been a transmission. If so then go to next step
            staa SCI1DRL    ; Write to serial
            rts             ; Return to read function
            
            
Delay:
            pshx
            pshy
            ldx #60000
            ldy #50
Inner:
            dbne x, Inner
            ldx #60000
            dbne y, Inner
            pulx
            puly
            rts                         


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
