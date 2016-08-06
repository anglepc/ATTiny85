.DEVICE attiny85

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
	cbi	PORTB, PB0 ; Assert Pin 5 low
	sbi	PORTB, PB0 ; Assert Pin 5 high
	cbi	PORTB, PB0 ; Assert Pin 5 low

	; Reset 144 element strand
	rcall	ws2812_delay
	rcall	ws2812_reset

	rcall	ws2812_delay
end:
;	rcall	chase1
	rcall	chase2
	rcall	chase3

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
	rcall	ws2812_pxl
	rjmp	chase1_done
chase1_off:
	rcall	ws2812_pxl_off
chase1_done:
	dec	R17
	brne	chase1_loop2

	dec	R16
	brne	chase1_loop1
	ret

chase2:
	ldi	R16, 144
chase2_loop1:
	rcall	ws2812_delay
	ldi	R17, 144
chase2_loop2:
	cpse	R17, R16
	rjmp	chase2_off
chase2_low:
	dec	R20
	inc	R21
	mov	R22, R16
	rcall	ws2812_pxl
	rjmp	chase2_done
chase2_off:
	rcall	ws2812_pxl_off
chase2_done:
	dec	R17
	brne	chase2_loop2

	dec	R16
	brne	chase2_loop1
	ret

chase3:
	clr	R16
chase3_loop1:
	rcall	ws2812_delay
	ldi	R17, 144
chase3_loop2:
	cpse	R17, R16
	rjmp	chase3_off
chase3_low:
	dec	R20
	inc	R21
	mov	R22, R16
	rcall	ws2812_pxl
	rjmp	chase3_done
chase3_off:
	rcall	ws2812_pxl_off
chase3_done:
	dec	R17
	brne	chase3_loop2

	inc	R16
	cpi	R16, 144
	brne	chase3_loop1
	ret

ws2812_delay:
	push	R16
	ldi	R16, 137 ; 136*3 = 408 cycles
ws2812_delay_loop:
	dec	R16
	brne	ws2812_delay_loop
	pop	R16
	ret

ws2812_reset:
	push	R16
	ldi	R16, 144
ws2812_reset_loop:
	rcall	ws2812_pxl_off
	dec	R16
	brne	ws2812_reset_loop
	pop	R16
	ret

ws2812_pxl_off:
	push	R20
	push	R21
	push	R22
	ldi	R20, 0
	ldi	R21, 0
	ldi	R22, 0
	rcall	ws2812_pxl
	pop	R22
	pop	R21
	pop	R20
	ret

ws2812_pxl: ; Pass in Green (R20), Red (R21), and Blue (R22)
	push	R16
	ldi	R16, 8
ws2812_pxl_green:
	lsl	R20
	sbi	PINB, PB0
	brcs	ws2812_pxl_green_high
ws2812_pxl_green_low:
	sbi	PINB, PB0
	dec	R16
	brne	ws2812_pxl_green
	rjmp	ws2812_pxl_green_done
ws2812_pxl_green_high:
	nop
	nop
	sbi	PINB, PB0
	dec	R16
	brne	ws2812_pxl_green
ws2812_pxl_green_done:

	ldi	R16, 8
ws2812_pxl_red:
	lsl	R21
	sbi	PINB, PB0
	brcs	ws2812_pxl_red_high
ws2812_pxl_red_low:
	sbi	PINB, PB0
	dec	R16
	brne	ws2812_pxl_red
	rjmp	ws2812_pxl_red_done
ws2812_pxl_red_high:
	nop
	nop
	sbi	PINB, PB0
	dec	R16
	brne	ws2812_pxl_red
ws2812_pxl_red_done:

	ldi	R16, 8
ws2812_pxl_blue:
	lsl	R22
	sbi	PINB, PB0
	brcs	ws2812_pxl_blue_high
ws2812_pxl_blue_low:
	sbi	PINB, PB0
	dec	R16
	brne	ws2812_pxl_blue
	rjmp	ws2812_pxl_blue_done
ws2812_pxl_blue_high:
	nop
	nop
	sbi	PINB, PB0
	dec	R16
	brne	ws2812_pxl_blue
ws2812_pxl_blue_done:

	pop	R16
	ret
