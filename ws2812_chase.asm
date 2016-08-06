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
	clr	R0
	mov	R1, R0
	inc	R1

	sbi	DDRB, DDB0 ; Pin 5 output

	; Reset 144 element strand
	rcall	ws2812_clear
	rcall	ws2812_delay
	rcall	ws2812_update_all
rjmp	end

	ldi	R17, 0x10
	ldi	R18, 0x10
	ldi	XL, low(ws2812_pixels_red)
	ldi	XH, high(ws2812_pixels_red)
	ldi	YL, low(ws2812_pixels_green)
	ldi	YH, high(ws2812_pixels_green)
	ldi	ZL, low(ws2812_pixels_blue)
	ldi	ZH, high(ws2812_pixels_blue)
	ldi	R16, ws2812_COUNT
populate:
	st	X+, R16
	st	Z+, R18
	inc	R18
	dec	R16
	brne	populate

	rcall	ws2812_delay
	rcall	ws2812_update_all

end:
	rcall	chaseLeft
	rcall	chaseRight

	rjmp	end


chase1:
	ldi	R16, 144
chase1_loop1:
	rcall	ws2812_delay
	ldi	R17, 144
chase1_loop2:
	cpse	R17, R16
	rjmp	chase1_off
chase1_low:
	ldi	R20, 1
	ldi	R21, 1
	ldi	R21, 1
	rcall	ws2812_update
	rjmp	chase1_done
chase1_off:
	rcall	ws2812_clear
chase1_done:
	dec	R17
	brne	chase1_loop2

	dec	R16
	brne	chase1_loop1
	ret

chaseLeft:
	clr	R0
	ldi	R16, ws2812_COUNT - 1
chaseLeft_loop1:
        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
        ldi     YL, low(ws2812_pixels_green)
        ldi     YH, high(ws2812_pixels_green)
        ldi     ZL, low(ws2812_pixels_blue)
        ldi     ZH, high(ws2812_pixels_blue)
	rcall	ws2812_clear
	dec	R1
	inc	R2
	mov	R3, R16
	add	XL, R16
	adc	XH, R0
	add	YL, R16
	adc	YH, R0
	add	ZL, R16
	adc	ZH, R0
	st	X, R1
	st	Y, R2
	st	Z, R3
	rcall	ws2812_delay
	rcall	ws2812_update_all

	dec	R16
	cpi	R16, 0xFF
	brne	chaseLeft_loop1
	ret

chaseRight:
	clr	R16
chaseRight_loop1:
        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
        ldi     YL, low(ws2812_pixels_green)
        ldi     YH, high(ws2812_pixels_green)
        ldi     ZL, low(ws2812_pixels_blue)
        ldi     ZH, high(ws2812_pixels_blue)
	rcall	ws2812_clear
	dec	R1
	inc	R2
	mov	R3, R16
        add     XL, R16
        adc     XH, R0
        add     YL, R16
        adc     YH, R0
        add     ZL, R16
        adc     ZH, R0
        st      X, R1
        st      Y, R2
        st      Z, R3
	rcall	ws2812_delay
	rcall	ws2812_update_all

	inc	R16
	cpi	R16, ws2812_COUNT
	brne	chaseRight_loop1
	ret

.INCLUDE "lib/math.inc"
.INCLUDE "lib/ws2812.inc"
