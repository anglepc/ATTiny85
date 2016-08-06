.DEVICE attiny85

.CSEG
.ORG 0x0000
	rjmp	RESET	   ; Reset
	reti		; INT0
	reti		; PCINT0
	reti		; TIMER1_COMPA
	reti		; TIMER1_OVF
	rjmp	TIMER0_OVF ; TIMER0_OVF
	reti		; EE_RDY
	reti		; ANA_COMP
	reti		; ADC
	reti		; TIMER1_COMPB
	reti		; TIMER0_COMPA
	reti		; TIMER0_COMPB
	reti		; WDT
	reti		; USI_START
	reti		; USI_OVF

RESET:
	clr	R0
	mov	R1, R0
	inc	R1

	ldi	R16, (1<<PB0)
	out	DDRB, R16

;	ldi	R16, (1<<CS02) | (0<<CS01) | (1<<CS00)
	in	R16, TCCR0B ; Timer/Counter0 Control Register B
	sbr	R16, (1<<CS02) | (0<<CS01) | (1<<CS00)
	cbr	R16, (0<<CS02) | (1<<CS01) | (0<<CS00)
	out	TCCR0B, R16
	; Timer/ounter Interrupt Mask Register
	ldi	R16, (1<<TOIE0)
	out	TIMSK, R16
	out	TCNT0, R0
	sei

end:
	rjmp	end

TIMER0_OVF:
	in	R18, PINB
	eor	R18, R1
	out	PORTB, R18
	reti
