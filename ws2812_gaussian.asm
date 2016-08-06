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
        ldi     R16, low(RAMEND)
        out     SPL, R16
        ldi     R16, high(RAMEND)
        out     SPH, R16

	clr	R0
	mov	R1, R0
	inc	R1

	sbi	DDRB, DDB0 ; Pin 5 output

	; Reset 144 element strand
	rcall	ws2812_clear
	rcall	ws2812_delay
	rcall	ws2812_update_all

;	ldi	R16, 0xAA
;	mov	R0, R16
;	ldi	R16, 0x37
;	mov	R1, R16
;	ldi	R16, 0x06
;	mov	R2, R16
	rcall	rng_init
end:
	rcall	gaussian
	rjmp	end


gaussian:
	rcall	rng_next
	clr	R1
	movw	R2, R0
;	rcall	rng_next
;	add	R0, R2
;	adc	R1, R3

;	lsr	R1
;	ror	R0
	lsr	R1
	ror	R0

        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
	add	XL, R0
	adc	XH, R1

	ld	R16, X
	inc	R16
        st      X, R16

	rcall	ws2812_delay
	rcall	ws2812_update_all

	ret

.INCLUDE "lib/delay.inc"
.INCLUDE "lib/math.inc"
.INCLUDE "lib/ws2812.inc"
