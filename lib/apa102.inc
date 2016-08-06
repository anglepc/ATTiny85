.SET apa102_count = 30

.DSEG
apa102_strip:
apa102_brightness:      .BYTE apa102_count
apa102_strip_red:       .BYTE apa102_count
apa102_strip_green:     .BYTE apa102_count
apa102_strip_blue:      .BYTE apa102_count

.CSEG
apa102_clear:
        push	R16
        push	R17
	push	XL
	push	XH
	push	YL
	push	YH
	push	ZL
	push	ZH

        ldi	XL, low(apa102_brightness)
        ldi	XH, high(apa102_brightness)
        ldi	R17, 0xE0
        ldi	R16, apa102_count
apa102_clear_brightness:
	st	X+, R17
	dec	R16
	brne	apa102_clear_brightness

        ldi	XL, low(apa102_strip_red)
        ldi	XH, high(apa102_strip_red)
        ldi	YL, low(apa102_strip_green)
        ldi	YH, high(apa102_strip_green)
        ldi	ZL, low(apa102_strip_blue)
        ldi	ZH, high(apa102_strip_blue)
        clr	R17
        ldi	R16, apa102_count
apa102_clear_loop:
        st	X+, R17
        st	Y+, R17
        st	Z+, R17
        dec	R16
        brne	apa102_clear_loop

        pop	ZH
        pop	ZL
        pop	YH
        pop	YL
        pop	XH
        pop	XL
        pop	R17
        pop	R16
        ret

apa102_update:
        push    R16
        push    R17
        push    XL
        push    XH
        push    YL
        push    YH
        push    ZL
        push    ZH

apa102_update_start_frame:
	clr	R16
	rcall	spi
	rcall	spi
	rcall	spi
	rcall	spi

        ldi     R24, low(apa102_brightness)
        ldi     R25, high(apa102_brightness)
        ldi     XL, low(apa102_strip_red)
        ldi     XH, high(apa102_strip_red)
        ldi     YL, low(apa102_strip_green)
        ldi     YH, high(apa102_strip_green)
        ldi     ZL, low(apa102_strip_blue)
        ldi     ZH, high(apa102_strip_blue)
        ldi     R17, apa102_count
apa102_update_loop:
	movw	R22, XL
	movw	XL, R24
	ld	R16, X+
	rcall	spi
	movw	R24, XL
	movw	XL, R22

        ld      R16, Z+
        rcall   spi
        ld      R16, Y+
        rcall   spi
        ld      R16, X+
        rcall   spi
        dec     R17
        brne    apa102_update_loop

        pop     ZH
        pop     ZL
        pop     YH
        pop     YL
        pop     XH
        pop     XL
        pop     R17
        pop     R16
        ret
