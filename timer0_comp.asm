.DEVICE attiny85

.CSEG
.ORG 0x0000
	rjmp	RESET	; Reset
	reti		; INT0
	reti		; PCINT0
	reti		; TIMER1_COMPA
	reti		; TIMER1_OVF
	rjmp	TIMER0_OVF	; TIMER0_OVF
	reti		; EE_RDY
	reti		; ANA_COMP
	reti		; ADC
	reti		; TIMER1_COMPB
	rjmp	TIMER0_COMPA	; TIMER0_COMPA
	rjmp	TIMER0_COMPB	; TIMER0_COMPB
	reti		; WDT
	reti		; USI_START
	reti		; USI_OVF

RESET:
	clr	R0
	mov	R1, R0
	inc	R1

	ldi	R16, (1<<PB0)
	out	DDRB, R16

	ldi	R16, (1<<WGM01) | (0<<WGM00)
	out	TCCR0A, R16
;	ldi	R16, (1<<CS02) | (0<<CS01) | (1<<CS00)
	in	R16, TCCR0B ; Timer/Counter0 Control Register B
	sbr	R16, (0<<WGM02) | (0<<CS02) | (0<<CS01) | (1<<CS00)
	cbr	R16, (1<<WGM02) | (1<<CS02) | (1<<CS01) | (0<<CS00)
	out	TCCR0B, R16
	ldi	R16, 48
	out	OCR0A, R16
	ldi	R16, 32
	out	OCR0B, R16
	; Timer/Counter Interrupt Mask Register
	ldi	R16, (1<<OCIE0A) | (1<<OCIE0B) | (1<<TOIE0)
	out	TIMSK, R16
	out	TCNT0, R0
	sei

end:
	rjmp	end

TIMER0_OVF:
	out	PORTB, R0
	rjmp	TIMER0_OVF
	reti

TIMER0_COMPA:
	out	PORTB, R1
	reti

TIMER0_COMPB:
	out	PORTB, R0
	reti
