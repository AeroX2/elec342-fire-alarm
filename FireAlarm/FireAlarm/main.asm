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
.include "spi.asm"
.include "mcp23s17.asm"
.list

; Initialize IO pins
; Initialize LCD display
; Start the main loop
main:
	ldi	temp0,high(RAMEND)
	out	SPH,temp0
	ldi	temp0,low(RAMEND)
	out	SPL,temp0

	;Configure 0-3 as pullup pins
	ldi temp0,0b0000_1111
	out PORTD,temp0

	;Configure 4-7 as outputs
	ldi temp0,0b1111_0000
	out DDRD,temp0

	;Configure 9-11 and 13 as outputs
	ldi temp0,0b0010_1110
	out DDRB,temp0
	sbi PORTB,SLAVE_SELECT

	;Configure analog pins as inputs
	ldi temp0,0b0000_1110
	out PORTC,temp0

	;Run init procedures
	rcall spi_init
	rcall mcp_init
	rcall lcd_init
	rcall state_init
	
	ldi temp0,LOW(1000)
	ldi temp1,HIGH(1000)
	clr temp2
	rcall delay

	ldi temp0,LOW(NORMAL_MESSAGE*2)
	ldi temp1,HIGH(NORMAL_MESSAGE*2)
	rcall lcd_print

	ldi temp0,0x00
	ldi temp1,0x00
	rcall mcp_write_pins

	clr state

	EEPROM_read:
	sbic EECR,EEPE
	rjmp EEPROM_read

	ldi temp0,0x10
	out EEARH,r16
	out EEARL,r16

	sbi EECR,EERE
	in state,EEDR
	
	clr loop
	mov state_read,state
	_startup_loop:
		mov temp0,state_read
		andi temp0,0b0000_0011
		cpi temp0,ISOLATE
		brne _skip_led_on

		mov temp0,loop
		rcall _turn_on_led

		_skip_led_on:

		lsr state_read
		lsr state_read

		inc loop
		cpi loop,BUILDINGS
	brlt _startup_loop

	;Main loop
	main_loop:
		rcall state_update
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