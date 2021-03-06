.SET USI_WM = 0<<USIWM1 | 1<<USIWM0 ; Two-wire mode (SPI)
.SET USI_CS = 1<<USICS1 | 0<<USICS0 | 1<<USICLK ; External, positive-edge, USITC strobe
.SET USI_TC = 1<<USITC ; Clock Strobe
.SET USI_CONF = USI_WM | USI_CS | USI_TC

.CSEG
spi_init:
        cbi     DDRB, DDB0 ; Pin 5 output (DI)
        sbi     DDRB, DDB1 ; Pin 6 output (DO)
        sbi     DDRB, DDB2 ; Pin 7 output (USCK)
	ret

spi:
        push    R16
        push    R17
        push    R18
        out     USIDR, R16    ; USI Data Register - send R16
        sbi     USISR, USIOIF ; Clear the Counter Overflow Interrupt Flag
        ldi     R17, USI_CONF
spi_loop:
        out     USICR, R17    ; USI Control Register
        in      R18, USISR
        sbrs    R18, USIOIF
        rjmp    spi_loop
;       in      R16, USIBR    ; Not utilizing input
        pop     R18
        pop     R17
        pop     R16
        ret
