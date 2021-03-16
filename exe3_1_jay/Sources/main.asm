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
;StringStart EQU  $2000  ; absolute address to place messages for serial transmission ]

; variable/data section

            ORG RAMStart
 ; Insert here your data definition.
no_1 fcc "We are  Big Dollar Bills"                ;Store a string
no_2 dc.b 13,0         ;Decimal 13 is the ASCII carriage return, can I add a NULL as an ending sigh? 



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
             
            movb  #$00,SCI1BDH           ; 0-4 bits in high should be set to zeros
            movb  #156,SCI1BDL           ; Set Baud Rate register to 156 which will make the baud rate close to 9600, this is on textbook p455 table 9.3
            
            
            
            movb  #$4C,SCI1CR1     ;this is enable 8 data bits nad address wake up
                                   ;How to determine which bits to set?                                       
            movb  #$0C,SCI1CR2     ;both transmitor and receive are enabled, but here we just use transmitor
            bsr   delay   
                                         
Start:
           ldx #RAMStart


Read_char:  
            ldaa 1,x+             ; First, load the A register with the value inside memory address pointed by x, and then add 1 to X for later operations
            beq done             ; Checking. IF THE CURRENT MEMORY IS 0 (NULL), this means the end of string, delay and go abck to the start
            jsr write_char        ; If the current memory is not 0 (NULL), go to write the character
            bra Read_char         ; After writing the character, go back to read the second character    

write_char:    
            brclr SCI1SR1,mSCI0SR1_TDRE,write_char      
            staa SCI1DRL                                
            rts         
            
done:
          jsr delay
          bra Start            
  
            
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
