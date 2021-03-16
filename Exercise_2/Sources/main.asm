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
            
            ; Variable
number      FCC   "1279"
;flag        EQU  $4010 
            
 ; Insert here your data definition.
Counter     DS.W 1
FiboRes     DS.W 1


; code section
            ORG   ROMStart


Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
            

;mainLoop: ; Setting port B and port J to output
            ldaa #$FF
            staa DDRP ; Allows you to pick individual displays
            staa DDRB ; Allows you to input numbers
            staa DDRJ ; Allows you to set the 'ground' of the LED
            ldaa #$00
            staa PTJ    ; Enable LEDS, set ground to 0v
            staa DDRH ; Set buttons to input

        
        
start:     ; Generating numbers
        ldy #number
        ;ldaa #$00
        ;staa flag ; Set flag to zero
        
loop:        
        ldaa #$0E ; Sets left 7 seg on
        staa PTP  ; increment address stored in x to get next value
        ldaa 0, Y ; Gets value from string
        jsr number_check ; Checks the value of the number and places correct code in register
        staa PORTB ; Set to display 1
        jsr button ; branch to button module
        clr PORTB 
        jsr delay ;delay 1 ms
        clr PORTB ;turn display off
        
        ;ldab flag ;Get flag
        ;cmpb #$01 ;Check if button has been pressed once
       ; blt  loop ;If value is less than one loop only first number
        
        ldaa #$0D ; Sets left 7 seg on
        staa PTP  ; increment address stored in x to get next value
        ldaa 1, Y ; Gets value from string
        jsr number_check ; Checks the value of the number and places correct code in register
        staa PORTB ; Set to display 1
        jsr button ; branch to button module
        clr PORTB 
        jsr delay ;delay 1 ms
        clr PORTB ;turn display off
        
        ;ldab flag ;Get flag
        ;cmpb #$02 ;Check if button has been pressed twice
        ;blt  loop ;If value is less than one loop only first number
        
        ldaa #$0B ; Sets left 7 seg on
        staa PTP  ; increment address stored in x to get next value
        ldaa 2, Y ; Gets value from string
        jsr number_check ; Checks the value of the number and places correct code in register
        staa PORTB ; Set to display 1
        jsr button ; branch to button module
        clr PORTB 
        jsr delay ;delay 1 ms
        clr PORTB ;turn display off
        
        ;ldab flag ;Get flag
        ;cmpb #$03 ;Check if button has been pressed three times
        ;blt  loop ;If value is less than one loop only first number
        
        ldaa #$07 ; Sets left 7 seg on
        staa PTP  ; increment address stored in x to get next value
        ldaa 3, Y ; Gets value from string
        jsr number_check ; Checks the value of the number and places correct code in register
        staa PORTB ; Set to display 1
        jsr button ; branch to button module
        clr PORTB 
        jsr delay ;delay 1 ms
        clr PORTB ;turn display off
        
        bra loop
        
        ;ldab flag ;Get flag
        ;cmpb #$04 ;Check if button has been pressed more than three times
        ;blt loop ;If value is four then reset flag so only one number shows
        ;jsr reset_flag ; Continue incrementing through memory addresses
        
       ; bra loop
        
;reset_flag:
        ;ldab #$00
        ;stab flag
        
        ;rts
        
number_check:
        cmpa #$30 ; Check for '0'
        beq zero
        cmpa #$31 ; 1
        beq one
        cmpa #$32 ; 2
        beq two
        cmpa #$33 ; 3
        beq three
        cmpa #$34 ; 4
        beq four
        cmpa #$35 ; 5
        beq five
        cmpa #$36 ; 6
        beq six
        cmpa #$37 ; 7
        beq seven
        cmpa #$38 ; 8
        beq eight
        cmpa #$39 ; 9
        beq nine
        cmpa #$41 ; A
        beq lab_a
        cmpa #$42 ; B
        beq lab_b
        cmpa #$43 ; C
        beq lab_c
        cmpa #$44 ; D
        beq lab_d
        cmpa #$45 ; E
        beq lab_e
        cmpa #$46 ; F
        beq lab_f
        
zero:   ldaa #$3F
        rts
one:    ldaa #$06
        rts
two:    ldaa #$5B
        rts
three:  ldaa #$4F
        rts
four:   ldaa #$66
        rts
five:   ldaa #$6D
        rts
six:    ldaa #$7D
        rts
seven:  ldaa #$07    ; Change the ASCII value in accumulator to corresponding 7 seg code
        rts
eight:  ldaa #$7F
        rts
nine:   ldaa #$6F
        rts
lab_a:  ldaa #$77
        rts
lab_b:  ldaa #$7C
        rts
lab_c:  ldaa #$39
        rts
lab_d:  ldaa #$5E
        rts
lab_e:  ldaa #$79
        rts
lab_f:  ldaa #$71
        rts
 ; return from subroutine
        
        
button:
        ldab PTH  ; Get data from switches (if no press, 11111111)
        cmpb #$FE ; compare to 11111110 (last button is pressed)
        bne button ;If not the same, keep looping so number stays the same
        
        ;ldx flag ;Load value in flag
        ;inx ;increment flag
        
        rts ; If same return from subroutine
        
delay:
          ; <your code goes here>
          ldx #60000
          ldab #80
          
inner_loop:
          dbne x, inner_loop  ; dbne takes 3 cycles 
          
          ldx #60000
          dbne b, inner_loop 
          
          ;
          rts		; return from subroutine, back to main
        
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
