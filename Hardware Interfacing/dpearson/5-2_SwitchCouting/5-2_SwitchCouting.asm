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

SAMPLE_DOWN:
	SBIC PIND, 0					; if the button is pushed then skip the next instruction
	RJMP SAMPLE_DOWN				; go back and check again
	; this means the button is pressed
	INC COUNT						; count = count + 1
	MOV TMP1, COUNT					; move the value of count to tmp1
	OUT PORTA, TMP1

SAMPLE_UP:
	SBIS PIND, 0					; if switch port = 0 then skip if released
	RJMP SAMPLE_UP					; switch is not released so check when it is released
	RJMP SAMPLE_DOWN				; go to sswitch down and loop again

INITIALIZE:
    SER TMP1						; set bits in register to all 1's
	OUT DDRA, TMP1					; 
	CLR TMP1
	OUT PORTA, TMP1					; set port a leds to off
	CLR COUNT						; set counter to 0
	OUT DDRD, TMP1					; make d inputs
	SER TMP1
	OUT PORTD, TMP1					; activate pullups on portd
	RET
