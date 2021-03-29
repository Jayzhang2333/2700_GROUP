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
input_string    fcc "Hello World"; string to be altered   
return_char dc.b 13,0 ; set 1 byte for the return character to come after string

; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:

        ; configure the serial port
        
        movb #$00, SCI1BDH  ;set baud rate to 9600
        movb #156, SCI1BDL ;
        movb #$4C, SCI1CR1  ; select 8 data bits, address mark wake-up
        movb #$0C, SCI1CR2   ; enable transmitter and receiver
        
        bsr delay
        
        ldx #input_string ; load string to register x


innerLoop:
        
        ldaa 1,x+ ;load to A character in X and point to next character
                
        jsr putcSCI1 ;jump to subroutine
          
        ;cmpa return_char  ;check if the next character is the return character
        
        beq mainLoop 
        
        bra innerLoop
        
        
        
putcSCI1:
              
        brclr SCI1SR1, mSCI1SR1_TDRE,* ; wait for TDRE to be set
        
        staa SCI1DRL ; output character
                
        rts
        
delay:
          ldx #60000
          ldy #50
          
delay_loop:
          psha                ; push requires 2 cycles
          pula                ; pull request takes 3 cycles
          dbne x, delay_loop  ; dbne takes 3 cycles 
          
          ldx #60000
          dbne y, delay_loop 
          
          ;
          rts		; return from subroutine



;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
