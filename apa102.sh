#!/bin/bash
./gavrasm/gavrasm apa102.asm
# Fuses
# sudo ~/arduino-1.6.6/hardware/tools/avr/bin/avrdude -p attiny85 -C ~/arduino-1.6.6/hardware/tools/avr/etc/avrdude.conf -c usbtiny -U lfuse:r:-:h -U hfuse:r:-:h
# sudo ~/arduino-1.6.6/hardware/tools/avr/bin/avrdude -p attiny85 -C ~/arduino-1.6.6/hardware/tools/avr/etc/avrdude.conf -c usbtiny -U lfuse:w:0xE2:m

sudo ~/arduino-1.6.6/hardware/tools/avr/bin/avrdude -p attiny85 -C ~/arduino-1.6.6/hardware/tools/avr/etc/avrdude.conf -c usbtiny -U flash:w:apa102.hex:i
