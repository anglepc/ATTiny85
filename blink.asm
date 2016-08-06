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
	sbi	DDRB, PB3

end:
	sbi	PINB, PB3
	rcall	delay
	rjmp	end

delay: ; R16*(3+40000) = 0.005 - 1.275 seconds 
	push	R16
	push	R17
	push	R18
	ldi	R16, 20 ; 0.1 seconds
delay_R16:
        ldi     R17, 50 
delay_R17: ; 50(4+796)=40,000 cycles = 0.005 seconds 
        ldi     R18, 199 
delay_R18: ; 796 cycles = 0.0000995 seconds 
        dec     R18 
        nop 
	brne    delay_R18
        nop 
        dec     R17 
	brne    delay_R17
        nop 
        dec     R16 
        brne    delay_R16
	pop	R18
	pop	R17
	pop	R16
        ret 
