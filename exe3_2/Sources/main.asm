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
string_buffer rmb 100  ; Reserve 100 bytes of memory for string 

; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1         ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:
           
SCI_setup:              
            movb  #$00,SCI1BDH      ; Set all bits in SCI1BDH to 0
            movb  #156,SCI1BDL      ; Set baud rate to 9600
            movb  #$4c,SCI1CR1      ; Sets 8 data bits and wake up bit    
            movb  #$0c,SCI1CR2      ; Enables transmitter and receiver
            
            ldx   #RAMStart         ; Load x with memory address $1000, where our string buffer is located

; we need to wait for the RDRF to be set (to 1), so brclr will branch itself if RDRF is 0   
; until RDRF is 1, it will go to the next line to load the message         
getcSCI1:
            brclr SCI1SR1, mSCI1SR1_RDRF,getcSCI1   ; Polling, checking for receiving bit to be set to continue
            ldaa  SCI1DRL                           ; Loads character from serial to register A
            staa  1,x+                              ; Stores value in A to location pointed by X (in string buffer)
            bra getcSCI1                            ; Goes to read next character
            
            
            
                        
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
