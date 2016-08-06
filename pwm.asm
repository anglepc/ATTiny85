.DEVICE attiny85

.INCLUDE "lib/common.inc"

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
        ldi     R16, low(RAMEND)
        out     SPL, R16
        ldi     R16, high(RAMEND)
        out     SPH, R16

	; Enable Timer/Counter Synchronization Mode and Reset Prescaler
	ldi	R16, 1<<TSM | 1<<PSR0 ; Other bits are read-only
	out	GTCCR, R16

	rcall	PresetOC0A

	rcall	FastPWM

	; Disable Timer/Counter Synchronization Mode (enables operation)
	in	R16, GTCCR
	cbr	R16, 1<<TSM
	out	GTCCR, R16

	; PB0 output (OC0A output)
	sbi	DDRB, PB0

	rjmp	end

end:
	rjmp	end

PresetOC0A:
	; Normal mode 0<<WGM02, 0<<WGM01, 0<<WGM00
	; Compare Output Mode A - clear OC0A on match 1<<COM0A1, 0<<COM0A0 
	; Compare Output Mode B - OC0B disconnected 0<<COM0B1, 0<<COM0B0 
	; Clock Select (clk(I/O) / 1024) 1<<CS02, 0<<CS01, 1<<CS00
	; Force OCR0A Match 1<<FOC0A
	ldi	R16, 1<<COM0A1 | 0<<COM0A0 | 0<<COM0B1 | 0<<COM0B0 | 0<<WGM01 | 0<<WGM00
	out	TCCR0A, R16
	ldi	R16, 1<<FOC0A | 0<<FOC0B | 0<<WGM02 | 1<<CS02 | 0<<CS01 | 1<<CS00
	out	TCCR0B, R16

	ret

FastPWM:
	ldi	R16, 1<<COM0A1 | 0<<COM0A0 | 1<<WGM01 | 1<<WGM00
	out	TCCR0A, R16
	ldi	R16, 0<<WGM02 | 0<<CS02 | 0<<CS01 | 1<<CS00
	out	TCCR0B, R16

	; 50% Duty Cycle
	ldi	R16, 0x80
	out	OCR0A, R16


	ret
