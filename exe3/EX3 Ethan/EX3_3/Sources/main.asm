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

            ORG RAMStart ; Starts location pointer at $1000
 ; Insert here your data definition.

buffer rmb 100 ; Sets aside 100 bytes of memory under label


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
            
            ; Set the baud rate to 9600 using formula
            ; Module Clock / (16*BR) (BR = baud rate) (24MHZ for clock)
            ; Result is 156.25 = 156 and only requires 8 bits
            ; Hence, set SCIBHD to zeros and SCIBDL to 156 in binary
            ; Use SCI1 for output to computer
            movb #$00, SCI1BDH  ; Setting bits 0-4 to LOW
            movb #156, SCI1BDL  ; Setting Baud Rate close to 9600
            
            
            movb #$4C, SCI1CR1 ; Enables 9 bit word length and wake bit. Turns loop bit on as well
            movb #$0C, SCI1CR2 ; Enables both transmitter and reciever bits on SCI1
            
main:
            ldx #buffer ; Starts location pointer at $1000
            
get_char:
            brclr SCI1SR1, mSCI1SR1_RDRF, get_char ; Will check if recieving bit is set. If not set then continue
            ldaa SCI1DRL ; Get character from SCI register. Only need lower one for 8 bits
            
            cmpa #13 ; Compare character to carriage return value
            beq return ; Return from function
            
            
            staa 1, x+   ; Store character in buffer
            bra get_char ; Loop
            
            ; If RDRF is 0, get_char will loop itself. If set to 1 it will proceed to read the character and store it
return:
            staa x
            ;rts ; Return from function
            bra main            
            

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
