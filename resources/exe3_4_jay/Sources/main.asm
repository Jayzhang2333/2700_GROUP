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
 buffer rmb 100


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts

SCI_setup:              
            movb  #$00,SCI1BDH       ; Set bits in SCI1BDH to 0
            movb  #156,SCI1BDL       ; Sets baud rate to 9600
            movb  #$4c,SCI1CR1       ; Sets 8 bit data and wake up bit
            movb  #$0c,SCI1CR2       ; Enables transmissions and receiving
            
            
;*****************************read from seria****************************
; we need to wait for the RDRF to be set (to 1), so brclr will branch itself if RDRF is 0   
; until RDRF is 1, it will go to the next line to load the message         
getcSCI1:
            ldx   #RAMStart                     ; Loads X with address $1000 where string buffer is located
read:       brclr SCI1SR1, mSCI1SR1_RDRF,read   ; Waits for a byte to be received to continue
            ldaa  SCI1DRL                       ; Stores received byte to register A
            staa  1,x+                          ; Stores in X, increments X
            cmpa  #13                           ; Compares value with carriage return
            beq writecSCI1                      ; If equal, finished reading from serial. Branch to write
            bra read                            ; Loop for each character in the string




;**************************write to serial**************************                                      
writecSCI1:
           ldx #RAMStart


Read_char:  
            ldaa 1,x+               ; Load register A with value in location pointed by X, increment X
            cmpa #13
            beq delay_done          ; If equal to carriage return, reset program with a delay  
            jsr write_char          ; Jump to write function
            bra Read_char           ; After writing, read the next character                                                  

write_char:    
            brclr SCI1SR1,mSCI1SR1_TDRE,write_char      ; Wait untill SCI1DRL is cleared to transmit the next byte to serial
            staa SCI1DRL                                ; Store the bits in register A into register A
            rts                                         ; Return from subroutine
            
delay_done:
        jsr write_char                                  ; Jump to write function to write carraige return to serial
        ;jsr delay
        bra getcSCI1                                    ; Reset program, wait for next string
           
        
        
;*****************************one second delay*****************************
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
