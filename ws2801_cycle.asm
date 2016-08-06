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

	ldi	R16, 0x01
cycle:
	inc	R16
	ldi	R17, 0x18
cycle_red:
	mov	R4, R17
	rcall	ws2801_set_red
	rcall	delay_5ms
	rcall	ws2801_update
	dec	R17
	brpl	cycle_red
	ldi	R17, 0x18
cycle_green:
	mov	R4, R17
	rcall	ws2801_set_green
	rcall	delay_5ms
	rcall	ws2801_update
	dec	R17
	brpl	cycle_green
	ldi	R17, 0x18
cycle_blue:
	mov	R4, R17
	rcall	ws2801_set_blue
	rcall	delay_5ms
	rcall	ws2801_update
	dec	R17
	brpl	cycle_blue
	rjmp	cycle


.INCLUDE "lib/ws2801.inc"
.INCLUDE "lib/spi.inc"
.INCLUDE "lib/delay.inc"
