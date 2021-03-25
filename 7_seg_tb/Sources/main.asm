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

 ifdef _HCS12_SERIALMON
            ORG $3FFF - (RAMEnd - RAMStart)
 else
            ORG RAMStart
 endif
 ; Insert here your data definition.


; code section
            ORG   ROMStart


Entry:
_Startup:
         LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:
            LDAA  #$FF            ; Load register A with all ones.
            LDAB  #$00  
            STAA  DDRB
            STAA  DDRP            
            STAA  DDRJ            ; Set port B,P, J as outputs
            ;LDD   #4000           ; Load register D as 4000 for 0.5ms delay

            ;$0E, $0D, $0B, $07
            ;$ff $df
            LDAB  #$07               ; Load register B as the CONTENT IN MEMORY POINTED BY Y (LED state)
            STAB  PTP 
            ldaa #$DF
            staa PORTB

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
