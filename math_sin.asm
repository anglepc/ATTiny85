.DEVICE attiny85

.INCLUDE "lib/common.inc"

.EQU fq=8000000


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

	sbi	DDRB, DDB0 ; Pin 5 output

	; Reset 144 element strand
	rcall	ws2812_clear
	rcall	ws2812_delay
	rcall	ws2812_update_all

end:
	rcall	test5
	rjmp	end

testB:
	ldi	R16, 0x01
	mov	R15, R16
	ldi	R20, 0x00 ; current blur
	ldi	R21, 0x01 ; scale delta
	ldi	R22, 0x00 ; pixel
	ldi	R23, 0x00
	ldi	R24, 0x00 ; angle
	ldi	R25, 0x00
testB_loop:
	movw	R0, R24 ; radians
	rcall	cosine_angle_correction
	rcall	cosine3
lsr	R1
ror	R0

	brtc	testB_pos
testB_neg:
	movw	R16, R0
	com	R16
	com	R17
	subi	R16, 0xFF
	sbci	R17, 0xFF
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	rjmp	testB_update
testB_pos:
	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
testB_update:
	add	XL, R22
	adc	XH, R23
	st      X, R0

	subi	R24, 0xF5 ; angle step to get one complete cycle in 144 steps
	sbci	R25, 0xFF

; Iterate over all Pixels
	inc	R22
	cpi	R22, ws2812_COUNT
	brne	testB_loop
	ldi	R22, 0x00
	ldi	R23, 0x00

; Render pixels
	sbrc	R20, 0
	rcall	ws2812_blur
	inc	R20
	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear
rcall	delay_1000ms

	clr	R24
	clr	R25
	rjmp	testB_loop
	ret

testA:
	ldi	R16, 0x01
	mov	R15, R16
	ldi	R20, 0x00 ; current scale
	ldi	R21, 0x01 ; scale delta
	ldi	R22, 0x00 ; pixel
	ldi	R23, 0x00
	ldi	R24, 0x00 ; angle
	ldi	R25, 0x00
testA_loop:
	movw	R0, R24 ; radians
	rcall	cosine_angle_correction
	rcall	cosine3
lsr	R1
ror	R0

	brtc	testA_pos
testA_neg:
	movw	R16, R0
	com	R16
	com	R17
	subi	R16, 0xFF
	sbci	R17, 0xFF
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	rjmp	testA_update
testA_pos:
	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
testA_update:
	add	XL, R22
	adc	XH, R23
	st      X, R0

	subi	R24, 0xF5 ; angle step to get one complete cycle in 144 steps
	sbci	R25, 0xFF

; Iterate over all Pixels
	inc	R22
	cpi	R22, ws2812_COUNT
	brne	testA_loop
	ldi	R22, 0x00
	ldi	R23, 0x00

; Amplitude scaling
	mov	R1, R20 ; Red Scale (0.8 FixedPoint)
	ldi	R16, 0x10 ; 1.0 Scale (4.4 FixedPoint)
	mov	R2, R20 ; Green
	ldi	R16, 0x08 ; 0.5 Scale (4.4 FixedPoint)
	mov	R3, R20 ; Blue
	rcall	ws2812_scale
	tst	R21
	brmi	testA_scale_down
testA_scale_up:
	add	R20, R21
	cpi	R20, 0x40
	brsh	testA_scale_down_init
	rjmp	testA_scale_done
testA_scale_up_init:
	ldi	R20, 0x00
	ldi	R21, 0x01
	rjmp	testA_scale_done
testA_scale_down_init:
	ldi	R20, 0x40
	ldi	R21, 0xFF
	rjmp	testA_scale_done
testA_scale_down:
	add	R20, R21
	cpi	R20, 0x00
	brmi	testA_scale_up_init
testA_scale_done:

; Render pixels
	rcall	ws2812_blur
	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear

	clr	R24
	clr	R25
	rjmp	testA_loop
	ret

test9:
	ldi	R16, 0x01
	mov	R15, R16
	ldi	R20, 0x00 ; current scale
	ldi	R21, 0x01 ; scale delta
	ldi	R22, 0x00 ; pixel
	ldi	R23, 0x00
	ldi	R24, 0x00 ; angle
	ldi	R25, 0x00
test9_loop:
	movw	R0, R24 ; radians
	rcall	sine_angle_correction
	rcall	sine2

	brtc	test9_pos
test9_neg:
	movw	R16, R0
	com	R16
	com	R17
	subi	R16, 0xFF
	sbci	R17, 0xFF
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	rjmp	test9_update
test9_pos:
	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
test9_update:
	add	XL, R22
	adc	XH, R23
	st      X, R0

	subi	R24, 0xF5 ; angle step to get one complete cycle in 144 steps
	sbci	R25, 0xFF

; Iterate over all Pixels
	inc	R22
	cpi	R22, ws2812_COUNT
	brne	test9_loop
	ldi	R22, 0x00
	ldi	R23, 0x00

; Amplitude scaling
	mov	R1, R20 ; Red Scale (0.8 FixedPoint)
	ldi	R16, 0x10 ; 1.0 Scale (4.4 FixedPoint)
	mov	R2, R20 ; Green
	ldi	R16, 0x08 ; 0.5 Scale (4.4 FixedPoint)
	mov	R3, R20 ; Blue
	rcall	ws2812_scale
	tst	R21
	brmi	test9_scale_down
test9_scale_up:
	add	R20, R21
	cpi	R20, 0x40
	brsh	test9_scale_down_init
	rjmp	test9_scale_done
test9_scale_up_init:
	ldi	R20, 0x00
	ldi	R21, 0x01
	rjmp	test9_scale_done
test9_scale_down_init:
	ldi	R20, 0x40
	ldi	R21, 0xFF
	rjmp	test9_scale_done
test9_scale_down:
	add	R20, R21
	cpi	R20, 0x00
	brmi	test9_scale_up_init
test9_scale_done:

; Render pixels
	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear

	clr	R24
	clr	R25
	rjmp	test9_loop
	ret

test8:
	ldi	R20, 0x00 ; angle initial value
	ldi	R21, 0x00
	ldi	R22, 0x00 ; pixel
	ldi	R23, 0x00
	movw	R24, R20 ; angle
test8_loop:
	movw	R0, R24 ; radians

	movw	R0, R24
	rcall	sine_angle_correction

	rcall	sine2

; Amplitude scaling
	mov	R16, R20
	movw	R18, R0
test8_scale:
	subi	R18, 0x01
	sbci	R19, 0x00
	brmi	test8_scale_correct
	dec	R16
	brne	test8_scale
	rjmp	test8_scale_done
test8_scale_correct:
	ldi	R18, 0x00
	ldi	R19, 0x00
test8_scale_done:
	movw	R0, R18

	brtc	test8_pos
test8_neg:
	movw	R16, R0
	com	R16
	com	R17
	subi	R16, 0xFF
	sbci	R17, 0xFF
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	rjmp	test8_update
test8_pos:
	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
test8_update:
	add	XL, R22
	adc	XH, R23
	st      X, R0

	subi	R24, 0xF5 ; angle step to get one complete cycle in 144 steps
	sbci	R25, 0xFF
	inc	R22

	cpi	R22, 144
	brne	test8_over
	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear
	ldi	R22, 0x00
	subi	R20, 0xFF ; Add 1 to initial angle
	sbci	R21, 0xFF
	movw	R24, R20
clr	R24
clr	R25
test8_over:
	rjmp	test8_loop
	ret


test7:
	clr	R20
	clr	R21

	ldi	R24, 0x00 ; radians
	ldi	R25, 0x00
	rcall	ws2812_clear
test7_loop:
	movw	R0, R24 ; radians

; theta = radians % 2pi
	ldi	R16, TWO_PI_LO
	ldi	R17, TWO_PI_HI
	movw	R2, R16
	movw	R0, R24
	rcall	modulo

; theta in range [0 - pi] or [pi - 2pi]
	clt
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	cp	R0, R16
	cpc	R1, R17
	brlo	test7_sine_positive
	breq	test7_sine_positive
	set ; T Flag indicates sine is negative
test7_sine_positive:

; theta = [0 - pi]
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	movw	R2, R16
	rcall	modulo

; If theta [pi/2 - pi] then theta = pi - theta
	ldi	R16, PI_OVER_TWO_LO
	ldi	R17, PI_OVER_TWO_HI
	cp	R0, R16
	cpc	R1, R17
	brlo	test7_sine
	breq	test7_sine
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	sub	R16, R0 ; pi - [pi/2 - pi] = [pi/2 - 0]
	sbc	R17, R1	
	movw	R0, R16
test7_sine:

	rcall	sine2
	lsr	R1
	ror	R0
	lsr	R1
	ror	R0
	lsr	R1
	ror	R0
	lsr	R1
	ror	R0

	brtc	test7_pos
test7_neg:
	movw	R16, R0
	com	R16
	com	R17
	subi	R16, 0xFF
	sbci	R17, 0xFF
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	rjmp	test7_update
test7_pos:
	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
test7_update:
	add	XL, R22
	adc	XH, R23
	st      X, R0

	subi	R24, 0xF0 ; angle step
	sbci	R25, 0xFF
	inc	R22

	cpi	R22, 144
	brne	test7_over
	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear
	ldi	R22, 0x00
	subi	R20, 0xF0
	sbci	R21, 0xFF
	movw	R24, R20
test7_over:
	rjmp	test7_loop
	ret


test6:
	clr	R21
	clr	R22
	clr	R23
	ldi	R24, 0x00 ; radians
	ldi	R25, 0x00
	rcall	ws2812_clear
test6_loop:
	movw	R0, R24 ; radians
	adiw	R24, 0x10
	inc	R22

; theta = radians % 2pi
	ldi	R16, TWO_PI_LO
	ldi	R17, TWO_PI_HI
	movw	R2, R16
	movw	R0, R24
	rcall	modulo

; theta in range [0 - pi] or [pi - 2pi]
	clt
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	cp	R0, R16
	cpc	R1, R17
	brlo	test6_sine_positive
	breq	test6_sine_positive
	set ; T Flag indicates sine is negative
test6_sine_positive:

; theta = [0 - pi]
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	movw	R2, R16
	rcall	modulo

; If theta [pi/2 - pi] then theta = pi - theta
	ldi	R16, PI_OVER_TWO_LO
	ldi	R17, PI_OVER_TWO_HI
	cp	R0, R16
	cpc	R1, R17
	brlo	test6_sine
	breq	test6_sine
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	sub	R16, R0 ; pi - [pi/2 - pi] = [pi/2 - 0]
	sbc	R17, R1	
	movw	R0, R16
test6_sine:

	rcall	sine2
	lsr	R1
	ror	R0
	lsr	R1
	ror	R0
	lsr	R1
	ror	R0
	lsr	R1
	ror	R0

	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	add	XL, R22
	adc	XH, R23
	st      X, R0


	cpi	R22, 143
	brne	test6_over
	rcall	ws2812_delay
	rcall	ws2812_update_all
	clr	R22
	inc	R21
	mov	R24, R21
	clr	R25
test6_over:
	rjmp	test6_loop
	ret

test5:
	ldi	R24, 0x00 ; radians
	ldi	R25, 0x00
test5_loop:
	movw	R0, R24 ; radians
	adiw	R24, 0x01

; theta = radians % 2pi
	ldi	R16, TWO_PI_LO
	ldi	R17, TWO_PI_HI
	movw	R2, R16
	rcall	modulo

; theta in range [0 - pi] or [pi - 2pi]
	clt
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	cp	R0, R16
	cpc	R1, R17
	brlo	test5_sine_positive
	breq	test5_sine_positive
	set ; T Flag indicates sine is negative
test5_sine_positive:

; theta = [0 - pi]
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	movw	R2, R16
	rcall	modulo

; If theta [pi/2 - pi] then theta = pi - theta
	ldi	R16, PI_OVER_TWO_LO
	ldi	R17, PI_OVER_TWO_HI
	cp	R0, R16
	cpc	R1, R17
	brlo	test5_sine
	breq	test5_sine
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	sub	R16, R0 ; pi - [pi/2 - pi] = [pi/2 - 0]
	sbc	R17, R1	
	movw	R0, R16
test5_sine:

	movw	R2, R0
	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
	ldi	R17, 0x10
test5_blue_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test5_blue_loop
	movw	R0, R2

	rcall	sine2

	mov	R4, R0
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	adiw	XL, 0x00
	st      X, R0

	ldi     XL, low(ws2812_pixels_green)
	ldi     XH, high(ws2812_pixels_green)
	adiw	XL, 0x10
	ldi	R17, 0x10
test5_green_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test5_green_loop

test5_done:
	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear
	rcall	delay_1000ms

	rjmp	test5_loop
	ret

test4:
	ldi	R24, 0x00 ; radians
	ldi	R25, 0x00
test4_loop:
; Output radians
	movw	R0, R24 ; radians
	adiw	R24, 0x01

	ldi     XL, low(ws2812_pixels_green)
	ldi     XH, high(ws2812_pixels_green)
	ldi	R17, 0x10
test4_rad_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test4_rad_loop

; theta = radians % 2pi
	ldi	R16, TWO_PI_LO
	ldi	R17, TWO_PI_HI
	movw	R2, R16
	movw	R0, R24
	rcall	modulo

	clt
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	cp	R0, R16
	cpc	R1, R17
	brlo	test4_sine_positive
	breq	test4_sine_positive
	set ; T Flag indicates sine is negative
test4_sine_positive:

; Output sign of Sine
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	bld	R22, 0
	st      X, R22

; Output radians % 2pi
	movw	R4, R0 ; Make a copy of truncated radians
	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
	adiw	XL, 0x10
	ldi	R17, 0x10
test4_blue_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test4_blue_loop

; theta = theta % pi
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	movw	R2, R16
	movw	R0, R4
	rcall	modulo

; Output theta % pi
	movw	R4, R0
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	adiw	XL, 0x20
	ldi	R17, 0x10
test4_red_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test4_red_loop

; If theta [pi/2 - pi] then theta = pi - theta
	ldi	R16, PI_OVER_TWO_LO
	ldi	R17, PI_OVER_TWO_HI
	cp	R4, R16
	cpc	R5, R17
	brlo	test4_sine
	breq	test4_sine
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	sub	R16, R4 ; pi - [pi/2 - pi] = [pi/2 - 0]
	sbc	R17, R5	
	movw	R4, R16
test4_sine:
	movw	R0, R4

	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
	adiw	XL, 0x30
	ldi	R17, 0x10
test4_blue2_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test4_blue2_loop

	movw	R0, R4
	rcall	sine2
	lsr	R1
	ror	R0
	lsr	R1
	ror	R0
	lsr	R1
	ror	R0
	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	adiw	XL, 0x30
	st      X, R0

	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear
;	rcall	delay_10ms

	rjmp	test4_loop
	ret

test3:
	clr	R24
	clr	R25
test3_loop:
	movw	R0, R24 ; Dividend
	movw	R2, R20 ; Divisor
	adiw	R24, 0x01

	ldi	R16, TWO_PI_LO
	ldi	R17, TWO_PI_HI
	movw	R2, R16
	rcall	divide16 ; R5:R4 (Modulus) 0 - 2pi

	movw	R0, R4
	ldi	R16, PI_LO
	ldi	R17, PI_HI
	movw	R2, R16
	rcall	divide16 ; R5:R4 (Modulus) 0 - pi
	bst	R1, 0 ; SREG T Flag set if sine is negative

; LED #1 lit when radians in range pi - 2pi
	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
	bld	R22, 0
	st      X+, R22

	movw	R0, R4
	ldi	R16, PI_OVER_TWO_LO
	ldi	R17, PI_OVER_TWO_HI
	movw	R2, R16
	rcall	divide16 ; R5:R4 (Modulus) 0 - pi

; LED #2 lit when radians in range pi/2 - pi
	ldi     XL, low(ws2812_pixels_green+1)
	ldi     XH, high(ws2812_pixels_green)
	ldi	R22, 0x01
	sbrc	R1, 0
	st      X, R22

rcall	delay_100ms
	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear

	rjmp	test3_loop
	ret

test2:
	clr	R24
	clr	R25
test2_loop:
	movw	R0, R24 ; Dividend
	movw	R2, R20 ; Divisor
	adiw	R24, 0x01

	ldi	R16, TWO_PI_LO
	ldi	R17, TWO_PI_HI
	movw	R2, R16
	rcall	divide16 ; R5:R4 (Modulus) 0 - 2pi
	movw	R0, R4

	ldi     XL, low(ws2812_pixels_green)
	ldi     XH, high(ws2812_pixels_green)
	ldi	R17, 0x10
test2_green_loop:
	clr	R22
	sbrc	R5, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R4
	rol	R5
	dec	R17
	brne	test2_green_loop

	ldi	R16, PI_LO
	ldi	R17, PI_HI
	movw	R2, R16
	rcall	divide16 ; R5:R4 (Modulus) 0 - pi
	bst	R1, 0 ; SREG T Flag set if sine is negative

	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
	ldi	R22, 0x01
	st      X+, R22

rcall	delay_100ms
	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear

	rjmp	test2_loop
	ret

test1:
	clr	R24
	clr	R25
	ldi	R20, PI_LO
	ldi	R21, PI_HI
test1_loop:
	movw	R0, R24 ; Dividend
	movw	R2, R20 ; Divisor
	adiw	R24, 0x01

	ldi     XL, low(ws2812_pixels_green)
	ldi     XH, high(ws2812_pixels_green)
	ldi	R17, 0x10
test1_rad_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test1_rad_loop

	movw	R0, R24 ; Dividend
	rcall	divide16 ; R1:R0 (Quotient), R5:R4 (Modulus)

	ldi     XL, low(ws2812_pixels_blue)
	ldi     XH, high(ws2812_pixels_blue)
	adiw	XL, 0x10
	ldi	R17, 0x10
test1_blue_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test1_blue_loop

	movw	R0, R24
	rcall	modulo

	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	adiw	XL, 0x20
	ldi	R17, 0x10
test1_red_loop:
	clr	R22
	sbrc	R1, 7
	ldi	R22, 0x01
	st      X+, R22
	lsl	R0
	rol	R1
	dec	R17
	brne	test1_red_loop

	rcall	ws2812_delay
	rcall	ws2812_update_all
	rcall	ws2812_clear
	rcall	delay_10ms

	rjmp	test1_loop
	ret

.NOLIST
.INCLUDE "lib/delay.inc"
.INCLUDE "lib/math.inc"
.INCLUDE "lib/ws2812.inc"
