.DEVICE attiny85

.CSEG
.ORG 0x0000
	rjmp	reset	; Reset vector
	reti		; INT0 vector
	reti		; PCINT0 vector
	reti		; TIMER1_COMPA vector
	reti		; TIMER1_OVF vector
	reti		; TIMER0_OVF vector
	reti		; EE_RDY vector
	reti		; ANA_COMP vector
	rjmp	input	; ADC vector
	reti		; TIMER1_COMPB vector
	reti		; TIMER0_COMPA vector
	reti		; TIMER0_COMPB vector
	reti		; WDT vector
	reti		; USI_START vector
	reti		; USI_OVF vector

reset:
	clr	R0
	mov	R1, R0
	inc	R1
	ldi	R16, (1<<CS02) | (0<<CS01) | (1<<CS00)
	out	TCCR0B, R16
	ldi	R16, (0<<DDB2) | (1<<DDB0)
	out	DDRB, R16

	; Initialize ADC
	in	R16, ADMUX
	andi	R16, (0<<REFS1) | (0<<REFS0) | (1<<ADLAR) | (0<<MUX1)
	ori	R16, (0<<REFS1) | (0<<REFS0) | (1<<ADLAR) | (0<<MUX1)
	out	ADMUX, R16
	in	R16, ADCSRB
	andi	R16, (0<<ADTS2) | (0<<ADTS1) | (0<<ADTS0)
	out	ADCSRB, R16
	in	R16, DIDR0
	ori	R16, (1<<ADC2D)
	out	DIDR0, R16
	in	R16, ADCSRA
	ori	R16, (1<<ADEN) | (1<<ADSC) | (1<<ADIE)
	out	ADCSRA, R16
	sei

	; Initialize Timer/Counter0
	ldi	R16, (1<<CS02) | (0<<CS01) | (1<<CS00) ; 1024 Prescaler
	out	TCCR0B, R16
	out	TCNT0, R0 ; Set Timer0 count to 0

check:
	in	R17, TCNT0
	cp	R17, R19
	brlo	check
	in	R18, PINB
	eor	R18, R16
	out	PORTB, R18
	out	TCNT0, R0
	rjmp	check	
end:
	rjmp	end

input:
	in	R19, ADCH
	cpi	R19, 10
	brlo	input
	ldi	R19, 255
	in	R18, PINB
	eor	R18, R1
	out	PORTB, R18
	reti
