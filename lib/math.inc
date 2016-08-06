.EQU PI    = 0x32  ; 3.125 (4.4 FixedPoint)
.EQU PI_HI = 0x03  ; 3.140625 (8.8 FixedPoint)
.EQU PI_LO = 0x24
.EQU TWO_PI    = 0x65 ; 6.3125 (4.4 FixedPoint)
.EQU TWO_PI_HI = 0x06 ; 6.28125 (8.8 FixedPoint)
.EQU TWO_PI_LO = 0x48 ;
.EQU PI_OVER_TWO    = 0x19  ; 1.5325 (4.4 FixedPoint)
.EQU PI_OVER_TWO_HI = 0x01  ; 1.5703125 (8.8 FixedPoint)
.EQU PI_OVER_TWO_LO = 0x92
.EQU THREE_PI_OVER_TWO    = 0x4B  ; 4.6875 (4.4 FixedPoint)
.EQU THREE_PI_OVER_TWO_HI = 0x04  ; 4.7109375 (8.8 FixedPoint)
.EQU THREE_PI_OVER_TWO_LO = 0xB6

.DSEG
random_seed:	.BYTE 2
rng_seed:	.BYTE 4

.CSEG
shift_right_x7:
	lsr	R1
	ror	R0
shift_right_x6:
	lsr	R1
	ror	R0
shift_right_x5:
	lsr	R1
	ror	R0
shift_right_x4:
	lsr	R1
	ror	R0
shift_right_x3:
	lsr	R1
	ror	R0
shift_right_x2:
	lsr	R1
	ror	R0
shift_right_x1:
	lsr	R1
	ror	R0
	ret

shift_left_x7:
	lsl	R0
	rol	R1
shift_left_x6:
	lsl	R0
	rol	R1
shift_left_x5:
	lsl	R0
	rol	R1
shift_left_x4:
	lsl	R0
	rol	R1
shift_left_x3:
	lsl	R0
	rol	R1
shift_left_x2:
	lsl	R0
	rol	R1
shift_left_x1:
	lsl	R0
	rol	R1
	ret


;==================================================
; Multiply8 - 8 bit X 8 bit multiplication
;   Input: R0 (Multiplier), R1 (Multiplicand)
;   Output: R1:R0 16 bit product
;   Unsafe: R0, R1, R2, R16, SREG
;==================================================
multiply8:
        mov     R2, R1
        clr     R1
        ldi     R16, 0x08
multiply8_loop:
	clc
        sbrc    R0, 0
        add     R1, R2
        ror     R1
        ror     R0
        dec     R16
        brne    multiply8_loop
        ret

;==================================================
; Multiply16 - 16 bit X 16 bit multiplication
;   Input: R1:R0 (Multiplier), R3:R2 (Multiplicand)
;   Output: R3:R2:R1:R0 32 bit product
;   Unsafe: R0, R1, R2, R3, R4, R5, R16, SREG
;==================================================
multiply16:
	movw	R4, R2
	clr	R2
	clr	R3
	ldi	R16, 0x10
multiply16_loop:
	clc
	sbrs	R0, 0
	rjmp	multiply16_skip
	add	R2, R4
	adc	R3, R5
multiply16_skip:
	ror	R3
	ror	R2
	ror	R1
	ror	R0
	dec	R16
	brne	multiply16_loop
	ret

;==================================================
; Divide - Restoring Division
;   Input: R0 (Dividend), R1 (Divisor)
;   Output: R0 8.8 bit quotient
;   Unsafe: R0, R1, R2, R3, R4, R5, R16
;   Ref: users.utcluj.ro/~baruch/book_ssce/SSCE-Basic-Division.pdf
;==================================================
divide1:
	mov	R2, R0 ; Remainder R3:R2
	clr	R3
	clr	R4
	mov	R5, R1 ; Divisor R5:R4
	clr	R0 ; Quotient
	ldi	R16, 0x09
divide1_loop:
	sub	R2, R4 ; Subtract divisor from remainder
	sbc	R3, R5
	brpl	divide1_positive
divide1_restore:
	add	R2, R4 ; Restore Remainder
	adc	R3, R5 ; Restore Remainder
	clc
	rjmp	divide1_done
divide1_positive:
	sec
divide1_done:
	rol	R0 ; Update quotient
	lsr	R5
	ror	R4
	dec	R16
	brne	divide1_loop	

	sbic	0x1F, 0 ; Round up
	inc	R0
	ret

;==================================================
; Divide - Restoring Division (Optimized)
;   Input: R0 (Dividend), R1 (Divisor)
;   Output: R0 (Quotient), R1 (Remainder)
;   Unsafe: R0, R1, R2, R16, SREG
;   Ref: users.utcluj.ro/~baruch/book_ssce/SSCE-Basic-Division.pdf
;==================================================
divide8:
	clr	R2
	ldi	R16, 0x08
divide8_loop:
	lsl	R0
	rol	R2
	sub	R2, R1 ; Subtract divisor from remainder
	brpl	divide8_quotient1
	add	R2, R1 ; Restore Remainder
	rjmp	divide8_done
divide8_quotient1:
	inc	R0
divide8_done:
	dec	R16
	brne	divide8_loop	
	ret

;==================================================
; Divide - (8.8 FixedPoint / 8.8 FixedPoint)
;    Input: R1:R0 (Dividend), R3:R2 (Divisor)
;    Output: R1:R0 (Quotient), R5:R4 (Remainder)
;    Unsafe: R0, R1, R2, R3, R4, R5, R16
;    Ref: users.utcluj.ro/~baruch/book_ssce/SSCE-Basic-Division.pdf
;==================================================
divide16:
	clr	R4
	clr	R5
	ldi	R16, 0x18 ; Why 24 iterations and not 16?
divide16_loop:
	lsl	R0
	rol	R1
	rol	R4
	rol	R5
	sub	R4, R2 ; Subtract divisor from remainder
	sbc	R5, R3
	brpl	divide16_quotient1
divide16_quotient0:
	add	R4, R2 ; Restore Remainder
	adc	R5, R3
	rjmp	divide16_done
divide16_quotient1:
	inc	R0
divide16_done:
	dec	R16
	brne	divide16_loop	
	ret

;==================================================
; Divide - Non-Restoring Division... ToDo
;   Input: R0 (Dividend), R1 (Divisor)
;   Output: R0 (Quotient 8.8 FixedPoint), R2 (Remainder/Modulus)
;   Unsafe: R16
;   Ref: users.utcluj.ro/~baruch/book_ssce/SSCE-Basic-Division.pdf
;==================================================
divide_nonRestoring:
	clr	R2
	ldi	R16, 0x08
divide_nonRestoring_loop:
	lsl	R0
	rol	R2
	brcs	divide_nonRestoring_negative
	sbc	R2, R1 ; Remainder - Divisor
divide_nonRestoring_negative:
	adc	R2, R1 ; Remainder + Divisor
divide_nonRestoring_quotient:
	brmi	divide_nonRestoring_done
	inc	R0
divide_nonRestoring_done:
	dec	R16
	brne	divide_nonRestoring_loop	
; TODO: Fix Remainder by adding divisor back in if negative
	ret

;==================================================
; Divide - SRT... ToDo
;   Input: R0 (Dividend), R1 (Divisor)
;   Output: R0 (Quotient 8.8 FixedPoint), R2 (Remainder/Modulus)
;   Unsafe: R16
;   Ref: users.utcluj.ro/~baruch/book_ssce/SSCE-Basic-Division.pdf
;==================================================
divide_srt:
	clr	R2
	ldi	R16, 0x08
divide_srt_loop:
	lsl	R0
	rol	R2
	brcs	divide_nonRestoring_negative
	sbc	R2, R1 ; Remainder - Divisor
divide_srt_negative:
	adc	R2, R1 ; Remainder + Divisor
divide_srt_quotient:
	brmi	divide_nonRestoring_done
	inc	R0
divide_srt_done:
	dec	R16
	brne	divide_nonRestoring_loop	
	ret

;==================================================
; Random - 8 bit result
;   Output: R0
;   Ref: http://www.avrfreaks.net/forum/tiny-fast-prng
;==================================================
random8:
        ldi     XL, low(random_seed)
        ldi     XH, high(random_seed)
	ldi	R16, 0xAA
	st	X+, R16
	ldi	R17, 0x00
	st	X, R17
random8_next:
        ldi     XL, low(random_seed)
        ldi     XH, high(random_seed)
	ld	R16, X+
	ld	R17, X

	mov	R18, R16
	lsl	R18
	lsl	R18
	lsl	R18
	eor	R16, R18

	mov	R18, R16
	lsr	R18
	lsr	R18
	lsr	R18
	lsr	R18
	lsr	R18
	eor	R16, R18

	lsr	R17
	lsr	R17
	eor	R16, R17

	inc	R17
	st	X, R17
	st	-X, R16

	mov	R0, R16

	ret

;==================================================
; Random - 8 bit result
;   Input: R0, R1, R2
;   Output: R0
;   Ref: http://www.electro-tech-online.com/threads/ultra-fast-pseudorandom-number-generator-for-8-bit.124249/
;==================================================
rng_init:
        ldi     XL, low(rng_seed)
        ldi     XH, high(rng_seed)
	ld	R3, X
	inc	R3
	st	X+, R3
	ld	R3, X
	eor	R3, R0
	st	X+, R3
	ld	R3, X
	eor	R3, R1
	st	X+, R3
	ld	R3, X
	eor	R3, R2
	st	X+, R3
rng_next:
        ldi     XL, low(random_seed)
        ldi     XH, high(random_seed)
	ld	R16, X+
	ld	R17, X+
	ld	R18, X+
	ld	R19, X+

        ldi     XL, low(random_seed)
        ldi     XH, high(random_seed)
	inc	R16
	st	X+, R16

	eor	R17, R16
	eor	R17, R18
	st	X+, R17

	add	R18, R17
	st	X+, R18

	lsr	R18
	eor	R18, R17
	add	R19, R18
	st	X, R19

	mov	R0, R19
	ret

;==================================================
; SquareRoot - 8 bit result (no radix)
;    Input: R0
;    Output: R1:R0 (8.8 FixedPoint)
;==================================================
sqrt:
	clr	R1
	ldi	R16, 0x04
sqrt_loop:
	lsl	R2 ; Make space for next result digit
	lsl	R0 ; Shift two digits into R1
	rol	R1
	lsl	R0
	rol	R1
	breq	sqrt_skip ; If R1 != 0 then
	inc	R2 ; Increment the result
	inc	R3 ; Multiply result by two and add to workspace
	inc	R3 ; same as adding two or incrementing twice
	lsl	R3 ; Make space for next workspace digit
	dec	R1 ; Subtract result from R1
sqrt_skip:
	dec	R16
	brne	sqrt_loop
	ret


;==================================================
; SquareRoot - 16 bit result
;   Input: R0
;   Output: R1:R0 (8.8 FixedPoint)
;   Unsafe: R0, R1, ?
;==================================================
sqrt8:
	mov	R23, R0 ; Input
	clr	R24 ; Remainder low
	clr	R25 ; Remainder high
	clr	R26 ; Result low
	clr	R27 ; Result high
	clr	R28 ; Workspace low
	clr	R29 ; Workspace high
	ldi	R16, 0x0C ; Iterate over 16 bits (2 bits at a time)
sqrt8_loop:
	lsl	R26 ; Result - make space for next bit
	rol	R27
	lsl	R28 ; Workspace - make space for placeholder bit
	rol	R29
	lsl	R23 ; Shift two bits from Input into Remainder
	rol	R24
	rol	R25
	lsl	R23
	rol	R24
	rol	R25
	adiw	R29:R28, 0x01 ; Assume workspace bit is "1" to help logic branch
	cp	R24, R28      ; Determine whether (Remainder - Workspace) would be negative
	cpc	R25, R29
	brlo	sqrt8_skip    ; If Remainder < Workspace then skip subtraction
	adiw	R27:R26, 0x01 ; Add one to Result
	sub	R24, R28
	sbc	R25, R29
	adiw	R29:R28, 0x02 ; Multiply paleholder bit of Workspace by 2
sqrt8_skip:
	sbiw	R29:R28, 0x01 ; Compensate for Workspace bit "1" assumption
	dec	R16
	brne	sqrt8_loop
	movw	R0, R26
	ret


;==================================================
; Sine - Taylor Series x-(x^3)/6
;   Input: R1:R0 (8.8 FixedPoint)
;   Output: R1:R0 (8.8 FixedPoint)
;   Unsafe: R0, R1, R2, R3, R6, R7, R16, R17, SREG
;   Ref: blog.demofox.org/2014/11/04/four-ways-to-calculate-sine-without-trig/
;==================================================
sine2:
	movw	R6, R0 ; Copy x to temp location

; x^2
	movw	R2, R0
	rcall	multiply16
	mov	R0, R1
	mov	R1, R2

; (x^2)/6
	ldi	R16, 0xAB
	ldi	R17, 0x2A
	movw	R2, R16
	rcall	multiply16

; 1 - (x^2)/6
	ldi	R16, 0x00
	ldi	R17, 0x01
	sub	R16, R2
	sbc	R17, R3

; x(1 - (x^2)/6)
	movw	R0, R16
	movw	R2, R6
	rcall	multiply16
	mov	R0, R1
	mov	R1, R2

	ret

;==================================================
; Sine - Taylor Series x-(x^3)/6+(x^5)/120
;    Input: R1:R0 (8.8 FixedPoint)
;    Output: R1:R0 (8.8 FixedPoint)
;    Ref: blog.demofox.org/2014/11/04/four-ways-to-calculate-sine-without-trig/
;==================================================
sine3:
	movw	R6, R0 ; R7:R6 = x

; x^2
	movw	R2, R0
	rcall	multiply16
	mov	R0, R1
	mov	R1, R2
	movw	R8, R0 ; R9:R8 = x^2

; (x^2)/20
	ldi	R16, 0xCD
	ldi	R17, 0x0C
	movw	R2, R16 ; 0.05000305...
	rcall	multiply16

; (1 - (x^2)/20)
	ldi	R16, 0x00
	ldi	R17, 0x01
	sub	R16, R2
	sbc	R17, R3
	movw	R10, R16

; (x^2)/6
        ldi     R16, 0xAB
        ldi     R17, 0x2A
        movw    R2, R16 ; 0.1666717...
	movw	R0, R8  ; x^2
        rcall   multiply16

; ((x^2)/6)(1 - (x^2)/20) = (x^2)/6 - (x^4)/120
	movw	R0, R10
	rcall	multiply16 

; (1 - [(x^2)/6 - (x^4)/120] = 1 - (x^2)/6 + (x^4)/120
	ldi	R16, 0x00
	ldi	R17, 0x01
	sub	R16, R1
	sbc	R17, R2
	movw	R0, R16

; x - (x^3)/6 + (x^5)/120 = x(1 - (x^2)/6 + (x^4)/120)
	movw	R0, R16
	movw	R2, R6
	rcall	multiply16
	mov	R0, R1
	mov	R1, R2

	ret

;==================================================
; Cosine - Taylor Series 1-(x^2)/2
;    Input: R1:R0 (8.8 FixedPoint)
;    Output: R1:R0 (8.8 FixedPoint)
;    Ref: blog.demofox.org/2014/11/04/four-ways-to-calculate-sine-without-trig/
;==================================================
cosine2:
; (x^2)/2
	movw	R2, R0
	rcall	multiply16
	lsr	R2
	ror	R1

; 1 - (x^2)/2
	ldi	R16, 0x00
	ldi	R17, 0x01
	sub	R16, R1
	sbc	R17, R2
	mov	R0, R16

	ret

;==================================================
; Cosine - Taylor Series 1-(x^2)/2+(x^4)/24
;    Input: R1:R0 (8.8 FixedPoint)
;    Output: R1:R0 (8.8 FixedPoint)
;    Ref: blog.demofox.org/2014/11/04/four-ways-to-calculate-sine-without-trig/
;==================================================
cosine3:
; (x^2)/2
	movw	R2, R0
	rcall	multiply16
	lsr	R2
	ror	R1
	mov	R0, R1
	mov	R1, R2
	movw	R6, R0

; (x^2)/12
	ldi	R16, 0xAB
	ldi	R17, 0x2A
	movw	R2, R16
	rcall	multiply16

; (1 - (x^2)/12)
	ldi	R16, 0x00
	ldi	R17, 0x01
	sub	R16, R2
	sbc	R17, R3

; (x^2)/2 - (x^4)/24
	movw	R0, R16
	movw	R2, R6
	rcall	multiply16
	mov	R0, R1
	mov	R1, R2

; 1- (x^2)/2 - (x^4)/24
	ldi	R16, 0x00
	ldi	R17, 0x01
	sub	R16, R0
	sbc	R17, R1
	movw	R0, R16

	ret

;==================================================
; Sine Angle Correction
;    Input: R1:R0 (Angle in radians)
;    Output: R1:R0 (Angle 0 - pi), T (Negative)
;==================================================
sine_angle_correction:
; theta = radians % 2pi
        ldi     R16, TWO_PI_LO
        ldi     R17, TWO_PI_HI
        movw    R2, R16
        rcall   modulo

; theta in range [0 - pi] or [pi - 2pi]
        clt
        ldi     R16, PI_LO
        ldi     R17, PI_HI
        cp      R0, R16
        cpc     R1, R17
        brlo    sine_angle_correction_positive
        breq    sine_angle_correction_positive
        set ; T Flag indicates sine is negative
sine_angle_correction_positive:

; theta = [0 - pi]
        ldi     R16, PI_LO
        ldi     R17, PI_HI
        movw    R2, R16
        rcall   modulo

; If theta [pi/2 - pi] then theta = pi - theta
        ldi     R16, PI_OVER_TWO_LO
        ldi     R17, PI_OVER_TWO_HI
        cp      R0, R16
        cpc     R1, R17
        brlo    sine_angle_correction_increasing
        breq    sine_angle_correction_increasing
        ldi     R16, PI_LO
        ldi     R17, PI_HI
        sub     R16, R0 ; pi - [pi/2 - pi] = [pi/2 - 0]
        sbc     R17, R1
        movw    R0, R16
sine_angle_correction_increasing:

	ret

cosine_angle_correction:
; theta = radians % 2pi
        ldi     R16, TWO_PI_LO
        ldi     R17, TWO_PI_HI
        movw    R2, R16
        rcall   modulo
	movw	R16, R0

; theta <= pi/2
	cpi	R16, PI_OVER_TWO_LO
	ldi	R18, PI_OVER_TWO_HI
	cpc	R17, R18
	brsh	cosine_angle_correction_1
	ret

cosine_angle_correction_1:
; theta <= pi
	set
        cpi     R16, PI_LO
        ldi     R18, PI_HI
	cpc	R17, R18
	brsh	cosine_angle_correction_2
	ldi	R16, PI_LO
	ldi	R17, PI_HI
        sub	R16, R0
	sbc	R17, R1
	movw	R0, R16
	ret

cosine_angle_correction_2:
; theta <= 3pi/2
        cpi     R16, THREE_PI_OVER_TWO_LO
        ldi     R18, THREE_PI_OVER_TWO_HI
	cpc	R17, R18
	brsh	cosine_angle_correction_3
        subi	R16, PI_LO
	sbci	R17, PI_HI
	movw	R0, R16
	ret

cosine_angle_correction_3:
 ; theta <= 2pi
	clt
	ldi	R16, TWO_PI_LO
	ldi	R17, TWO_PI_HI
	sub	R16, R0
	sbc	R17, R1
	movw	R0, R16
	ret

;==================================================
; Modulo
;    Input: R1:R0 (Dividend), R3:R2 (Divisor)
;    Output: R3:R2 (8.8 FixedPoint)
;    Ref: blog.demofox.org/2014/11/04/four-ways-to-calculate-sine-without-trig/
;==================================================
modulo:
	sub	R0, R2
	sbc	R1, R3
	brsh	modulo
	add	R0, R2
	adc	R1, R3
	ret
