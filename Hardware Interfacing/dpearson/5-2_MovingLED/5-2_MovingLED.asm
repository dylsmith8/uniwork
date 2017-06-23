; Counting Switch Press
; Counts the button presses on PD0 and displays them on
; the LED's

.include "m16def.inc"               ; includes all the definitions for the programmer

; register definitions
.def TMP1=R16
.def TMP2=R17
.def TMP3=R18
.def COUNT=R19


.cseg                               ; tells the assembler where the code section starts

.org $000                           ; loads the start address to start writing code from the begining
RJMP START                          ; jumps to the start of our code
.org $2A                            ; writes out code past the interupt vectors

START:
	LDI TMP1, LOW(RAMEND)           ; setting up the stack pointer
    OUT SPL, TMP1
    LDI TMP1, HIGH(RAMEND)
    OUT SPH, TMP1

    RCALL INITIALIZE

LOOP:
	SBIS PIND, 0					; if button 0 is not pressed skip the next instruction to move the light up
	RJMP B0_DOWN					; jump to move the light up
	SBIS PIND, 1					; if button 1 is not pressed then skip the next instruction
	RJMP B1_DOWN					; jump to move the led down
	RJMP LOOP						; go back and check again because nothing has happened


B0_DOWN:
	SBIC PIND, 0					; if the button is pushed then skip the next instruction
	RJMP B0_DOWN					; go back and check again
									; this means the button is pressed
	LSL TMP1
	OUT PORTA, TMP1

B0_UP:
	SBIS PIND, 0					; if switch port = 0 then skip if released
	RJMP B0_UP						; switch is not released so check when it is released
	RJMP LOOP						; go to sswitch down and loop again

B1_DOWN:
	SBIC PIND, 1					; if button 1 is pressed then skip the next instruction and decrease the LED
	RJMP B1_DOWN					; go back to the start of this and check if the button is pressed
									; if we got here the button is pressed and now we need to do something
	LSR TMP1						; shift the bit right to move the led light down
	OUT PORTA, TMP1					; move the value from the register to the LED register	

B1_UP:
	SBIS PIND, 1					; if button 1 is not pressed there is a 0 in pind so skip the next instruction
	RJMP B1_UP						; whilst the button is up loop round here to 
	RJMP LOOP						; go back to the button being pressed										

INITIALIZE:
    SER TMP1						; set bits in register to all 1's
	OUT DDRA, TMP1					; set port a as outputs for the led's
	
	CLR TMP1						; clear temp 1 set it to 0b00000000
	OUT DDRD, TMP1					; make d inputs

	SER TMP1						; set tmp1 to 0b11111111
	OUT PORTD, TMP1					; activate pullups on portd 

	LDI TMP1, 0b0000001				; set tmp1 to have a 1 in the first bit to move
	OUT PORTA, TMP1					; set the first led on
	RET
