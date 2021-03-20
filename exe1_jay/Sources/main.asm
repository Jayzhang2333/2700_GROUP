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
string fcc "This is"
end_sign dc.b 0



; code section
            ORG   ROMStart
Entry:
_Startup:
          LDS   #RAMEnd+1       ; initialize the stack pointer

          ldx  #string
Start:
        jsr up2low      ; jump to up2low
        ldx #string     ; load string to register X
        jsr low2up      ; jump to low2up
        ldx #string     ; load adjusted string to X
        jsr CapWord     ; jump to CapWord
        ldx #string     ; load adjusted string to X
        jsr CapSen      ; jump to CapSen
        






low2up:                 ; function to raise all lower case characters to upper case 
        psha            ; push to stack 
loop_up:
        ldaa 0,x        ;load character from X with no offset
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
        rts             ; return
  
  
  
 
 
 
      
up2low:                ;
        psha
loop_low:
        ldaa 0,x
        beq done
        cmpa #$61
        bhi next_low
        cmpa #$41
        blo next_low
        adda #$20
        staa 0,x
next_low:
        inx
        bra loop_low
        







CapWord:
        psha
        jsr up2low
        ldx #string
        jsr check_up
               
loop_word:
        ldaa 0,x
        beq done
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







CapSen:
        psha
        jsr up2low
        ldx #string
        jsr check_up
           
loop_sen:
        ldaa 0,x
        beq done
        ldaa -1,x
        cmpa #$20
        bne next_sen
        ldaa -2,x
        cmpa #$2E
        bne next_sen
        jsr check_up
        
next_sen:
        inx
        bra loop_sen   





end

;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
