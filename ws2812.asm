.DEVICE attiny85

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
	clr	R0
	mov	R1, R0
	inc	R1

	sbi	DDRB, DDB0 ; Pin 5 output
	cbi	PORTB, PB0 ; Assert Pin 5 low
	sbi	PORTB, PB0 ; Assert Pin 5 high
	cbi	PORTB, PB0 ; Assert Pin 5 low

	; Pause >= 50 us (400 cycles)
	ldi	R16, 137 ; 136*3 = 408 cycles
pause:
	dec	R16
	brne	pause

	sbi	PORTB, PB0 ; Assert Pin 5 high
	cbi	PORTB, PB0 ; Assert Pin 5 low

	ldi	R16, 12
bit_high:
	sbi	PINB, PB0 ; T1H
	nop ; 125 ns
	nop ; 250 ns
	nop ; 375 ns
	nop ; 500 ns
	sbi	PINB, PB0 ; T1L
	nop ; 125 ns
	nop ; 250 ns
	nop ; 375 ns
bit_low:
	sbi	PINB, PB0 ; T0H
	nop ; 125 ns
	sbi	PINB, PB0 ; T0L
	nop ; 125 ns
	nop ; 250 ns
	dec	R16 ; 375 ns
	brne	bit_high ; 625 ns

end:
	rjmp	end
