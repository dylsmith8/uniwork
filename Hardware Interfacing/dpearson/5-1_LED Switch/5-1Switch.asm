; LED-Switch - Project 1
; This program toggles portB pin 0

.include "m16def.inc"

.def TMP1=R16				; sets R16 with a easy reconisable name
.def TMP2=R17				; TMP2 refers to R17
.def TMP3=R18				; TMP3 points to R18

.cseg						; this is where the actual code starts

.org 	$000				; locate code at address $000
rjmp	START

.org	$02A				; get the code that is past the interupt vectors

START:
	ldi TMP1, LOW(RAMEND)	; loads the value of LOW(RAMEND) into TMP1 or R16
	out	SPL, TMP1			; writes the value of TMP1 to SPL
	ldi TMP1, HIGH(RAMEND)	; loads the value of HIGH(RAMEND) into TMP1
	out SPH, TMP1			; writes TMP1 to SPH

	rcall INITIALISE		; calls initialise

MAINLOOP:
	SBIC PIND, 0 			; if pin d0 == 0 skip the next instruction
	CBI	PORTB, 0			; if PD0 is set to 1 or high then make it 0 or low 
	SBIS PIND, 0			; if PD0 is set to 1 then skip the next instruction
	SBI PORTB,0				; if pressed turn on the LED
	NOP
	NOP
	RJMP MAINLOOP			; jump back to the start
	 
INITIALISE:
	SBI DDRB, 0				; set data pin b0 to send data
	CBI	PORTB, 0			; clear the bit in pinB0 to off, LED = off
	CBI DDRD, 0				; now set PB0 to be an input
	SBI PORTD, 0			; set PD0 to 1
	RET
