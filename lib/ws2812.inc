.EQU ws2812_COUNT = 144

.DSEG
ws2812_pixels:
ws2812_pixels_red:      .BYTE ws2812_COUNT
ws2812_pixels_green:    .BYTE ws2812_COUNT
ws2812_pixels_blue:     .BYTE ws2812_COUNT

.CSEG
;============================================================
; Clear - Set all pixel values to zero
;   Input: R1 (0.8 Red Factor), R2, R3
;============================================================
ws2812_clear:
	push	R0
	push	R16
	push	XL
	push	XH
	push	YL
	push	YH
	push	ZL
	push	ZH
        clr     R0
        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
        ldi     YL, low(ws2812_pixels_green)
        ldi     YH, high(ws2812_pixels_green)
        ldi     ZL, low(ws2812_pixels_blue)
        ldi     ZH, high(ws2812_pixels_blue)
	ldi	R16, ws2812_COUNT
ws2812_clear_loop:
	st	X+, R0
	st	Y+, R0
	st	Z+, R0
	dec	R16
	brne	ws2812_clear_loop
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	pop	XH
	pop	XL
	pop	R16
	pop	R0
        ret

;============================================================
; Blur
;============================================================
ws2812_blur:
	push	R0
	push	R1
	push	R2
	push	R3
	push	R4
	push	R16
	push	R17
	push	XL
	push	XH
	push	YL
	push	YH
	push	ZL
	push	ZH

        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
        ldi     YL, low(ws2812_pixels_green)
        ldi     YH, high(ws2812_pixels_green)
        ldi     ZL, low(ws2812_pixels_blue)
        ldi     ZH, high(ws2812_pixels_blue)
	ldi	R16, ws2812_COUNT
ws2812_blur_loop1:
	ld	R0, X
	lsr	R0
	lsr	R0
	st	X+, R0
	dec	R16
	brne	ws2812_blur_loop1

	ldi     XL, low(ws2812_pixels_red)
	ldi     XH, high(ws2812_pixels_red)
	ldi     YL, low(ws2812_pixels_green)
	ldi     YH, high(ws2812_pixels_green)
	clr	R16
ws2812_blur_loop2:
	clr	R5
	clr	R6
	clr	R7
	clr	R8
	clr	R9

	ld	R0, X+
	ld	R1, X+
	ld	R2, X+
	ld	R3, X+
	ld	R4, X+

	add	R5, R0
;	add	R5, R1

	add	R6, R0
	add	R6, R1
	add	R6, R2

	add	R7, R1
	add	R7, R2
	add	R7, R3

	add	R8, R2
	add	R8, R3
	add	R8, R4

;	add	R9, R3
	add	R9, R4

	st	-X, R9
	st	-X, R8
	st	-X, R7
	st	-X, R6
	st	-X, R5

;	st	Y+, R0
;	st	Y+, R1
;	st	Y+, R2
;	st	Y+, R3
;	st	Y+, R4

	adiw	XL, 0x03
	inc	R16
	inc	R16
	inc	R16
	cpi	R16, ws2812_COUNT
	brne	ws2812_blur_loop2

ws2812_blur_done:
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	pop	XH
	pop	XL
	pop	R17
	pop	R16
	pop	R4
	pop	R3
	pop	R2
	pop	R1
	pop	R0
        ret

;============================================================
; Blur
;   Input: R1 (0.8 Red Factor), R2, R3
;============================================================
ws2812_blur1:
	push	R0
	push	R4
	push	R16
	push	R17
	push	XL
	push	XH
	push	YL
	push	YH
	push	ZL
	push	ZH

        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
        ldi     YL, low(ws2812_pixels_green)
        ldi     YH, high(ws2812_pixels_green)
        ldi     ZL, low(ws2812_pixels_blue)
        ldi     ZH, high(ws2812_pixels_blue)
	ldi	R18, ws2812_COUNT
ws2812_blur1_loop:
	ld	R2, X
	lsr	R2
	ld	R3, Y
	lsr	R3
	ld	R4, Z
	lsr	R4

	mov	R5, R2 ; Red
	lsr	R5
	add	R3, R5
	add	R4, R5

	mov	R5, R3 ; Green
	lsr	R5
	add	R2, R5
	add	R4, R5

	mov	R5, R4 ; Blue
	lsr	R5
	add	R2, R5
	add	R3, R5

	st	X+, R2
	st	Y+, R3
	st	Z+, R4

	dec	R18
	brne	ws2812_blur1_loop
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	pop	XH
	pop	XL
	pop	R17
	pop	R16
	pop	R4
	pop	R0
        ret

;============================================================
; Normalize - Average color of each pixel
;   Input: R1 (0.8 Red Factor), R2, R3
;============================================================
ws2812_average:
	push	R0
	push	R4
	push	R16
	push	R17
	push	XL
	push	XH
	push	YL
	push	YH
	push	ZL
	push	ZH

	mov	R4, R1

        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
        ldi     YL, low(ws2812_pixels_green)
        ldi     YH, high(ws2812_pixels_green)
        ldi     ZL, low(ws2812_pixels_blue)
        ldi     ZH, high(ws2812_pixels_blue)
	ldi	R18, ws2812_COUNT
ws2812_average_loop:
	ld	R2, X
	ld	R3, Y
	ld	R4, Z

	clr	R1
	mov	R0, R2
	clr	R6
	add	R0, R3
	adc	R1, R6
	add	R0, R4
	adc	R1, R6
	ldi	R16, 0x56
	ldi	R17, 0x55
	movw	R2, R16
	rcall	multiply16
	st	X+, R2
	st	Y+, R2
	st	Z+, R2

	dec	R18
	brne	ws2812_average_loop
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	pop	XH
	pop	XL
	pop	R17
	pop	R16
	pop	R4
	pop	R0
        ret

;============================================================
; Scale
;   Input: R1 (0.8 Red Factor), R2, R3
;============================================================
ws2812_scale:
	push	R0
	push	R4
	push	R16
	push	R17
	push	XL
	push	XH
	push	YL
	push	YH
	push	ZL
	push	ZH

	mov	R4, R1

        ldi     XL, low(ws2812_pixels_red)
        ldi     XH, high(ws2812_pixels_red)
        ldi     YL, low(ws2812_pixels_green)
        ldi     YH, high(ws2812_pixels_green)
        ldi     ZL, low(ws2812_pixels_blue)
        ldi     ZH, high(ws2812_pixels_blue)
	ldi	R17, ws2812_COUNT
ws2812_scale_loop:
	mov	R1, R4
	ld	R0, X
	rcall	multiply8
	st	X+, R1

	mov	R1, R2
	ld	R0, Y
	rcall	multiply8
	st	Y+, R1

	mov	R1, R3
	ld	R0, Z
	rcall	multiply8
	st	Z+, R1

	dec	R17
	brne	ws2812_scale_loop
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	pop	XH
	pop	XL
	pop	R17
	pop	R16
	pop	R4
	pop	R0
        ret

;============================================================
; Delay the proper number of cycles to reset the WS2812 chips
; and allow them to latch a new set of values for the led
; pixels.
;============================================================
ws2812_delay:
        push    R16
        ldi     R16, 137 ; 136*3 = 408 cycles
ws2812_delay_loop:
        dec     R16
        brne    ws2812_delay_loop
        pop     R16
        ret

;============================================================
; Iterate over each led/pixel.  Write each Red, Green, and
; Blue value in sequence using the ws2812_update routine
;============================================================
ws2812_update_all:
	push	R1
	push	R2
	push	R3
	push	R16 ; Modified by rcall ws2812_update
	push	R17
	push	XL
	push	XH
	push	YL
	push	YH
	push	ZL
	push	ZH
	ldi	XL, low(ws2812_pixels_red)
	ldi	XH, high(ws2812_pixels_red)
	ldi	YL, low(ws2812_pixels_green)
	ldi	YH, high(ws2812_pixels_green)
	ldi	ZL, low(ws2812_pixels_blue)
	ldi	ZH, high(ws2812_pixels_blue)
	ldi	R17, ws2812_COUNT
ws2812_update_all_loop:
	ld	R1, X+
	ld	R2, Y+
	ld	R3, Z+
	rcall	ws2812_update
	dec	R17
	brne	ws2812_update_all_loop
	pop	ZH
	pop	ZL
	pop	YH
	pop	YL
	pop	XH
	pop	XL
	pop	R17
	pop	R16 ; Modified by rcall ws2812_update
	pop	R3
	pop	R2
	pop	R1
	ret

;============================================================
; Convert Register RGB value to Data signal
;   Input: R1, R2, R3 - Red, Greeen, Blue
;   Unsafe: R1, R2, R3, R16
;============================================================
ws2812_update:
        ldi     R16, 24
ws2812_update_loop:
        lsl     R3 ; Blue is third byte
        rol     R1 ; Red is second byte
        rol     R2 ; Green is first byte
        sbi     PINB, PB0
        brcs    ws2812_update_high
ws2812_update_low: ; Cycle timing for a low bit (0)
        sbi     PINB, PB0
        dec     R16
        brne    ws2812_update_loop
        rjmp    ws2812_update_done
ws2812_update_high: ; Cycle timing for a high bit (1)
        nop
        nop
        sbi     PINB, PB0
        dec     R16
        brne    ws2812_update_loop
ws2812_update_done:
        ret
