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
LOOKUP_NUM     DC.B    $3F,$06, $5B, $4F, $66, $6D, $7D, $07, $7F, $67
;LOOKUP_NUM      dc.b   $3F, $5B, $6d, $66 
LOOKUP_LED       DC.B    $0E, $0D, $0B, $07
NUM_WORDS        EQU     4



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
            STAB  PTJ
            STAB  PTP
            ;LDD   #4000           ; Load register D as 4000 for 0.5ms delay


;***************************DISPLAY FUNCTION********************************************
inf_loop    LDX   #LOOKUP_NUM   
            LDY   #LOOKUP_LED     ; Load index pointers X and Y with the initial address of the look up tables.
            LDAA   #NUM_WORDS + 1 ; Load a register as number of words
            
DISP        DBNE  A, DISP_LETTER
            BRA   inf_loop        ; For four times, each time we first increase both Y and X index by one (pointing to the next letter / LED), then enable the respective LED     
                                  ; After one complete cycle, do it again.   
            
DISP_LETTER LDAB  Y               ; Load register B as the CONTENT IN MEMORY POINTED BY Y (LED state)
            STAB  PTP             ; Store the info into Port P to enable selected LEDs
            LDAB  X               ; Load register A as the CONTENT IN MEMORY POINTED BY X (Decoded letter)
            STAB  PORTB           ; Store the info into port B to light up the LED
                        
            PSHA 
            pshb 
            LDD    #4000                ; Preserve the A register before BSR as it will change the value of registers
            BSR   DELAY           ; Delay 0.5 ms
            pulb
            PULA
            
            INX
            INY                   ; After the display, we increase one to both X and Y pointer in order to point to the next char.
            BRA   DISP            
;**************************0.5 ms delay**********************************************            
            
DELAY       
            dbne D, DELAY
            RTS                   ; Delay 0.5 ms £¨See calculation on labbook)
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
