.DEVICE attiny85

.CSEG
.ORG 0x0000
	rjmp	RESET	; Reset
	reti		; INT0
	reti		; PCINT0
	rjmp	TIMER1_COMPA	; TIMER1_COMPA
	rjmp	TIMER1_OVF	; TIMER1_OVF
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

RESET:
	clr	R0
	mov	R1, R0
	inc	R1

	ldi	R16, (1<<PB0)
	out	DDRB, R16

	; set prescaler to 1
	ldi	R16, (1<<CTC1) | (0<<CS13) | (0<<CS12) | (0<<CS11) | (1<<CS10)
	out	TCCR1, R16

	; Timer/Counter Interrupt Mask Register
	ldi	R16, (1<<OCIE1A) | (1<<TOIE1)
	out	TIMSK, R16

	out	TCNT1, R0

	; set timer1 comparatorA
	ldi	R16, 10
	out	OCR1A, R16

	; enable PLL mode
	in	R16, PLLCSR
	ori	R16, (1<<PLLE)
	out	PLLCSR, R16

	; ensure PLOCK is set
plock_check:
	in	R16, PLLCSR
	andi	R16, (1<<PLOCK)
	brne	plock_check
	
	; enable asynchronous mode
	in	R16, PLLCSR
	ori	R16, (1<<PCKE)
	out	PLLCSR, R16


	sei

end:
	rjmp	end

TIMER1_OVF:
	out	PORTB, R0
	rjmp	TIMER1_OVF
	reti

TIMER1_COMPA:
	in	R17, PINB
	eor	R17, R1
	out	PORTB, R17
	reti
