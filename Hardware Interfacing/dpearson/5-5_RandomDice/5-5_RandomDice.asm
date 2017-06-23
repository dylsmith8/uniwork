; A PROGRAM THAT GENERATES A RANDOM NUMBER ON BUTTON PRESS
; BUTTON0 STARTS THE TIMER
; BUTTON1 STOPS THE TIMER AND GENERATES THE RANDOM NUMBER

;INCLUDE FILES
.include "m16def.inc"

;DEFINITIONS
 .def TMP1=R16
 .def TMP2=R17
 .def TMP3=R18

;CODE SETUP
.cseg
.org $000
	RJMP START

.org INT0addr						; tells the program to write the below code in the interupt 0 code space
	RJMP INT0_ISR					; jump to int0 service record
.org INT1addr						; GET INT1 CODE SPACE
	RJMP INT1_ISR					; JUMP TI INT1 SERVICE RECORD
.org OVF0addr						; find the over flow vector address
	RJMP TIMER0_OVF_ISR				; over flow vector service record
.org $02A							; jump past the interup vectors to start writing our code

;START CODE
START:
	LDI TMP1, LOW(RAMEND)				
	OUT SPL, TMP1						; STACK POINTER LOW
	LDI TMP1, HIGH(RAMEND)
	OUT SPH, TMP1						; STACK POINTER HIGH

	RCALL SETUP_PORTS
	RCALL SETUP_INTERUPTS
	RCALL SETUP_TIMERS

	SEI									; ENABLE TO GLOBAL INTERUPT FLAG
MAIN_LOOP:
	NOP
	NOP
	RJMP MAIN_LOOP

SETUP_PORTS:

	LDI TMP1, 0X00						; SETUP PORTD FOR INPUTS
	OUT PORTD, TMP1
	
	SBI PORTD, 2						; ENABLE PULLUPS ON PORTD 2

	SER TMP1							; SETUP PORTA FOR LED'S AND SET THEM TO OFF
	OUT DDRA, TMP1
	CLR TMP1
	OUT PORTA, TMP1

	RET									; RETURN TO CALL SITE

SETUP_INTERUPTS:
	LDI TMP1, 0X40						; BINARY = 0100 0000
	OUT GICR, TMP1						; ENABLE INT0 GLOBALLY
	
	; SET INTERUPTS ON A SPECIFIC EDGE
	LDI TMP1, 0X02						; BINARY = 0000 1010
	OUT MCUCR, TMP1						; ENABLE FALLING EDGE INTERUPT FOR INT1 AND INT0

	RET									; GO BACK TO CALL SITE

SETUP_TIMERS:

	RET									; RETURN TO CALL SITE


INT0_ISR:

; DISABLE INT0 AND ENABLE INT1
	LDI TMP1, 0X80						; BINARY = 1000 0000
	OUT GICR, TMP1						; TURNS OFF INTO AND TURNS ON INT1
	
	LDI TMP1, 0B10000000				;
	OUT GICR, TMP1						; ENABLE INT1 AND DISABLE INT0	

	CLR TMP1							; TMP1 = 0X00
	OUT TCNT0, TMP1						; CLEAR THE TIMER COUNTER REGISTER
	
	LDI TMP1, 0X01						; BINARY = 0000 0001
	OUT TCCR0, TMP1						; ENABLE THE TIMER WITH NO PRESCALLER	
	
	LDI TMP1, 0X05						; BINARY = 0000 0101
	OUT TCCR0, TMP1					; SET THE TIMER PRESCALLER TO 1024					

	RETI								; RETURN TO CALL SITE ENABLING INTERUPTS AGAIN		

INT1_ISR:
	LDI TMP1, 0X80						; BINARY = 1000 0000
	OUT GICR, TMP1						; TURNS OFF INTO AND TURNS ON INT1

		
	
	LDI TMP1, 0X00						; BINARY = 0000 0000
	OUT TCCR0, TMP1					; SET THE TIMER PRESCALLER TO 1024					

	RETI								; RETURN TO CALL SITE ENABLING INTERUPTS AGAIN

TIMER0_OVF_ISR:
	LDI TMP1, 0X00						; BIANRY = 0000 0000
	OUT TCCR1B, TMP1					; STOP THE TIMER
	OUT PORTA, TMP1						; OUTPUTS THE VALUE IN TMP1 TO THE LEDS	

	RETI								; RETURN TO CALL SITE

DELAY:
	LDI TMP1, 0X60						; BINARY = 0110 0000
	LOOP1: SER TMP2						; SET ALL BITS IN REGISTER 17
	LOOP2: SER TMP3						; SET ALL BITS IN REGISTER 18
	LOOP3:
		DEC TMP3						; DECREMENT TMP3
		CPI TMP3, 0						; CHECK IF TMP3 = 0 (COMPARE WITH IMEDIATE)
		BRNE LOOP3						; BRANCH TO LOOP 3 IF TMP3 IS NOT EQUAL TO 0
		DEC TMP2						; TMP2--
		BRNE LOOP2						; BRANCH IF TMP2 IS NOT EQUAL TO 0
		DEC TMP1						; TMP1--
		BRNE LOOP1						; GO TO LOOP1 IF TMP1 != 0
	
	RET									; RETURN TO CALL SITE
