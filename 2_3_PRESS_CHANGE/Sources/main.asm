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
LOOKUP_NUM       DC.B    $3F, $30, $5B, $4F, $66, $6D, $7D, $07, $7F, $67  ;Lookup table for numbers on 7-Seg
LOOKUP_LED       DC.B    $0E, $0D, $0B, $07   ;7-Seg locations on port P
;here we use 0,1,2,3 as exmple.
NUM_CHR        EQU     4  ;We only loop through 4 numbers



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
mainLoop:
            
Config_io:  LDAA  #$FF            ;Load register A with all ones.
            LDAB  #$00            ;Load register B with all zeros.
            STAA  DDRB            ;Configure port B,P,J as outputs
            STAA  DDRP            
            STAA  DDRJ
            ;DDRH should be input, which is set to be #$00, but due to the simulation, 
            ;When runs on simulation,here we are setting it to output #$FF
            STAB  DDRH            ;Configure port H as input
            STAB  PTP             ;Enable 7-Segs and LEDs under 7-Segs
            STAB  PTJ
            clra                  ;Clear register A
            clrb                  ;Clear register B
            
;**********************Press Change function********************************
;Input: Press button of PH0, Display string, 7-Segs location on port p
;Output: 7-Segs display a new number once PH0 being pressed             
press_change:
            LDX #LOOKUP_NUM       ;Load X to the head of numbers need to display
            LDY #LOOKUP_LED       ;Load Y to the head of memory where the location of 7-Segs are stored
            LDAB  Y               ;Load register B as the CONTENT IN MEMORY POINTED BY Y (7-Seg location)
            STAB  PTP             ;Store the info into Port P to enable selected LEDs 

display:      
            LDAB  X               ;Load register B as the CONTENT IN MEMORY POINTED BY X (Hex value of numbers on 7-Seg)
            STAB  PORTB           ;Store the info into Port B 
            ldab PTH              ;Load register B with the input value of port H
            jsr delay
            ;By pressing the button, that bit is changed into low 0
            ;therefore compared with 11111110 is checking the last button whether is being pressed
            cmpb #$FE
            beq  Next             ;If true, we change to the next number
            bra display           ;Keep looping the display subroutine if button not pressed
Next:
           ;Here I use compare A with 4 to determine the end of string
            ;because I want to avoid z be set to 1 because of the comparision used in previous step
            adda  #$01
            inx   ;Point X to the next number
            cmpa  #NUM_CHR-1      ;Compare if it is the end of the 4 letters. Because we started counting from 0, so we need NUM_CHR-1
            bhi back              ;If value in A is greater than 3, we need to move X to the head again
            bra display           ;If not, keep displaying
            
back:
            clra                  ;Change A to 0
            ldx #LOOKUP_NUM       ;Load X to the head of numbers need to display
            bra display           ;Keep displaying



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
