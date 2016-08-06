.DEVICE attiny85

.SET USI_WM = 0<<USIWM1 | 1<<USIWM0 ; Three-wire mode
.SET USI_CS = 1<<USICS1 | 0<<USICS0 | 1<<USICLK ; External, positive-edge, USITC strobe
.SET USI_TC = 1<<USITC ; Clock Strobe
.SET USI_CONF = USI_WM | USI_CS | USI_TC

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
	; Physical Pin 5
	cbi	DDRB, DDB0 ; Set as input
	sbi	PORTB, PB0 ; Enable pull-up resistor

	; Physical Pin 6
	sbi	DDRB, DDB1 ; Set as output

	;Physical Pin 7
	sbi	DDRB, DDB2 ; Pin 7 output

	ldi	R16, 'S'
	rcall	spi
	ldi	R16, 'P'
	rcall	spi
	ldi	R16, 'I'
	rcall	spi

end:
	rjmp	end

spi:
	out	USIDR, R16 ; Place output value on USI Data Register
	sbi	USISR, USIOIF ; Clear the Counter Overflow Interrupt Flag
	ldi	R16, USI_CONF
spi_loop:
	out	USICR, R16 ; USI Control Register
	in	R17, USISR
	sbrs	R17, USIOIF
	rjmp	spi_loop
	in	R16, USIDR
	ret
