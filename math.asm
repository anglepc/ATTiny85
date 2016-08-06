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

;	rcall	test_multiply8
	rcall	test_divide
;	rcall	test_sqrt
end:
	rjmp	end

test_multiply8:
	ldi	R16, 0x30
	mov	R0, R16
	ldi	R16, 0x30
	mov	R1, R16
	rcall	multiply8

	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	ldi	R16, 0x10
test_multiply8_loop:
        clr     R17
        sbrc    R1, 7
        ldi     R17, 0x01
        st      X+, R17
        lsl     R0
        rol     R1
        dec     R16
        brne    test_multiply8_loop

	rcall	ws2812_delay
	rcall	ws2812_update_all
	ret

test_divide:
	ldi	R24, 0x0C
	mov	R0, R24
	ldi	R25, 0x03
	mov	R1, R25
	rcall	divide_nonRestoring

	ldi     XL, low(ws2812_pixels_green)
	ldi     XH, high(ws2812_pixels_green)
	ldi	R16, 0x08
test_divide_loop:
        clr     R17
        sbrc    R0, 7
        ldi     R17, 0x01
        st      X+, R17
        lsl     R0
        dec     R16
        brne    test_divide_loop

	rcall	ws2812_delay
	rcall	ws2812_update_all
	ret

result3:
        ldi     R24, 0x80 ; 8.0
        mov     R0, R24
        ldi     R25, 0x08 ; 0.5
        mov     r1, R25
        rcall   multiply8
        mov     R24, R0
        mov     R25, R1
lsr	R25
ror	R24
lsr	R25
ror	R24
lsr	R25
ror	R24
lsr	R25
ror	R24
lsr	R25
ror	R24
lsr	R25
ror	R24
lsr	R25
ror	R24
lsr	R25
ror	R24
        ldi     R16, 0x10
        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
result3_loop:
        sbiw    R25:R24, 0x01
        brmi    result3_done
        st      X+, R16
        rjmp    result3_loop
result3_done:
        rcall   ws2812_update_all

test_sqrt:
	ldi	R16, 143
	mov	R0, R16
	rcall	sqrt8
	mov	R17, R1
        ldi     XL, low(ws2812_pixels_blue)
        ldi     XH, high(ws2812_pixels_blue)
	ldi	R16, 0x10
test_sqrt_loop:
        clr     R22
        sbrc    R1, 7
        ldi     R22, 0x01
        st      X+, R22
        lsl     R0
        rol     R1
        dec     R16
        brne    test_sqrt_loop

	rcall	ws2812_delay
	rcall	ws2812_update_all
	ret	

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

bounce_up:
	ldi	R16, 0x01
	mov	R1, R16
	clr	R2
	clr	R3
	clr	R16
bounce_up_loop1:
        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
	rcall	ws2812_clear
        add     XL, R16
        adc     XH, R0
        st      X, R1
;	rcall	delay_variable_2
	rcall	ws2812_update_all

	inc	R16
	cpi	R16, ws2812_COUNT
	brne	bounce_up_loop1
	ret

.INCLUDE "lib/math.inc"
.INCLUDE "lib/delay.inc"
.INCLUDE "lib/ws2812.inc"
