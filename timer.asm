.DEVICE attiny85

.CSEG
.ORG 0x0000
	rjmp	reset	; Reset
	reti		; INT0
	reti		; PCINT0
	reti		; TIMER1_COMPA
	reti		; TIMER1_OVF
	reti		; TIMER0_OVF
	reti		; EE_RDY
	reti		; ANA_COMP
	reti		; ADC
	reti		; TIMER1_COMPB
	reti		; TIMER0_COMPA
	reti		; TIMER0_COMPB
	reti		; WDT
	reti		; USI_START
	reti		; USI_OVF

reset:
	clr	R0
	mov	R1, R0
	inc	R1
;	ldi	R16, (1<<CS02) | (0<<CS01) | (1<<CS00)
	in	R16, TCCR0B ; Timer/Counter0 Control Register B
	sbr	R16, (1<<CS02) | (0<<CS01) | (1<<CS00)
	out	TCCR0B, R16
	ldi	R16, (1<<PB0)
	out	DDRB, R16
	out	TCNT0, R0

check:
	in	R17, TCNT0
	cpi	R17, 250
	brlo	check
	in	R18, PINB
	eor	R18, R16
	out	PORTB, R18
	out	TCNT0, R0
	rjmp	check	
end:
	rjmp	end
