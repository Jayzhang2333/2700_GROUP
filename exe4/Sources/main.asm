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
buffer      rmb 100         ; Set input buffer to 100 bytes
trigger     dc.b $00          ; reserve byte to indicate whether port H high or low
PORT_H_MASK EQU %00000001   ; mask for triggering inputs if PH0 
                            ; transitions from high and low
                            



; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            
Button_Setup:
            
            LDAB  #$00            ; set all bits in register B to 0
            STAB  DDRH            ; configure port H as output


            
Bit_Setting:

            
            movb #$00, SCI1BDH    ; Set bits to zero
            movb #156, SCI1BDL    ; Set baud rate to 9600
            movb #$4C, SCI1CR1    ; Set 8 bit word length, and wake up bit
            movb #$0C, SCI1CR2    ; Enable SCI transmission and recieving bits
            

Initialise_IO:
            sei               ;disable interrupt
            ldaa #PORT_H_MASK
            staa PIEH
            coma              ; takes the complement of the port H mask
                              ; to observe the falling edge
            staa PPSH
            
            cli               ; enable interrupt

Start:
            
            ldx #buffer         ; Start at $1000, where buffer is located
            jsr Input             ; Allow user input to terminal
            ; Now user should be completed with inputs
            ; Reset x to point to the start of tbe input string
            ldx #buffer
            ldaa PTH
            staa trigger
            jsr Delay
            ldaa trigger
            cmpa #$FE
            beq  low2up
            bra  CapWord     
            ;bra Start ; Start again
            
Input:      
            brclr SCI1SR1, mSCI1SR1_RDRF, Input ; If something has not been received then loop until something is received
            ldaa SCI1DRL ; When recieved transmission, store character in register A
            staa 1,x+ ; Store in location pointed by x, increment x
            ; Compare with carriage sign
            cmpa #$0D
            beq return
            bra Input ; If no carriage return then loop for more input characters

Read:
            ldaa 1,x+   ; Load character pointed by X and increment x
            cmpa #$0D   ; compare carriage return
            beq Final_Write   ; If NULL return to main program, after writing the newline character
            jsr Write   ; If not NULL write character to serial
            beq Start  
            bra Read    ; Loop until all characters are read
            
                        
return: 
            rts ; Return from subroutine 
            
            
Write:
            brclr SCI1SR1, mSCI1SR1_TDRE, * ; Check if there has been a transmission. If so then go to next step
            staa SCI1DRL    ; Write to serial
            rts             ; Return to read function
            
            
Final_Write:

            brclr SCI1SR1, mSCI1SR1_TDRE, * ; Check if there has been a transmission. If so then go to next step
            staa SCI1DRL                        ; Write to serial
            bra  Start                          ; Return to read function
            
            
            
low2up:                 ; function to raise all lower case characters to upper case 
        psha            ; push to stack 
loop_up:
        ldaa 0,x        ;load character from X with no offset
        cmpa #13
        beq done
        cmpa #$61       ; compare A with hex value of 61 (a in ASCII)
        blo next_up     ; if A less than value of $61, branch to next_up 
        cmpa #$7A       ; compare A with hex value $7A (z in ASCII)
        bhi next_up     ; branch to next_up if A higher than $7A
        suba #$20       ; subtract hex $20 from A (converts to upper case ASCII code)
        staa 0,x        ; store value in A in X
next_up:
        inx             ; increment pointer in X
        bra loop_up     ; branch to loop_up


done:
        pula            ; pull from stack
        ldx #buffer ; reset X to start of buffer
        bra Read                ; return
  
  
  
 
 
 
      
up2low:                ;function to lower all upper case characters to lower case
        psha
loop_low:
        ldaa 0,x       ; load to A pointed value in X with no offset
        beq done_u2l       ; if empty, branch to done
        cmpa #$5A      ; compare with hex value 5A (Z in ASCII)
        bhi next_low   ; branch to next_low if character in A higher than 5A
        cmpa #$41      ; compare A with hex value 41 (A in ASCII)
        blo next_low   ; branch to next_low if character in A lower than 41
        adda #$20      ; Add 20 in hex (32 in decimal) to convert to lower case
        staa 0,x       ; Store A into current pointed value in X
next_low:
        inx            ; Increment X
        bra loop_low
        

done_u2l:             ;finish up2low
      pula 
      rts





CapWord:
        psha
        jsr up2low     ; First convert all characters to lower case
        ldx #buffer    ; load string to X
        jsr check_up   ; jump to check_up
               
loop_word:             ; will loop through string until the end of a word is reached
        ldaa 0,x
        cmpa #13
        beq done       ; branch to done if X is empty
        ldaa -1,x      ;
        cmpa #$20      ; check if stack pointer
        bne next_word
        jsr check_up
        
next_word:             ; used to set up loop_word function by incrementing X
        inx
        bra loop_word   

check_up:             ; Checks if the current if character is lower case. If so, convert to upper case
        ldaa 0,x
        cmpa #$61
        blo next_word  ; jumps to next word instead of next character if character below $61
        cmpa #$7A
        bhi next_word
        suba #$20      ; convert to upper case by subtracting $20 from character
        staa 0,x       ; store A into X, no offset
        rts
        ;bra next_word
            
            
            
Delay:                 ;push A, X and Y onto stack to preserve them after delay 
          psha
          pshx
          pshy
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
            pula 
            rts		; return from subroutine
            
            
port_h_isr:
            
            
            ldaa PTH                 ; load the current value of port H into A 
            staa trigger             ; store the current state into trigger
            
            bset PIFH, #PORT_H_MASK  ; reset all interrupt flags 
            
            RTI                      ; return from interrupt
          
            

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
            
            ORG   $FFCC
            DC.W  port_h_isr      ; port H interrupt
