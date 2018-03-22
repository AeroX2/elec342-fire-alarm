;
; main.asm
;
; Created: 12/03/2018
; Author : James Ridey
;
.org 0x0000

start:
	rjmp main

.nolist
.include "constants.asm"
.include "sound.asm"
;.include "state.asm"
.include "i2c.asm"
.include "lcd.asm"
;.include "spi.asm"
.list

; Initialize IO pins
; Initialize LCD display
; Start the main loop
main:
	ldi	r16,high(RAMEND)
	out	SPH,r16
	ldi	r16,low(RAMEND)
	out	SPL,r16

	ldi r16,0xFF
	out DDRC,r16
	out PORTC,r16

	;Run init procedures
	;call sound_init
	call lcd_init

	;Main loop
	loop:
		;call sound_alarm
	rjmp loop

; Delay by the number of instructions in r0/r1/r2 as a 24 bit value * 4
; on a 1 MHz machine a value of 250,000 is 1 second: 0x03 0xd0 0x90
; on a 16 MHz machine a value of (16,000,000/4) = 4,000,000 is 1 second: 0x3d 0x09 0x00
delay:
	subi r16,1
	sbci r17,0
	sbci r18,0
	brne delay
	ret