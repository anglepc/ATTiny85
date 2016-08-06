.SET ws2801_count = 25
.SET ws2801_RED   = 0x00
.SET ws2801_GREEN = 0x01
.SET ws2801_BLUE  = 0x02

.DSEG
ws2801_strip:
ws2801_strip_red:       .BYTE ws2801_count
ws2801_strip_green:     .BYTE ws2801_count
ws2801_strip_blue:      .BYTE ws2801_count

.CSEG
ws2801_clear:
        push    R1
        push    R2
        push    R3
        push    R4
        push    R16
        clr     R1
        clr     R2
        clr     R3
        ldi     R16, ws2801_count
ws2801_clear_loop:
        mov     R4, R16
        rcall   ws2801_set_rgb
        dec     R16
        brpl    ws2801_clear_loop
        pop     R16
        pop     R4
        pop     R3
        pop     R2
        pop     R1
        ret

ws2801_get_red:
        push    R17
        ldi     R17, ws2801_RED
        mov     R5, R17
        rcall   ws2801_get
        pop     R17
        ret

ws2801_get_green:
        push    R17
        ldi     R17, ws2801_GREEN
        mov     R5, R17
        rcall   ws2801_get
        pop     R17
        ret

ws2801_get_blue:
        push    R17
        ldi     R17, ws2801_BLUE
        mov     R5, R17
        rcall   ws2801_get
        pop     R17
        ret

ws2801_set_red:
        push    R17
        ldi     R17, ws2801_RED
        mov     R5, R17
        rcall   ws2801_set
        pop     R17
        ret

ws2801_set_green:
        push    R17
        ldi     R17, ws2801_GREEN
        mov     R5, R17
        rcall   ws2801_set
        pop     R17
        ret

ws2801_set_blue:
        push    R17
        ldi     R17, ws2801_BLUE
        mov     R5, R17
        rcall   ws2801_set
        pop     R17
        ret

ws2801_set:
        push    R0
        push    XL
        push    XH
        clr     R0
        ldi     XL, low(ws2801_strip)
        ldi     XH, high(ws2801_strip)
        add     XL, R4
        adc     XH, R0
ws2801_set_loop:
        dec     R5
        brmi    ws2801_set_loop_end
        adiw    XH:XL, ws2801_count
        rjmp    ws2801_set_loop
ws2801_set_loop_end:
        st      X, R16
        pop     XH
        pop     XL
        pop     R0
        ret

ws2801_get:
        push    R0
        push    XL
        push    XH
        clr     R0
        ldi     XL, low(ws2801_strip)
        ldi     XH, high(ws2801_strip)
        add     XL, R4
        adc     XH, R0
ws2801_get_loop:
        dec     R5
        brmi    ws2801_get_loop_end
        adiw    XH:XL, ws2801_count
        rjmp    ws2801_get_loop
ws2801_get_loop_end:
        ld      R16, X
        pop     XH
        pop     XL
        pop     R0
        ret

ws2801_set_rgb:
        push    R0
        push    XL
        push    XH
        clr     R0
        ldi     XL, low(ws2801_strip_red)
        ldi     XH, high(ws2801_strip_red)
        add     XL, R4
        adc     XH, R0
        st      X, R1
        adiw    XH:XL, ws2801_count
        st      X, R2
        adiw    XH:XL, ws2801_count
        st      X, R3
        pop     XH
        pop     XL
        pop     R0
        ret

ws2801_update:
        push    R16
        push    R17
        push    XL
        push    XH
        ldi     XL, low(ws2801_strip_red)
        ldi     XH, high(ws2801_strip_red)
        ldi     YL, low(ws2801_strip_green)
        ldi     YH, high(ws2801_strip_green)
        ldi     ZL, low(ws2801_strip_blue)
        ldi     ZH, high(ws2801_strip_blue)
        ldi     R17, ws2801_count
ws2801_update_loop:
        ld      R16, X+
        rcall   spi
        ld      R16, Y+
        rcall   spi
        ld      R16, Z+
        rcall   spi
        dec     R17
        brpl    ws2801_update_loop
        pop     XH
        pop     XL
        pop     R17
        pop     R16
        ret
