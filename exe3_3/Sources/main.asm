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
string_buffer rmb 100  ; Reserves 100 bytes of memory at location $1000



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:

SCI_setup:              
            movb  #$00,SCI1BDH     ; Sets all bits to 0 in SCI1BDH
            movb  #156,SCI1BDL     ; Sets baud rate to 9600
            movb  #$4c,SCI1CR1     ; Sets 8 bit transmission and wake up bit
            movb  #$0c,SCI1CR2     ; Enables transmission and receiving
            
            ldx   #RAMStart

; we need to wait for the RDRF to be set (to 1), so brclr will branch itself if RDRF is 0   
; until RDRF is 1, it will go to the next line to load the message         
getcSCI1:
            brclr SCI1SR1, mSCI1SR1_RDRF,getcSCI1   ; Waits for a byte to be received before moving on
            ldaa  SCI1DRL                           ; Stores received byte in register A
            staa  1,x+                              ; Stores data from A to memory location pointed by X, increments X 
            cmpa  #13                               ; Compares stored data to carriage return character
            beq done                                ; If equal to carriage return, end reading as end of string is reached
            bra getcSCI1                            ; Loop for each character in given string
 done:
        rts                                         ; Return to infinite loop to wait for next string input.
            
            
            
                       

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
