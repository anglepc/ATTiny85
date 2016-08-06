.DEVICE attiny85

.CSEG
.ORG 0x0000
	rjmp	RESET	; RESET
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
	ldi	R20, 24 ; high cycle count for a zero
	ldi	R21, 60 ; high cycle count for a one

	sbi	DDRB, PB0 ; PB0 output
	sbi	DDRB, PB1 ; PB1 output

	; set prescaler to 1
	ldi	R16, (1<<CTC1) | (1<<PWM1A) | (1<<COM1A1) | (0<<COM1A0) | (0<<CS13) | (0<<CS12) | (0<<CS11) | (1<<CS10)
	out	TCCR1, R16

	; Timer/Counter Interrupt Mask Register
	ldi	R16, (1<<OCIE1A) | (0<<TOIE1)
	out	TIMSK, R16

	out	TCNT1, R0

	; set timer1 comparatorA
	out	OCR1A, R21 ; Output a 1

	; set timer1 comparatorC
	ldi	R16, 78 ; t=1.219us
	out	OCR1C, R16

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

	; Generate a pulse for Logic4 trigger
;	sbi	PINB, PB1
;	cbi	PINB, PB1

	sei

end:
	rjmp	end

TIMER1_OVF:
	cbi	PORTB, 0
	rjmp	TIMER1_OVF
	reti

TIMER1_COMPA:
;	inc	R19
;	sbrc	R19, 3
;	ldi	R19, 0
	out	OCR1A, R20
	reti
