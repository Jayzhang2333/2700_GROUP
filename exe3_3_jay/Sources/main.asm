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
string_buffer rmb 100



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:

SCI_setup:              
            movb  #$00,SCI1BDH
            movb  #156,SCI1BDL
            movb  #$4c,SCI1CR1
            movb  #$0c,SCI1CR2
            
            ldx   #RAMStart

; we need to wait for the RDRF to be set (to 1), so brclr will branch itself if RDRF is 0   
; until RDRF is 1, it will go to the next line to load the message         
getcSCI1:
            brclr SCI1SR1, SCI1SR1_RDRF,getcSCI1
            ldaa  SCI1DRL
            staa  1,x+
            ;compare with the ASCII carriage sign
            cmpa  #$13
            beq done
            bra getcSCI1
 done:
        rts           
            
            
            
                       

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
