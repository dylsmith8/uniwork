; button counting with interupts
; this program countrs button presses on portd0 abd outputs them to the LED's on port a using interupts

.include "m16def.inc"				; this has all the defintions for the MC

.def TMP1=R16
.def TMP2=R17
.def TMP3=R18
.def COUNT=R19

.cseg								; a command to tell the assembler to write this is the code segment

.org 0x000							; get the code at address $000
RJMP START							; jumps to the start label
.org INT0addr						; locates code at address 0x0002 which is the code that executes on int0
RJMP INT0_ROUTINE					; if int0 gets triggered then do this code meaning jump to the label int0_routine
.org INT1addr						; locate the code segment at 0x0004
RJMP INT1_ROUTINE					; write code to jump to this label on int1 trigger

.org $02A							; jump to the code block past the interupt vectors and start typing code

START:
	LDI TMP1, LOW(RAMEND)			; initialise the stack pointer part 1
	OUT SPL, TMP1					; output the low end to the SP low

	LDI TMP1, HIGH(RAMEND)			; high stack pointer
	OUT SPH, TMP1

	RCALL SETUP						; jump with the intent on returning
	SEI 							; set the gloabal interupt flag to allow interupts to happen

LOOP:
	NOP
	NOP
	NOP
	RJMP LOOP

SETUP: 								; set the ports for the led outputs and clear them, set the counter value to 0, setup the interupts
	CLR TMP1						; tmp1 = 00000000
	OUT DDRD, TMP1					; make port d and input

	SBI PORTD, 2					; set bit in IO register d2 to 1 to enable pull ups on int0
	SBI PORTD, 3					; activates pull ups on pin d3 which is int1
	
	SER TMP1						; set all the bits in tmp1 to 11111111 or 0xFF
	OUT DDRA, TMP1					; set port a to be outputs

	CLR TMP1						; clears temp maybe redundant because tmp has not changed but just incase of interupts changing it
	OUT PORTA, TMP1					; outputs the value in tmp1 to the leds in this case 00000000 or 0x00

	CLR COUNT

	LDI TMP1, 0x0d					; load an immediate value to tmp1 of 0000 1111 int0 falling and rising edge, int1 rising see page 67 to 69
	OUT MCUCR, TMP1					; outputs the value in tmp1 to the MCU control register to tell what edge the interupts will happen on

	LDI TMP1, 0xc0					; set the value of tmp1 to 1100 0000 to enable interupt 0 and 1 
	OUT GICR, TMP1					; move the value to the global interup control register

	RET								; return to call site and execute the next bit of code

INT0_ROUTINE:						; int0 will increment the counter 
									; save the registers first
	PUSH TMP1						; push tmp1 onto the stack
	IN TMP1, SREG					; move the status register into tmp1
	PUSH TMP1

	RCALL DELAY						; so that the switch does not double count
	
	IN TMP1, GIFR					; takes the value from the GIFR
	ANDI TMP1, 0b01000000			; and so that it puts a one in GIFR 6
	OUT GIFR, TMP1					; outputs the value back tot he GIFR

	INC COUNT						; counter + 1
	MOV TMP1, COUNT					; copy the value from count to tmp1
	OUT PORTA, TMP1					; display the value on the led's		

	POP TMP1						; pop value on stack to tmp1
	OUT SREG, TMP1					; restore the status register
	POP TMP1						; pop tmp1 back to restore the registers
	
	RETI		

INT1_ROUTINE:						; int1 will decrement the counter
									; save the registers first
	PUSH TMP1						; push tmp1 onto the stack
	IN TMP1, SREG					; move the status register into tmp1
	PUSH TMP1
	
	RCALL DELAY						; so that the switch does not double count
	
	IN TMP1, GIFR					; takes the value from the GIFR
	ANDI TMP1, 0b10000000			; and so that it puts a one in GIFR 7
	OUT GIFR, TMP1					; outputs the value back tot he GIFR
	
	DEC COUNT						; counter - 1
	MOV TMP1, COUNT					; move count value to tmp1
	OUT PORTA, TMP1					; output the values on the led	

	POP TMP1						; pop value on stack to tmp1
	OUT SREG, TMP1					; restore the status register
	POP TMP1						; pop tmp1 back to restore the registers
	
	RETI								

DELAY:
	SER TMP1
DEL1:
	SER TMP2
DEL2:
	LDI TMP3, 10
DEL3:
	DEC TMP3
	BRNE DEL3
	DEC TMP2
	BRNE DEL2
	DEC TMP1
	BRNE DEL1
	RET
