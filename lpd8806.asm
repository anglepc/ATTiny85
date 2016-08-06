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
	ldi	R16, low(RAMEND)
	out	SPL, R16
	ldi	R16, high(RAMEND)
	out	SPH, R16

	rcall	spi_init

	rcall	lpd8806_clear
	rcall	lpd8806_update

end:
	rcall	lpd8806_test
	rcall	lpd8806_update
	rjmp	end

lpd8806_test:
        ldi	XL, low(lpd8806_strip_red)
        ldi	XH, high(lpd8806_strip_red)
        ldi	YL, low(lpd8806_strip_green)
        ldi	YH, high(lpd8806_strip_green)
        ldi	ZL, low(lpd8806_strip_blue)
        ldi	ZH, high(lpd8806_strip_blue)
	ldi	R17, 0x80
	ldi	R18, 0xA0
	ldi	R19, 0xFF
	ldi	R16, lpd8806_count
lpd8806_test_loop:
	subi	R17, 0xFF
	st	X+, R17
	subi	R18, 0x01
	st	Y+, R18
	dec	R16
	brne	lpd8806_test_loop
	ret

.NOLIST
.INCLUDE "lib/lpd8806.inc"
.INCLUDE "lib/spi.inc"
