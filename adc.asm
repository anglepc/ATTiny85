.DEVICE attiny85

.SET TCCR0B_CONF = (1<<CS02) | (0<<CS01) | (1<<CS00) ; Prescaler /1024

.SET REFS = 0<<REFS2 | 0<<REFS1 | 0<<REFS0 ; Voltage Reference to Vcc (REFS2=X)
.SET MUX  = 0<<MUX3 | 0<<MUX2 | 0<<MUX1 | 1<<MUX0 ; Pin 7 ADC1 (PB2)
.SET ADMUX_CONF = REFS | MUX | 1<<ADLAR ; Left adjust 10 bit result

.SET ADCSRA_ADPS = 1<<ADPS2 | 1<<ADPS1| 1<<ADPS0; ADC Prescaler Select Bits - Division Factor 128
.SET ADCSRA_MISC = 1<<ADEN | 1<<ADSC | 1<<ADATE | 1<<ADIE ; ADC Enable, ADC Start Conversion, ADC Auto Trigger Enable, ADC Interrupt Enable
.SET ADCSRA_CONF = ADCSRA_ADPS | ADCSRA_MISC

.SET DIDR0_CONF = 0<<ADC0D | 1<<ADC2D | 0<<ADC3D | 0<<ADC1D ; Digital Input Disable - Disable PB2 Digital Input Buffer

.SET ADCSRB_CONF = 0<<ADTS2 | 0<<ADTS1 | 0<<ADTS0 ; ADC Auto Trigger Source - Free Running mode

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
	rjmp	ADC_vect	; ADC vector
	reti		; TIMER1_COMPB vector
	reti		; TIMER0_COMPA vector
	reti		; TIMER0_COMPB vector
	reti		; WDT vector
	reti		; USI_START vector
	reti		; USI_OVF vector

RESET_vect:
	clr	R0
	mov	R1, R0
	inc	R1

	sbi	DDRB, DDB0 ; Pin 5 output
	cbi	DDRB, DDB2 ; Pin 7 input
	cbi	PORTB, 0 ; Assert Pin 5 low

	; Timer/Counter0 Control Register
	ldi	R16, TCCR0B_CONF
	out	TCCR0B, R16

	; Initialize ADC
	ldi	R16, ADMUX_CONF
	out	ADMUX, R16

	; ADC Control and Status Register B
	ldi	R16, ADCSRB_CONF
	out	ADCSRB, R16

	; Digital Input Disable Register 0
	ldi	R16, DIDR0_CONF
	out	DIDR0, R16

	; ADC Control and Status Register A
	ldi	R16, ADCSRA_CONF
	out	ADCSRA, R16

	sei

	; Initialize Timer/Counter0
	ldi	R16, (1<<CS02) | (0<<CS01) | (1<<CS00) ; 1024 Prescaler
	out	TCCR0B, R16
	out	TCNT0, R0 ; Set Timer0 count to 0

end:
	rjmp	end

delay: ; R16*(3+40000) = 0.005 - 1.275 seconds
	ldi	R17, 50
	delay_outer: ; 50(4+796)=40,000 cycles = 0.005 seconds
	ldi	R18, 199
	delay_inner: ; 796 cycles = 0.0000995 seconds
	dec	R18
	nop
	brne	delay_inner
	nop
	dec	R17
	brne	delay_outer
	nop
	dec	R16
	brne	delay
	ret

ADC_vect:
	in	R16, ADCH
	rcall	delay
	sbi	PINB, PB0 ; Toggle PB0 value
	reti
