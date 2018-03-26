;
; main.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

.org 0x0000
	rjmp main
;.org 0x000A
	;rjmp state_interrupt

.nolist
.include "constants.asm"
.include "sound.asm"
.include "state.asm"
.include "i2c.asm"
.include "lcd.asm"
;.include "spi.asm"
.list

; Initialize IO pins
; Initialize LCD display
; Start the main loop
main:
	ldi	temp0,high(RAMEND)
	out	SPH,temp0
	ldi	temp0,low(RAMEND)
	out	SPL,temp0

	;Pull inputs high
	ldi temp0,0b0111_1111
	out PORTD,temp0

	;Configure as outputs
	ldi temp0,0b0011_1110
	out DDRB,temp0

	;sbi PORTB,0

	;Run init procedures
	call lcd_init
	;call state_init

	ldi temp0,LOW(NORMAL_MESSAGE*2)
	ldi temp1,HIGH(NORMAL_MESSAGE*2)
	call lcd_print

	;Main loop
	main_loop:
		call state_update
	rjmp main_loop

; Delay by the number of instructions in r0/r1/r2 as a 24 bit value * 4
; on a 1 MHz machine a value of 250,000 is 1 second: 0x03 0xd0 0x90
; on a 16 MHz machine a value of (16,000,000/4) = 4,000,000 is 1 second: 0x3d 0x09 0x00
delay:
	push temp0
	push temp1
	push temp2

	_delay_loop:
	subi temp0,1
	sbci temp1,0
	sbci temp2,0
	brne _delay_loop

	pop temp2
	pop temp1
	pop temp0
	ret