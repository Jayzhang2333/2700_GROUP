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
string_buffer rmb 100       ;Reserve a memory space for string buffer
start_mask equ %11111110    ;Mask to determine which mode 
LEDON	    equ	 $01	        ;Value to write to Port B to turn on LED
LEDOFF    equ  $00          ;Value to write to Port B to turn off LED
PTH_0      DC.B $00         ;Variable to store the value of PH0
PORT_H_MASK equ %00000001   ;Mask of port H to setup interrupt
; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

                                
SCI_setup:              
            movb  #$00,SCI1BDH    ;Configure serial port 1
            movb  #156,SCI1BDL
            movb  #$4c,SCI1CR1
            movb  #$0c,SCI1CR2

LED_setup:
            ldaa    #$FF
            staa    DDRB   ; Configure PORTB as output
            staa    DDRJ   ; Port J as output to enable LED
            ldaa    #00    ; Need to write 0 to J0
            staa    PTJ    ; to enable LEDs

Digital_setup:
            sei
            LDAA #PORT_H_MASK  ;Set up the interrupt for port H
            staa PIEH
            COMA
            STAA PPSH
            CLI
            
getcSCI1:
            ldx   #RAMStart                        ;Read input string from Serial port 1
read:       brclr SCI1SR1, mSCI1SR1_RDRF,read      ;Stop reading until carriage return character detected
            ldaa  SCI1DRL
            staa  1,x+
            cmpa  #13                              ;Compare with the ASCII carriage sign
            beq wait_mode
            bra read     
            

wait_mode:
          ldaa PTH                                 ;Initialise PTH_0 with the current value in port H
          staa PTH_0
          movb #LEDON, PORTB                       ;Turn of the LED to indicate finish reading input
          jsr delay                                ;Delay for 2 second for user to decide which mode
          movb #LEDOFF, PORTB                      ;Turn off the LED after 2 second delay
          ldaa PTH_0                               ;Load the PTH_0 value and compare with the mask that determine which mode
          cmpa #start_mask
          beq  CapWord                             ;If PH0 pressed, only capitalise the first letter
          bra  low2up                              ;If PH0 not pressed, capital all letters



writecSCI1:                                        ;This is the same serial output function created in exe3 
           ldx #string_buffer
Read_char:  
            ldaa 1,x+             ;First, load the A register with the value inside memory address pointed by x, and then add 1 to X for later operations
            cmpa #13              ;Compare with carriage return char, if it is, end outputing
            beq delay_done        
            jsr write_char        ;If the current memory is not 0 (NULL), go to write the character
            bra Read_char         ;After writing the character, go back to read the next character    

write_char:    
            brclr SCI1SR1,mSCI1SR1_TDRE,write_char      ;If the TDRE flag is cleared, indicating that the DRL is not cleared, loop back again to keep sending data. else, go on
            staa SCI1DRL                                ;Store the bits in register A into the data register
            rts         
            
delay_done:
        JSR write_char                                  ;First output the carriage return char
        BRA getcSCI1                                    ;Branch back to the getcSCI1 and read next string





up2low:                                                 ;This is the same function created in exe1 to change upper case to lower case 
        psha
loop_low:
        ldaa 0,x
        cmpa #13
        
        beq done
        cmpa #$5A
        bhi next_low
        cmpa #$41
        blo next_low
        adda #$20
        staa 0,x
next_low:
        inx
        bra loop_low
done:
        pula
        rts


low2up:                                                ;This is the same function created in exe1 to change lower case into upper case
        ldx #string_buffer
        psha
loop_up:
        ldaa 0,x
        cmpa #13
        beq change_done
        cmpa #$61
        blo next_up
        cmpa #$7A
        bhi next_up
        suba #$20
        staa 0,x
next_up:
        inx
        bra loop_up


CapWord:
        ldx #string_buffer
        psha
        jsr up2low
        ldx #string_buffer
        jsr check_up
               
loop_word:
        ldaa 0,x
        beq change_done
        ldaa -1,x
        cmpa #$20
        bne next_word
        jsr check_up        
next_word:
        inx
        bra loop_word   
check_up:
        ldaa 0,x
        cmpa #$61
        blo next_word
        cmpa #$7A
        bhi next_word
        suba #$20
        staa 0,x
        rts
        ;bra next_word


change_done:
        pula
        bra writecSCI1




; one second delay
delay:
          pshx
          pshy
          ; <your code goes here>
          ;
          ldx #60000
          ldy #100
          
inner_loop:
            psha  ;push requires 2 cycle
            pula  ; pull requires 3 cycle
            dbne x, inner_loop ;dbne requires 3 cycle
            
            ldx #60000
            dbne y, inner_loop
          
          puly
          pulx  
          rts		; return from subroutine 
          
          
port_h_isr:
          ldaa PTH
          staa PTH_0
          bset PIFH, #PORT_H_MASK
          RTI          
          
          
              
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG $FFCC
            DC.W port_h_isr
            
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
