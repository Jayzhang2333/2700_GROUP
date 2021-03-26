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
table       DC.B    $0E, $0D, $0B, $07   ;7-Seg locations on port P
                 
            ORG RAMStart
 ; Insert here your data definition.



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
            
            
Config_PORTS:
       
            LDAA  #$FF            ; Load register A with all ones.
            LDAB  #$00            ; Load register B with all zeros.
            STAA  DDRB            ; Configure port B,P,J as outputs
            STAA  DDRP            
            STAA  DDRJ
            STAB  PTP             ; Enable 7 segments
            STAB  PTJ             ; Enable LEDS on 7 segs
            
            
main:       ; For this we will choose the pattern 1,3,5,7
            LDX   #table   ; X picks which 7 seg is enabled at one time
            
display:    
            ldaa X         ; Load 7 segment to enable
            staa PTP       ; Enable first 7 segment
            ldab #$3F      ; Load '1' to 7 segment
            stab PORTB 
            jsr  delay     ; Short delay
            clr  PORTB     ; Clear PORTB
            inx            ; increment x
            
            ldaa X         ; Load 7 segment to enable
            staa PTP       ; Enable first 7 segment
            ldab #$5B      ; Load '3' to 7 segment
            stab PORTB 
            jsr  delay     ; Short delay
            clr  PORTB     ; Clear PORTB
            inx            ; increment x
            
            ldaa X         ; Load 7 segment to enable
            staa PTP       ; Enable first 7 segment
            ldab #$66      ; Load '5' to 7 segment
            stab PORTB 
            jsr  delay     ; Short delay
            clr  PORTB     ; Clear PORTB
            inx            ; increment x
            
            ldaa X         ; Load 7 segment to enable
            staa PTP       ; Enable first 7 segment
            ldab #$7D      ; Load '7' to 7 segment
            stab PORTB 
            jsr  delay     ; Short delay
            clr  PORTB     ; Clear PORTB
            inx            ; increment x
            
            bra  main
            
;-------------------------------------------------------------------;            
            
delay:    ; Short delay function
          psha
          pshx
          pshy
          ldx #600
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
