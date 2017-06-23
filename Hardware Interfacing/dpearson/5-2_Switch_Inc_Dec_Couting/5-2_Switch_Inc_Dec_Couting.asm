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

CHECK_BUTTON:
	SBIS PIND, 0		; skip if button0 is not pushed
	RCALL BUTTON_INC_DOWN ; button0 is pressed
	SBIS PIND, 1		; skip if button1 is not pushed
	RCALL BUTTON_DEC_DOWN	; button1 is pressed
	RJMP CHECK_BUTTON ; loop waiting for a button to be pressed

BUTTON_INC_DOWN:	
   ;If we get here the button0 has been pushed
	INC COUNT			; increment the counter;
	MOV TMP1, COUNT		; move value in count to a register
	OUT PORTA, TMP1		; output count value	

BUTTON_INC_UP:
	SBIC PIND, 0 		; skip if button released
	RET	; idle - go back to checking for button presses
	RJMP BUTTON_INC_UP	; button has not been released
	

BUTTON_DEC_DOWN:
;If we get here the button has been pushed
	DEC COUNT			;decrement the counter;
	MOV TMP1, COUNT		; move value in count to a register
	OUT PORTA, TMP1		; output count value

BUTTON_DEC_UP:
	SBIC PIND, 1 		; skip if button released
	RET	; idle - go back to checking for button presses
	RJMP BUTTON_DEC_UP	; button has not been released

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
