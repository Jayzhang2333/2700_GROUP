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
string fcc "ThIS is A vAlId INpUt. This is also a valid input."   ; test string
end_sign dc.b 0        ; place end sign at end of string


; code section
            ORG   ROMStart
Entry:
_Startup:
          LDS   #RAMEnd+1       ; initialize the stack pointer


          ldx  #string
Start:
        jsr up2low      ; jump to up2low
        ldx #string     ; load X to the head of the string
        jsr low2up      ; jump to low2up
        ldx #string     ; load X to the head of the string
        jsr CapWord     ; jump to CapWord
        ldx #string     ; load X to the head of the string
        jsr CapSen      ; jump to CapSen
        bra Start
        






low2up:                 ; function to raise all lower case characters to upper case 
        psha            ; push value in A to stack, preserve it 
loop_up:
        ldaa 0,x        ;load character from X with no offset
        beq done        ;If the current value pointed by X is $00
                        ;This means we have reached the end 
                        ;Branch to done
                        
        cmpa #$61       ; compare A with hex value of 61 (a in ASCII)
        blo next_up     ; if A less than value of $61, branch to next_up 
        cmpa #$7A       ; compare A with hex value $7A (z in ASCII)
        bhi next_up     ; branch to next_up if A higher than $7A
        suba #$20       ; subtract hex $20 from A (converts to upper case ASCII code)
        staa 0,x        ; store value in A in X
next_up:
        inx             ; Increase X to point to the next char
        bra loop_up     ; branch to loop_up
done:
        pula            ; pull from stack
        rts             ; return
  
  
  
 
 
 
      
up2low:                ;function to lower all upper case characters to lower case
        psha
loop_low:
        ldaa 0,x       ; load to A pointed value in X with no offset
        beq done       ; if it is null, branch to done
        cmpa #$5A      ; compare with hex value 5A (Z in ASCII)
        bhi next_low   ; branch to next_low if character in A higher than 5A
        cmpa #$41      ; compare A with hex value 41 (A in ASCII)
        blo next_low   ; branch to next_low if character in A lower than 41
        adda #$20      ; Add 20 in hex (32 in decimal) to convert to lower case
        staa 0,x       ; Store A into current pointed value in X
next_low:
        inx            ; Increment X to point to the next char in string
        bra loop_low   ; Branch again to deal with next char 
        







CapWord:
        psha           ; push value in A to stack, preserve it 
        jsr up2low     ; First convert all characters to lower case
        ldx #string    ; load X to the head of the string
        jsr check_up   ; jump to check_up to capitalise the first letter
               
loop_word:             ; will loop through string until the end of a word is reached
        ldaa 0,x
        beq done       ; branch to done if X is null
        ldaa -1,x      ;
        cmpa #$20      ; check if the previous letter is a space
        bne next_word  ;If false, we can move on to the next letter
        jsr check_up   ;If true, we need to capitalise the current letter
        
next_word:             ; used to set up loop_word function by incrementing X
        inx            ;Increase X to point to the next letter in the string
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







CapSen:               ; function to capitalise start of each sentence
        psha
        jsr up2low
        ldx #string
        jsr check_up
           
loop_sen:
        ldaa 0,x
        beq done
        ldaa -1,x     ; check if previous character is a space
        cmpa #$20     ; compare character with hex 20 (SPACE in ASCII)
        bne next_sen  ; We can move on to the next char if the previous is not space
        ldaa -2,x     ; check if previous character 2 is a full stop
        cmpa #$2E     ; compare character with hex 2E ( . in ASCII)
        bne next_sen  ; We can move on to the next char if the previous is not a full stop
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
