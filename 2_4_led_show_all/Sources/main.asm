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
;LOOKUP_NUM     DC.B    $3F,$06, $5B, $4F, $66, $6D, $7D, $07, $7F, $67
LOOKUP_NUM      dc.b   $5B, $07, $3F, $3F ;They are "2700" 
LOOKUP_LED       DC.B    $0E, $0D, $0B, $07 ;7-Seg locations on port P
NUM_WORDS        EQU     4     ;We only display 4 numbers (Max 4)



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                   ; enable interrupts
mainLoop:
            LDAA  #$FF            ;Load register A with all ones.
            LDAB  #$00            ;Load register B with all zeros.
            STAA  DDRB            ;Configure port B,P,J as outputs
            STAA  DDRP            
            STAA  DDRJ            
            STAB  PTJ             ;Enable 7-Segs and LEDs under 7-Segs
            STAB  PTP
            


;***************************DISPLAY FUNCTION********************************************
;Inputs: Display String, 7-Segs location on port p
;Outputs: 7-Segs display the whole string  
inf_loop    LDX   #LOOKUP_NUM   
            LDY   #LOOKUP_LED     ; Load index pointers X and Y with the initial address of the look up tables.
            LDAA   #NUM_WORDS + 1 ; Load a register as number of words, plus one because we are using dbne A
                                  ; and we want 0 to be the stop branching condition
            
DISP        DBNE  A, DISP_LETTER  ;Keep branching to display the current number if A is not 0
            BRA   inf_loop        ;If finish display all 4 numbers, branch back to inf_loop and start a new cycle     
                                     
            
DISP_LETTER LDAB  Y               ; Load register B as the CONTENT IN MEMORY POINTED BY Y (LED state)
            STAB  PTP             ; Store the info into Port P to enable selected LEDs
            LDAB  X               ; Load register B as the CONTENT IN MEMORY POINTED BY X (Decoded number)
            STAB  PORTB           ; Store the info into port B to light up the LED
                       
            PSHA                  ;Stack values in A and B to avoid being changed by the delay
            pshb 
            LDD    #4000          ;Loop 4000 times is about 0.5 ms
            BSR   DELAY           ;Delay 0.5 ms
            pulb                  ;Pull values for A nad B from stack
            PULA                  ;BE CAREFUL!!! FILO!!!
            
            INX
            INY                   ; After the display, we increasS both X and Y pointer in order to point to the next number.
            BRA   DISP            
;**************************0.5 ms delay**********************************************            
            
DELAY       
            dbne D, DELAY
            RTS                   ; Delay 0.5 ms 
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
