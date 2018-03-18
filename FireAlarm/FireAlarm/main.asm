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
	sbi	DDRB,SPEAKER_PORT

	;Run init procedures
	;call lcd_init
	;call sound_reset

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

; Delay by the value of the registers in r0/r1/r2 and pass that to the Arduino internal timer
pwm_8x_50:

	sts OCR1BH,r17
	sts OCR1BL,r16

	;Set duty cycle to 50%
	lsr r17
	ror r16
	sts OCR1AH,r17
	sts OCR1AL,r16

	ldi r16,(1<<COM1A0)|(1<<COM1B1)|(1<<WGM11)|(1<<WGM10);0b1010_0011 
	sts TCCR1A,r16 ;Toggle OC1 pin and use Fast PWM with wave generation
	ldi r16,(1<<WGM13)|(1<<WGM12)|(1<<CS11)
	sts TCCR1B,r16 ;8x prescaling, starts the timer

	ret