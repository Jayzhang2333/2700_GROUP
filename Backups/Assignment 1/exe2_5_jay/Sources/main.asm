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
 ;just till five follows with a null which is empty
 ; 0 1 2 3 4 5 null
LOOKUP_NUM     DC.B    $3F, $30, $5B, $4F, $66, $6D, $00
TAIL_STEP EQU 6
;reverse direction led layout
LOOKUP_LED       DC.B    $07, $0B, $0D, $0E
DISP_STRING      RMB     4
NUM_WORDS        EQU     4
step_counter     DC.B    $01
;LENGTH           EQU     4
;FILL POSITION IS THE POSITION INDEX OF THE CURRENT LEETER TO BE FILLED INTO THE STIRNG
;IT IS INITIALISED AS 00
Fill_Position       DC.B    $00
X_Position       DC.B    $01
; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
            LDAA  #$FF            ; Load register A with all ones.
            LDAB  #$00  
            STAA  DDRB
            STAA  DDRP            
            STAA  DDRJ
            ldx #LOOKUP_NUM          
mainLoop:
        
 
;*************************Below is load string function*********************************************** 
LOAD_STRING:
            
            ldy #DISP_STRING
            ldaa step_counter
            cmpa  #$04
            
            blo  less_than_4
            ldaa #NUM_WORDS
            bra  greater_equal_4

less_than_4:
            pshx
            pshy
l4_loop:  
            ldab  X
            stab  Y
            iny
            dex
            dbne A, l4_loop
            
            inc  step_counter
            puly
            pulx
            inx
            INC X_Position
            bra SHOW_STRING
            
greater_equal_4:
            pshx
            pshy
            ;THE FIRST LETTER TO BE FILLED SHOULD BE THE CURRENT X
            ldab X_Position
            stab Fill_Position

g4_loop:            
            ldab  X
            stab  Y
            iny
            dex
            dec Fill_Position
            ;IF THE FILL POSITION IS EQUAL TO 0, WE NEED TO CHANGE IT TO THE END OF THE STRING
            beq   use_back
            dbne A, g4_loop

             
use_back:
         
         ;I don't know why index addressing has error here, 6,#LOOPUP_NUM
         ldx  #LOOKUP_NUM+TAIL_STEP
         ;MOVE FILL POSITION TO THE END, TRY TO USE A EQU HERE
         ldab  #$07
         stab  Fill_Position
         ;make sure we don't overflow A
         cmpa  #$00
         beq   done
         dbne A, g4_loop   
            
done:       
            puly
            pulx
            ldab  X
            beq back_x
            inx
            INC X_Position
            bra SHOW_STRING



back_x:
        ldx #LOOKUP_NUM
        ldab #$01
        stab X_Position
        bra SHOW_STRING 

;*****************************************************************************************


        
;**************below is the display function********************************************        
SHOW_STRING:
            pshx ;1
            ;TO DISPLAY FOR 0.5 SECOND
            ldx    #744
show_cycle: DBNE X, inf_loop
            pulx ;1
            bra LOAD_STRING

inf_loop    pshx  ;2
            LDX   #DISP_STRING   
            LDY   #LOOKUP_LED     ; Load index pointers X and Y with the initial address of the look up tables.
            LDAA   #NUM_WORDS + 1 ; Load a register as number of words
            
DISP        DBNE  A, DISP_LETTER
            pulx  ;2
            BRA   show_cycle      ; For four times, each time we first increase both Y and X index by one (pointing to the next letter / LED), then enable the respective LED     
                                  ; After one complete cycle, do it again.   
            
DISP_LETTER LDAB  Y               ; Load register B as the CONTENT IN MEMORY POINTED BY Y (LED state)
            STAB  PTP             ; Store the info into Port P to enable selected LEDs
            LDAB  X               ; Load register A as the CONTENT IN MEMORY POINTED BY X (Decoded letter)
            STAB  PORTB           ; Store the info into port B to light up the LED
                        
            PSHA 
            pshb 
            LDD    #4000                ; Preserve the A register before BSR as it will change the value of registers
            BSR   refresh_DELAY           ; Delay 0.5 ms
            pulb
            PULA
            
            INX
            INY                   ; After the display, we increase one to both X and Y pointer in order to point to the next char.
            BRA   DISP            
            
            
refresh_DELAY       
            dbne D, refresh_DELAY
            RTS                   ; Delay 0.5 ms £¨See calculation on labbook)   

;**********************************************************************************************

 


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
