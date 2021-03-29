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
;test_string     fcc "Hello World"; string to be altered   
;return_char     dc.b 13,0 ; set 1 byte for the return character to come after string
;function_char   fcb $41 ; set 1 byte for char to choose which function to run
string_buffer   rmb 100 ; reserve 100 bytes for the string sent from serial


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
setup:

        ; configure the serial port
        
        movb #$00, SCI1BDH  ;set baud rate to 9600
        movb #156, SCI1BDL ;
        movb #$4C, SCI1CR1  ; select 8 data bits, address mark wake-up
        movb #$0C, SCI1CR2   ; enable transmitter and receiver
        
        
        ;ldx #test_string ; load string to register x
        
        
mainLoop:
        bsr delay
        
        ldx #RAMStart; set X to be start of RAM
        
        jsr getcSCI1; jump to function to read serial input
        
        ldx #RAMStart; reset X to be start of RAM
        
        jsr putcSCI1; jump to function to output serial input
        
        bra mainLoop;  
        
 
        
        
        
putcSCI1:

        ldaa 1,x+ ;load to A character in X and point to next character
              
        brclr SCI1SR1, mSCI1SR1_TDRE,* ; wait for TDRE to be set. * means to jump back to same address
        
        staa SCI1DRL ; store into SCI1DRL character character in a
        
        bne putcSCI1; loop back to start of function if end of string not reached
        
        rts
                
        
        
getcSCI1:
        brclr SCI1SR1, mSCI1SR1_RDRF,* ; wait for RDRF to be set
        
        ldaa SCI1DRL ; load character to A
        
        staa 1,x+ ; store the character into register X and point to next space
        
        cmpa #$0D ; character the next character to the return character
        
        bne getcSCI1 ; loop through function until return carriage found
        
        ;bne getSCI1 ; branch to start of function if characters still to read
        
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
