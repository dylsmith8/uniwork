;a timer that counts how fast you can press a button
;switch0 - int0 on pd2
;switch1 - int1 on pd3
;porta0-7 fro the led's

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
 RJMP INT0_ISR						; jump to int0 service record
 .org INT1addr						; write this code in the int1 space
 RJMP INT1_ISR						; jump to int1 service record
 .org OVF1addr						; find the over flow vector address
 RJMP TIMER1_OVF_ISR				; over flow vector service record
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
;OUR CODE
MAIN_LOOP:
	NOP
	NOP
	RJMP MAIN_LOOP
;SETUP PORTS FOR SWITCHES
SETUP_PORTS:
;SETUP PORTD FOR INPUTS
	LDI TMP1, 0X00
	OUT PORTD, TMP1
;ENABLE PULLUPS ON PORTD
	SBI PORTD, 2
	SBI PORTD, 3
;SETUP PORTA FOR LED'S
	SER TMP1
	OUT DDRA, TMP1
	CLR TMP1
	OUT PORTA, TMP1
;RETURN TO CALL SITE
	RET
;SETUP INTERUPTS
SETUP_INTERUPTS:
;INT0
	LDI TMP1, 0X40						; BINARY = 0100 0000
	OUT GICR, TMP1						; ENABLE INT0 GLOBALLY
;INT1
	
;SET INTERUPTS ON A SPECIFIC EDGE
	LDI TMP1, 0X0A						; BINARY = 0000 1010
	OUT MCUCR, TMP1						; ENABLE FALLING EDGE INTERUPT FOR INT1 AND INT0
; GO BACK TO CALL SITE
	RET
;TIMERS
SETUP_TIMERS:

	RET									; RETURN TO CALL SITE

;INT0 SERVICE RECORD - MUST SAVE THE REGISTERS AND THE SREG
INT0_ISR:
	LDI TMP1, 0X80						; BINARY = 1000 0000
	OUT GICR, TMP1						; TURNS OFF INTO AND TURNS ON INT1

	SBI PORTA, 0						; TURN ON LED0

	RCALL DELAY							; DELAY SO THAT THERE IS NO SWITCH BOUNCE
	
	SBI PORTA, 1						; TURN LED1 ON
	CBI PORTA, 0 						; TURN LED0 OFF
	
	LDI TMP1, 0X05						; BINARY = 0000 0101
	OUT TCCR1B, TMP1					; SET THE TIMER PRESCALLER TO 1024					

	RETI								; RETURN TO CALL SITE ENABLING INTERUPTS AGAIN
;INT1 SERVICE RECORD - MUST SAVE THE REGISTERS AND THE SREG
INT1_ISR:
	
	LDI TMP1, 0X00						; BINARY 0000 0000
	OUT TCCR1B, TMP1					; STOP THE TIMER FROM RUNNING

	LDI TMP1, 0X40						; BINARY = 0100 0000
	OUT GICR, TMP1						; DISABLE INT1 AND ENABLE INT0

	IN TMP2, TCNT1L						; GET THE LOW BITS FROM TIMER1
	IN TMP1, TCNT1H						; GET THE HIGH BITS FROM TIMER1
	OUT PORTA, TMP1						; PUT THE HIGH BIT VALUE TO THE LEDS	

	RETI								; RETURN TO CALL SITE					
;TIMER SERVICE RECORD
TIMER1_OVF_ISR:
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