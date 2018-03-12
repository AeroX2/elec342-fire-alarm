;
; lcd.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

LCD_INIT_SEQUENCE:
.db 0x00,
	0x00

lcd_init:
	;TODO Work to do here	
	ret

;
; Delay by the number of instructions in r20/r21/r22 as a 24 bit value * 4
; on a 1 MHz machine a value of 250,000 is 1 second: 0x03 0xd0 0x90
; on a 16 MHz machine a value of (16,000,000/4) = 4,000,000 is 1 second: 0x3d 0x09 0x00
;

delay
	ldi	r20,BYTE3(SMALL_DELAY)
	ldi	r21,HIGH(SMALL_DELAY)
	ldi	r22,LOW(SMALL_DELAY)

	delay_loop:
		subi r22,0x01
		sbci r21,0x00
		sbci r20,0x00
	brne delay_loop
	ret
