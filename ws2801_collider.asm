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

collider:
	ldi	R17, 0x18
	ldi	R18, 0x00
collider_loop:
	rcall	delay
	ldi	R16, 0x07
	mov	R4, R17
	rcall	ws2801_set_red
	mov	R4, R18
	rcall	ws2801_set_blue

	cp	R17, R18
	brne	collider_continue
	ldi	R16, 0xFF
	rcall	ws2801_set_green
collider_continue:

	rcall	ws2801_update
	rcall	fade

	dec	R17
	brpl	collider_red_end
	ldi	R17, 0x18
collider_red_end:
	inc	R18
	cpi	R18, ws2801_count
	brlt	collider_blue_end
	ldi	R18, 0x00
collider_blue_end:
	rjmp	collider_loop

fade:
	ldi	R19, 0x18
fade_loop:
	mov	R4, R19
	rcall	ws2801_get_red
	lsr	R16
	rcall	ws2801_set_red
	rcall	ws2801_get_green
	lsr	R16
	rcall	ws2801_set_green
	rcall	ws2801_get_blue
	lsr	R16
	rcall	ws2801_set_blue
	dec	R19
	brpl	fade_loop
	ret

.INCLUDE "lib/ws2801.inc"
.INCLUDE "lib/spi.inc"
.INCLUDE "lib/delay.inc"
