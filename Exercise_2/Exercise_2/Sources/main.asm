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
Counter     DS.W 1
FiboRes     DS.W 1


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
            ; Create definitions for string
            Number: FCC "1234"
            

mainLoop:


        ldx #Number ; Point to string
        
loop: 
        
        ldaa X ; Store what is pointed by x to accumulator A
        inx ; increment address stored in x to get next value
        bsr delay ;delay 1 sec
        bra loop ; Continue incrementing through memory addresses
        

        
delay:
          ; <your code goes here>
          ldy #60000
          ldab #50
          
inner_loop:
          psha                ; push requires 2 cycles
          pula                ; pull request takes 3 cycles
          dbne y, inner_loop  ; dbne takes 3 cycles 
          
          ldy #60000
          dbne b, inner_loop 
          
          ;
          rts		; return from subroutine, back to main
        
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
