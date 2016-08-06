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

	sbi	DDRB, PB3

	rcall	spi_init

	rcall	apa102_clear
	rcall	apa102_update
	rcall	delay_1000ms
	rcall	delay_1000ms
	rcall	delay_1000ms
	rcall	delay_1000ms
	rcall	delay_1000ms

end:
	rcall	apa102_test
	rcall	apa102_fade
	rcall	apa102_update

;	sbi	PINB, PB3
;	rcall	delay_1000ms
	rjmp	end

apa102_fade:
        ldi	XL, low(apa102_brightness)
        ldi	XH, high(apa102_brightness)
	ldi	R17, 0xFF
	ldi	R18, 0xE1
	ldi	R16, apa102_count-15
apa102_fade_loop:
	st	X+, R17
	st	X+, R18
	dec	R16
	brne	apa102_fade_loop
	ret

apa102_test:
	ldi	R17, 0x01
	ldi	R18, 0x00
	ldi	R19, 0x00
apa102_test_loop_init:
        ldi	XL, low(apa102_strip_red)
        ldi	XH, high(apa102_strip_red)
        ldi	YL, low(apa102_strip_green)
        ldi	YH, high(apa102_strip_green)
        ldi	ZL, low(apa102_strip_blue)
        ldi	ZH, high(apa102_strip_blue)
	ldi	R16, apa102_count
apa102_test_loop:
	st	X+, R17
;	subi	R17, 0x08
	st	Y+, R18
	st	Z+, R19
	dec	R16
	brne	apa102_test_loop
	ret

.NOLIST
.INCLUDE "lib/apa102.inc"
.INCLUDE "lib/spi.inc"
.INCLUDE "lib/delay.inc"
