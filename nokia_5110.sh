#!/bin/bash
./gavrasm/gavrasm nokia_5110.asm
# Fuses
# sudo ~/arduino-1.6.6/hardware/tools/avr/bin/avrdude -p attiny85 -C ~/arduino-1.6.6/hardware/tools/avr/etc/avrdude.conf -c usbtiny -U lfuse:r:-:h -U hfuse:r:-:h
# sudo ~/arduino-1.6.6/hardware/tools/avr/bin/avrdude -p attiny85 -C ~/arduino-1.6.6/hardware/tools/avr/etc/avrdude.conf -c usbtiny -U lfuse:w:0xE2:m

sudo ~/arduino-1.6.6/hardware/tools/avr/bin/avrdude -p attiny85 -C ~/arduino-1.6.6/hardware/tools/avr/etc/avrdude.conf -c usbtiny -U flash:w:nokia_5110.hex:i
