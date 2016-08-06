.DEVICE attiny85

.INCLUDE "lib/common.inc"

.CSEG
.ORG 0x0000
	rjmp	RESET_vect	; Reset vector
	reti		; INT0 vector
	reti		; PCINT0 vector
	reti		; TIMER1_COMPA vector
	reti		; TIMER1_OVF vector
	reti		; TIMER0_OVF vector
	reti		; EE_RDY vector
	reti		; ANA_COMP vector
	reti		; ADC vector
	reti		; TIMER1_COMPB vector
	reti		; TIMER0_COMPA vector
	reti		; TIMER0_COMPB vector
	reti		; WDT vector
	reti		; USI_START vector
	reti		; USI_OVF vector

RESET_vect:
	ldi	R16, low(RAMEND)
	out	SPL, R16
	ldi	R16, high(RAMEND)
	out	SPH, R16

	rcall	spi_init

	rcall	ws2801_clear	
	rcall	ws2801_update

chase:
	ldi	R16, ws2801_count - 1
	mov	R1, R16
	mov	R2, R16
	mov	R3, R16
	mov	R4, R16
chase_loop:
	rcall	ws2801_clear
	rcall	ws2801_set
	rcall	ws2801_update
	rcall	delay
	dec	R4
	brpl	chase_loop
	rjmp	chase

.INCLUDE "lib/ws2801.inc"
.INCLUDE "lib/spi.inc"
.INCLUDE "lib/delay.inc"
