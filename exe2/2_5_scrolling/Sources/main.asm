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
LOOKUP_NUM       DC.B    $3F, $30, $5B, $4F, $66, $6D, $00  ;These are 012345 and empty, this is the whole string
TAIL_STEP        EQU     6 ;There are 6 steps between the front of the string to the tail of the string
LOOKUP_LED       DC.B    $07, $0B, $0D, $0E ;reverse direction led layout
DISP_STRING      RMB     4 ;Reserve 4 bytes in memory for loading the string need to display
NUM_WORDS        EQU     4 
step_counter     DC.B    $01 ;This variable works like a counter to check if we are in the first 4 steps in displaying
                             ;This also stores how many numbers we need to display. If it is in the first 4 steps, we will display with some empty
;FILL POSITION IS THE POSITION INDEX OF THE CURRENT LEETER TO BE FILLED INTO THE STIRNG
;IT IS INITIALISED AS 00
;In begining of each step, it will be initialised as X_position
Fill_Position    DC.B    $00
X_Position       DC.B    $01 ;X_position stores the current index of the memory location that X is pointing to in the whole string
; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
Config_io:  LDAA  #$FF            ;Load register A with all ones.
            LDAB  #$00            ;Load register B with all zeros.
            STAA  DDRB            ;Configure port B,P,J as outputs
            STAA  DDRP            
            STAA  DDRJ
            STAB  PTJ             ;Enable 7-Segs and LEDs
            STAB  PTP
                    
        

;*************************Below is load string function*********************************************** 
Scroll:
            ldx #LOOKUP_NUM       ;Load X to the head of numbers need to display
            ldy #DISP_STRING      ;Load Y to the head of the reserved memory for display string
LOAD_STRING:
            ldaa step_counter     ;Load register A with the value in step counter           
            cmpa  #NUM_WORDS      ;Compare with the length of the string
                                  ;If it is less than, this means we need to display some emptys
            blo  less_than_4      ;Branch to Less_than_4 if less
            ldaa #NUM_WORDS       ;Make sure register A has the correct value
            bra  greater_equal_4  ;Branch to greatnter_equal_4 if not less

less_than_4:
            pshx                  ;Stack values in X nad Y into stack to reserve them
            pshy
l4_loop:  
            ldab  X               ;Load register B as the CONTENT IN MEMORY POINTED BY X (Decoded number)
            stab  Y               ;Store the loaded value to the current memory location of the display string
            iny                   ;Increment Y to the next memory location in display string
            dex                   ;Because we are loading the display string in a reverse order, the next value of number shoud be the previous one in the whole string
            dbne A, l4_loop       ;Branch this loop until A becomes zero (we finish storing all numbers)
            
            inc  step_counter     ;Increase step_counter
            puly                  ;Pull values for X and Y back from stack
            pulx
            inx                   ;Increase X to point to the next position in the whle string
            INC X_Position
            bra SHOW_STRING       ;At this stage, we finish load all the numbers, now we brach to display them
            
greater_equal_4:
            pshx                  ;Stack values in X nad Y into stack to reserve them
            pshy
           
            ldab X_Position        ;Initialise Fill_position with the value in X_position
            stab Fill_Position     ;Fill_position is just a dummy variable to X_position

g4_loop:            
            ldab  X                ;Load register B as the CONTENT IN MEMORY POINTED BY X (Decoded number)
            stab  Y                ;Store the loaded value to the current memory location of the display string
            iny                    ;Increment Y to the next memory location in display string
            dex                    ;Because we are loading the display string in a reverse order, the next value of number shoud be the previous one in the whole string
            dec Fill_Position      ;We check if there are previous number exist by decreseasing Fill_position
            beq   use_back         ;IF THE FILL POSITION IS EQUAL TO 0, this means there is no more previous numbers
                                   ;WE NEED TO CHANGE IT TO THE END OF THE STRING
            dbne A, g4_loop        ;Branch this loop until A becomes zero (we finish storing all numbers)

use_back:
         ldx  #LOOKUP_NUM+TAIL_STEP ;Point register X to the tail of the whole string
         ldab  #TAIL_STEP+1         ;Load Fill_position to the last index of the whole string
         stab  Fill_Position
         
         cmpa  #$00                 ;If register A is zero, this means the loading process has finished
                                    ;We need to ranch to done
         beq   done
         dbne A, g4_loop            ;If the loading process has not been finished,
                                    ;Branch back to the loading process    
            
done:       
            puly                    ;Pull the values of X and Y pushed before we enter the oading process from stack 
            pulx
            ldab  X                 ;Load the value pointed by X to register B
            beq back_x              ;If it is equal to zero, this means it is at the end of the whole string
                                    ;Branch to back_x to point X to the head of the string again
            inx                     ;Increase X to the next position
            INC X_Position          ;Increase X_position
            bra SHOW_STRING         ;Branch to display the loaded string on 7 Segs



back_x:
        ldx #LOOKUP_NUM             ;Load X to the head of the whoel string
        ldab #$01                   ;Load X_position to the first index of the whole string
        stab X_Position             ;Branch to display the loaded string
        bra SHOW_STRING 

;*****************************************************************************************


        
;**************below is the display function********************************************        
SHOW_STRING:
            pshx 
            ldx    #744 ;This is calculated to display for 0.5 second
show_cycle: DBNE X, inf_loop        ;DBNE X 744 time to display for 0.5 second
            pulx                    ;Pull value for x before we enter dispaly string
            bra LOAD_STRING

inf_loop    pshx  
            LDX   #DISP_STRING      ; Load index pointers X and Y with the initial address of the look up tables.
            LDY   #LOOKUP_LED     
            LDAA   #NUM_WORDS + 1   ; Load a register as number of words, plus one because we are using dbne A
                                    ; and we want 0 to be the stop branching condition
DISP        DBNE  A, DISP_LETTER    ; Keep branching to display the current number if A is not 0
            pulx                    ; Pull the value of x before we enter this display cycle from stack
            BRA   show_cycle        ; Branch back and show the string again   
                                  
            
DISP_LETTER LDAB  Y               ; Load register B as the CONTENT IN MEMORY POINTED BY Y (LED state)
            STAB  PTP             ; Store the info into Port P to enable selected LEDs
            LDAB  X               ; Load register B as the CONTENT IN MEMORY POINTED BY X (Decoded number)
            STAB  PORTB           ; Store the info into port B to light up the LED
                       
            PSHA                  ;Stack values in A and B to avoid being changed by the delay
            pshb 
            LDD    #4000          ;Loop 4000 times is about 0.5 ms
            BSR   refresh_DELAY           ;Delay 0.5 ms
            pulb                  ;Pull values for A nad B from stack
            PULA                  ;BE CAREFUL!!! FILO!!!
            
            INX
            INY                   ; After the display, we increase both X and Y pointer in order to point to the next number.
            BRA   DISP            ; Branch back to display the next number                
                       
refresh_DELAY       
            dbne D, refresh_DELAY
            RTS                     

;**********************************************************************************************

 


;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
