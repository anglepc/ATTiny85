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

end:
	rcall	bounce2
	rjmp	end


bounce:
	clr	R16 ; Time 0.0625s steps (4.4 Fixed Point)
	ldi	R17, 0x9D ; g = 9.8 (9.8125 rounding error) (4.4 Fixed Point)
;	ldi	R17, 0x3D ; Test lower gravity values
	ldi	R18, 0xFF ; Initial velocity 15.0 (4.4 Fixed Point)
bounce_loop:
	mov	R0, R16 ; Multiplier (t)
	mov	R1, R17 ; Multiplicand (g)
	rcall	multiply8 ; (g*t) (4.4 * 4.4 = 8.8 Fixed Point)
	lsr	R1 ; (gt/2)
	ror	R0

	lsl	R0 ; Convert (gt/2) to 4.4 Fixed Point in R1
	rol	R1
	lsl	R0
	rol	R1
	lsl	R0
	rol	R1
	lsl	R0
	rol	R1

	mov	R0, R18
	sub	R0, R1 ; (v - gt/2)

	mov	R1, R16 ; Multiplier (t)
	rcall	multiply8 ; t * (v - gt/2) (4.4 * 4.4 = 8.8 Fixed Point)

	rcall	ws2812_clear

        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
	add	XL, R1
	ldi	R20, 0x00
	adc	XH, R20
	ldi	R21, 0x01
        st      X, R21

	rcall	ws2812_delay
	rcall	ws2812_update_all

	rcall	delay_10ms

	inc	R16
	cpi	R16, 140
	brne	bounce_loop
	ret

bounce2:
	ldi	R20, 0xCD ; g = 9.8 (9.80078125 rounding error) (8.8 Fixed Point)
	ldi	R21, 0x09
	ldi	R22, 0xF0 ; Initial velocity 32.0 (8.8 Fixed Point)
	ldi	R23, 0x10
	ldi	R24, 0x00 ; Time 0.0625s steps (8.8 Fixed Point)
	ldi	R25, 0x00
bounce2_loop:
	movw	R0, R24 ; Multiplier (t)
	movw	R2, R20 ; Multiplicand (g)
	rcall	multiply16 ; (g*t) (8.8 * 8.8 = 16.16 Fixed Point)
	lsr	R3 ; (gt/2)
	ror	R2
	ror	R1
	ror	R0

	mov	R3, R2 ; Truncate to get 8.8 Fixed Point
	mov	R2, R1

	movw	R0, R22
	sub	R0, R2 ; (v - gt/2)
	sbc	R1, R3

	brmi	bounce2_done ; Cycle complete

	movw	R2, R24 ; Multiplier (t)
	rcall	multiply16 ; t * (v - gt/2) (8.8 * 8.8 = 16.16 Fixed Point)
	mov	R0, R1 ; Truncate to get 8.8 Fixed Point
	mov	R1, R2

	rcall	ws2812_clear

        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
	add	XL, R1
	ldi	R20, 0x00
	adc	XH, R20
	ldi	R21, 0x01
        st      X, R21

	rcall	ws2812_delay
	rcall	ws2812_update_all

	adiw	R24, 0x08
	rjmp	bounce2_loop
bounce2_done:
	ret

.INCLUDE "lib/delay.inc"
.INCLUDE "lib/math.inc"
.INCLUDE "lib/ws2812.inc"
