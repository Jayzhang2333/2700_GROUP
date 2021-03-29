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
string fcc "Who ever is marking this very handsome" ; Create a string (first character at memory $1000)
string_end dc.b 13                   ; ASCII carriage return


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
            
            
            
                  
Start:
            ldx #RAMStart ; Stores address of RAMStart, where our string begins from

Read: 
            
            ldaa 1,x+  ; Loads character pointed by x, then increments x
            cmpa #13
            beq fin  ; If the value pointed by x is NULL, terminate program
            jsr Write ; If character is not NULL, branch to write character
            bra Read   ; After writing, loop to read each character in the string

Write:
            brclr SCI1SR1, mSCI1SR1_TDRE, Write ; Uses a bitmask on bit 7 to check whether a byte has been transmitted to shift register. Branches no byte is transmitted yet
            staa SCI1DRL ; Using 8 bit data format, only lower register needs to be accessed.
            rts ; Return from subroutine after writing character

fin:   
            jsr Write
            jsr delay
            bra Start
            
            
            
delay: ; delay function
            pshx ; Store x on stack
            pshy ; Store y on stack
            ldx #50000
            ldy #60
            
inner:
            dbne x, inner ; Decrement x, if not zero then branch
            
            ldx #60000
            dbne y, inner ; Decrement y, if not zero then branch
            
            pulx ; Pull x from stack
            puly ; Pull y from stack
            rts  ; Return from delay subroutine
            

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
