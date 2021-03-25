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
LOOKUP_NUM       DC.B    $3F, $30, $5B, $4F, $66, $6D, $7D, $07, $7F, $67 
LOOKUP_LED       DC.B    $0E, $0D, $0B, $07
;here we use 0,1,2,3 as exmple.
NUM_CHR        EQU     4



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
            STAA  DDRJ
            ;DDRH should be input, which is set to be #$00, but due to the simulation, 
            ;here we are setting it to output #$FF
            STAB  DDRH            ; configure port H as input
            ;Do we need to ground port P to enable 7_seg?
            STAB  PTP             ;Enable 7-seg
            STAB  PTJ
            clra
            LDX #LOOKUP_NUM
            LDY #LOOKUP_LED
 
 
 
            
press_change:
            ;LDAB  Y               ; Load register B as the CONTENT IN MEMORY POINTED BY Y (LED state)
            ldab #$0E
            STAB  PTP             ; Store the info into Port P to enable selected LEDs 
display:      
            LDAB  X               ; Load register A as the CONTENT IN MEMORY POINTED BY X (Decoded letter)
            STAB  PORTB  
            ldab PTH
            jsr delay
            ;by pressing the button, that bit is changed into low 0
            ;therefore compared with 11111110 is checking the last button whether is being pressed
            cmpb #$FE
            beq  Next
            bra display    
Next:
           ;here I use compare A with 4 to determine the end of string
            ;because I want to avoid z be set to 1 because of accumulator b
            adda  #$01
            inx
            cmpa  #NUM_CHR-1
            bhi back
            bra display 
            
back:
            clra
            ldx #LOOKUP_NUM
            bra display 



;************************one second delay******************************            
delay:  
          psha
          pshx
          pshy
          ldx #6000
          ldy #50
          
inner_loop:
            psha  ;push requires 2 cycle
            pula  ; pull requires 3 cycle
            dbne x, inner_loop ;dbne requires 3 cycle
            
            ldx #6000
            dbne y, inner_loop
            
          
          puly
          pulx
          pula 
          rts		; return from subroutine
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
