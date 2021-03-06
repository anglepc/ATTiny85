.SET lpd8806_count = 32
.SET lpd8806_RED   = 0x00
.SET lpd8806_GREEN = 0x01
.SET lpd8806_BLUE  = 0x02

.DSEG
lpd8806_strip:
lpd8806_strip_red:       .BYTE lpd8806_count
lpd8806_strip_green:     .BYTE lpd8806_count
lpd8806_strip_blue:      .BYTE lpd8806_count

.CSEG
lpd8806_clear:
        push	R16
        push	R17
        ldi	XL, low(lpd8806_strip_red)
        ldi	XH, high(lpd8806_strip_red)
        ldi	YL, low(lpd8806_strip_green)
        ldi	YH, high(lpd8806_strip_green)
        ldi	ZL, low(lpd8806_strip_blue)
        ldi	ZH, high(lpd8806_strip_blue)
        ldi	R17, 0x80
        ldi	R16, lpd8806_count
lpd8806_clear_loop:
        st	X+, R17
        st	Y+, R17
        st	Z+, R17
        dec	R16
        brne	lpd8806_clear_loop
        pop	R17
        pop	R16
        ret

lpd8806_reset:
	clr	R16
	rcall	spi
;	rcall	spi
	ret

lpd8806_update:
        push    R16
        push    R17
        push    XL
        push    XH
        push    YL
        push    YH
        push    ZL
        push    ZH
        ldi     XL, low(lpd8806_strip_red)
        ldi     XH, high(lpd8806_strip_red)
        ldi     YL, low(lpd8806_strip_green)
        ldi     YH, high(lpd8806_strip_green)
        ldi     ZL, low(lpd8806_strip_blue)
        ldi     ZH, high(lpd8806_strip_blue)
        ldi     R17, lpd8806_count
lpd8806_update_loop:
        ld      R16, Z+
        rcall   spi
        ld      R16, X+
        rcall   spi
        ld      R16, Y+
        rcall   spi
        dec     R17
        brne    lpd8806_update_loop
	clr	R16
	rcall	spi
        pop     ZH
        pop     ZL
        pop     YH
        pop     YL
        pop     XH
        pop     XL
        pop     R17
        pop     R16
        ret
