;
; lcd.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

LCD_STARTUP_SEQUENCE:
.db 0x20,0x80 ; Set 2 line, 5x8 dot display
.db 0x00,0xf0 ; Display on, cursor on, blink
.db 0x00,0x10 ; Clear screen
.db 0x00,0x20 ; Entry mode, left to right, shift every character input
.equ LCD_STARTUP_SEQUENCE_SIZE = 4

pulse_enable:
	mov temp1,temp0

	ldi temp0,LCD_ADDRESS
	ori temp1,(0x04|0x08)
	call i2c_send

	ldi temp1,0x08
	call i2c_send

	ret

write_char:
	;Send first 4 bits of character
	mov temp1,temp0
	andi temp0,0xF0
	ori temp0,1
	call pulse_enable

	;Send first 4 bits of character
	mov temp0,temp1
	andi temp0,0x0F
	lsl temp0
	lsl temp0
	lsl temp0
	lsl temp0
	ori temp0,1
	call pulse_enable

	ret

lcd_init:
	call i2c_init
	
	;Send initial 0 byte
	ldi temp0,LCD_ADDRESS
	ldi temp1,0x00
	call i2c_send

	;Repeatedly try to set to 4 bit mode
	clr loop
	lcd_init_loop:
		ldi temp0,0x30
		call pulse_enable
		
		inc loop
		cpi loop,3
	brlt lcd_init_loop
	ldi temp0,0x20
	call pulse_enable

	;Send the startup command sequence
	ldi ZL,LOW(LCD_STARTUP_SEQUENCE*2)
	ldi ZH,HIGH(LCD_STARTUP_SEQUENCE*2)
	clr loop
	lcd_startup_loop:
		lpm temp0,Z+
		call pulse_enable

		lpm temp0,Z+
		call pulse_enable

		inc loop
		cpi loop,LCD_STARTUP_SEQUENCE_SIZE
	brlt lcd_startup_loop

	ldi temp0,'H'
	call write_char

	ret

lcd_print:
	;TODO Work to do here
	ret