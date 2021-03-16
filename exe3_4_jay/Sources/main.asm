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


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts

SCI_setup:              
            movb  #$00,SCI1BDH
            movb  #156,SCI1BDL
            movb  #$4c,SCI1CR1
            movb  #$0c,SCI1CR2
            
            
;*****************************read from seria****************************
; we need to wait for the RDRF to be set (to 1), so brclr will branch itself if RDRF is 0   
; until RDRF is 1, it will go to the next line to load the message         
getcSCI1:
            ldx   #RAMStart
read:       brclr SCI1SR1, mSCI1SR1_RDRF,read
            ldaa  SCI1DRL
            staa  1,x+
            ;compare with the ASCII carriage sign
            cmpa  #$13
            beq writecSCI1
            bra read           


;**************************write to serial**************************                                      
writecSCI1:
           ldx #RAMStart


Read_char:  
            ldaa 1,x+             ; First, load the A register with the value inside memory address pointed by x, and then add 1 to X for later operations
            beq delay_done             ; Checking. IF THE CURRENT MEMORY IS 0 (NULL), this means the end of string, delay and go abck to the start
            jsr write_char        ; If the current memory is not 0 (NULL), go to write the character
            bra Read_char         ; After writing the character, go back to read the second character    

write_char:    
            brclr SCI1SR1,mSCI1SR1_TDRE,write_char      ; if the TDRE flag is cleared, indicating that the DRL is not cleared, loop back again to keep sending data. else, go on
            staa SCI1DRL                                ; Store the bits in register A into the data register
            rts         
            
delay_done:
        jsr delay
        bra getcSCI1
           
        
        
 ; one second delay
delay:
          pshx
          pshy
          ; <your code goes here>
          ;
          ldx #60000
          ldy #50
          
inner_loop:
            psha  ;push requires 2 cycle
            pula  ; pull requires 3 cycle
            dbne x, inner_loop ;dbne requires 3 cycle
            
            ldx #60000
            dbne y, inner_loop
          
          puly
          pulx  
          rts		; return from subroutine         
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
