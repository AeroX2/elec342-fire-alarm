;
; lcd.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

LCD_INIT_SEQUENCE:
.db 0x00,0x30,0x30,0x30,0x20 ; Repeatedly try to set to 4 bit mode

LCD_STARTUP_SEQUENCE:
.db 0x20,0x80 ; Set 2 line, 5x8 dot display
.db 0x00,0xf0 ; Clear screen
.db 0x00,0x10 ; Entry mode, left to right, shift every character input

lcd_init:
	ldi r16,LCD_ADDRESS
	ldi r17,0xFF
	;call i2c_send
	ret

lcd_print:
	;TODO Work to do here
	ret