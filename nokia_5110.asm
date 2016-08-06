.DEVICE attiny85

.SET USI_WM = 0<<USIWM1 | 1<<USIWM0 ; Three-wire mode
.SET USI_CS = 1<<USICS1 | 0<<USICS0 | 1<<USICLK ; External, positive-edge, USITC strobe
.SET USI_TC = 1<<USITC ; Clock Strobe
.SET USI_CONF = USI_WM | USI_CS | USI_TC

.SET NOKIA_RST = PB3 ; Reset (Brown)
.SET NOKIA_CE  = PB4 ; Chip Enable (Red)
.SET NOKIA_DC  = PB0 ; Data/Command (Green)
.SET NOKIA_DIN = PB1 ; Serial Data (Yellow)
.SET NOKIA_CLK = PB2 ; Serial Clock (Orange)

.DEF XL	= R26
.DEF XH	= R27

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
	ldi	R16, low(RAMEND)
;	out	SPL, R16
	ldi	R16, high(RAMEND)
;	out	SPH, R16

	sbi	PORTB, NOKIA_RST
	sbi	PORTB, NOKIA_CE
	sbi	PORTB, NOKIA_DC

	sbi	DDRB, NOKIA_RST ; Set as output
	sbi	DDRB, NOKIA_CE  ; Set as output
	sbi	DDRB, NOKIA_DC  ; Set as output
	sbi	DDRB, NOKIA_DIN ; Set as output
	sbi	DDRB, NOKIA_CLK ; Set as output

	sbi	PINB, NOKIA_RST
rcall	delay
	sbi	PINB, NOKIA_RST
rcall	delay

	; Set normal display configuration
	cbi	PORTB, NOKIA_DC ; Command Mode
	ldi	R16, 0x20 ; Function Set (H=0)
	rcall	spi
	ldi	R16, 0x08; Display Configuration (0x08 + 0x00, 0x01, 0x04, 0x05)
	rcall	spi
	ldi	R16, 0x0C; Display Configuration (0x08 + 0x00, 0x01, 0x04, 0x05)
	rcall	spi

	cbi	PORTB, NOKIA_DC ; Command Mode
	ldi	R16, 0x21 ; Function Set (H=1)
	rcall	spi
	ldi	R16, 0xE0 ; Contrast (0x80 + Vop)
	rcall	spi
	ldi	R16, 0x07 ; Temperature Coefficient (0x04 + TC)
	rcall	spi
	ldi	R16, 0x17 ; Bias System (0x10 + BS)
	rcall	spi

;	rcall	nokia5110_fill
;	rcall	nokia5110_test

;	rcall	nokia5110_clear
;	rcall	nokia5110_pattern
	ldi	ZL, low(screen)
	ldi	ZH, high(screen)
	ldi	R16, 0x53
xloop:
	mov	R1, R16
	ldi	R17, 0x2F
yloop:
	mov	R2, R17
;	rcall	nokia5110_point
	rcall	nokia5110_screen
adiw	XH:XL, 0x01
	rcall	delay
	dec	R17
	brne	yloop
	dec	R16
	brne	xloop

	cbi	PORTB, NOKIA_CE
end:
	rjmp	end

nokia5110_clear:
	push	R16
	push	R17
	push	R18
	push	XL
	push	XH
	ldi	XL, low(screen)
	ldi	XH, high(screen)
	clr	R16
	ldi	R18, 0x06
nokia5110_clear_y:
	ldi	R17, 0x54
nokia5110_clear_x:
	st	X+, R16
	dec	R17
	brne	nokia5110_clear_x
	dec	R18
	brne	nokia5110_clear_y
	pop	XH
	pop	XL
	pop	R18
	pop	R17
	pop	R16
	ret

nokia5110_screen:
	push	R16
	push	R17
	push	R18
	push	ZL
	push	ZH
	cbi	PORTB, NOKIA_DC ; Command Mode
	ldi	R16, 0x20
	rcall	spi
	ldi	R16, 0x80
	rcall	spi
	ldi	R16, 0x40
	rcall	spi
	sbi	PORTB, NOKIA_DC ; Data Mode
	ldi	R18, 0x06
nokia5110_screen_y:
	ldi	R17, 0x54
nokia5110_screen_x:
	lpm	R16, Z+
	rcall	spi
	dec	R17
	brne	nokia5110_screen_x
	dec	R18
	brne	nokia5110_screen_y
	pop	ZH
	pop	ZL
	pop	R18
	pop	R17
	pop	R16
	ret

nokia5110_pattern:
	push	R16
	push	XL
	push	XH
	ldi	XL, low(screen)
	ldi	XH, high(screen)
	ldi	R16, 0xFF
nokia5110_pattern_loop:
	st	X+, R16
	dec	R16
	brne	nokia5110_pattern_loop
	pop	XH
	pop	XL
	pop	R16
	ret

nokia5110_point:
	push	R16
	push	R17
	push	ZL
	push	ZH
	ldi	ZL, low(screen)
	ldi	ZH, high(screen)
	add	ZL, R1
	clr	R0
	adc	ZH, R0

	mov	R16, R2
	lsr	R16
	lsr	R16
	lsr	R16
nokia5110_point_y:
	adiw	ZH:ZL, 0x2A ; 42 half of 84
	adiw	ZH:ZL, 0x2A ; 42 half of 84
	dec	R16
	brne	nokia5110_point_y
	
	; Which bit to set within byte
	mov	R16, R2
	andi	R16, 0x07
	clr	R17
	sec
nokia5110_point_bit:
	rol	R17
	dec	R16
	brpl	nokia5110_point_bit

	lpm	R16, Z
	or	R16, R17
	st	Z, R16

nokia5110_point_end:
	pop	ZH
	pop	ZL
	pop	R17
	pop	R16
	ret

nokia5110_test:
	push	R16
	push	R17
	push	R18
	push	R19
	cbi	PORTB, NOKIA_DC ; Command Mode
	ldi	R16, 0x21 ; Function Set (H=1)
	rcall	spi
	; Test Contrast values
	ldi	R17, 0x7F
nokia5110_test_contrast:
	ldi	R16, 0x80 ; Contrast Vop
	add	R16, R17
	mov	R16, R17
	com	R16
	rcall	spi ; 0xE0
		; Test Temperature coefficients
		ldi	R18, 0x03
	nokia5110_test_temperature:
		ldi	R16, 0x04
		add	R16, R18
		rcall	spi
			; Test Bias values
			ldi	R19, 0x06
		nokia5110_test_bias:
			ldi	R16, 0x10
			add	R16, R19
			rcall	spi ; 0x17
			rcall	delay
			dec	R19
			brpl	nokia5110_test_bias
		dec	R18
		brpl	nokia5110_test_temperature
	dec	R17	
	brpl	nokia5110_test_contrast
	pop	R19
	pop	R18
	pop	R17
	pop	R16
	ret

spi:
	push	R16
	push	R17
	push	R18
	cbi	PORTB, NOKIA_CE
	out	USIDR, R16 ; USI Data Register - send R16
	sbi	USISR, USIOIF ; Clear the Counter Overflow Interrupt Flag
	ldi	R17, USI_CONF
spi_loop:
	out	USICR, R17 ; USI Control Register
	in	R18, USISR
	sbrs	R18, USIOIF
	rjmp	spi_loop
;	in	R16, USIDR ; Nokia 5110 does not have an output
	sbi	PORTB, NOKIA_CE
	pop	R18
	pop	R17
	pop	R16
	ret

delay: ; R16*(3+40000) = 0.005 - 1.275 seconds 
	push	R16
	push	R17
	push	R18
	ldi	R16, 20 ; 0.1 seconds
delay_R16:
        ldi     R17, 50 
delay_R17: ; 50(4+796)=40,000 cycles = 0.005 seconds 
        ldi     R18, 199 
delay_R18: ; 796 cycles = 0.0000995 seconds 
        dec     R18 
        nop 
	brne    delay_R18
        nop 
        dec     R17 
	brne    delay_R17
        nop 
        dec     R16 
        brne    delay_R16
	pop	R18
	pop	R17
	pop	R16
        ret 

.CSEG
.ORG 0x0280
screen:
screen_row0:	.DW 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
screen_row1:	.DW 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
screen_row2:	.DW 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
screen_row3:	.DW 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
screen_row4:	.DW 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
screen_row5:	.DW 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


; RAMEND
; SRAM_START
