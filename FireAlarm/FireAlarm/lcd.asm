;
; lcd.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

LCD_STARTUP_SEQUENCE:
.db 0x20,0x80 ; Set 2 line, 5x8 dot display
.db 0x00,0xc0 ; Display on, cursor on, blink
.db 0x00,0x10 ; Clear screen
.db 0x00,0x20 ; Entry mode, left to right, shift every character input
.equ LCD_STARTUP_SEQUENCE_SIZE = 4

;Private function to pulse the enable line on the LCD
_pulse_enable:
	mov temp1,temp0

	ldi temp0,LCD_ADDRESS
	ori temp1,(0x04|0x08)
	rcall i2c_send

	ldi temp0,LCD_ADDRESS
	ldi temp1,0x08
	rcall i2c_send

	ret

;Private function to write one character to the display
_write_char:
	;Send first 4 bits of character
	mov temp2,temp0
	andi temp0,0xF0
	ori temp0,1
	rcall _pulse_enable

	;Send first 4 bits of character
	mov temp0,temp2
	andi temp0,0x0F
	lsl temp0
	lsl temp0
	lsl temp0
	lsl temp0
	ori temp0,1
	rcall _pulse_enable

	ret

;Function to initialize and clear the LCD display
lcd_init:
	rcall i2c_init
	
	;Send initial 0 byte
	ldi temp0,LCD_ADDRESS
	ldi temp1,0x00
	rcall i2c_send

	;Repeatedly try to set to 4 bit mode
	clr loop
	_lcd_init_loop:
		ldi temp0,0x30
		rcall _pulse_enable
		
		inc loop
		cpi loop,3
	brlt _lcd_init_loop
	ldi temp0,0x20
	rcall _pulse_enable

	;Send the startup command sequence
	ldi ZL,LOW(LCD_STARTUP_SEQUENCE*2)
	ldi ZH,HIGH(LCD_STARTUP_SEQUENCE*2)
	clr loop
	_lcd_startup_loop:
		lpm temp0,Z+
		rcall _pulse_enable

		lpm temp0,Z+
		rcall _pulse_enable

		inc loop
		cpi loop,LCD_STARTUP_SEQUENCE_SIZE
	brlt _lcd_startup_loop

	ret

;Function to display a string on the display
;Param 0: Low address of the string in program memory
;Param 1: High address of the string in program memory
lcd_print:
	;rcall i2c_init

	mov ZL,temp0
	mov ZH,temp1

	;Clear the screen
	ldi temp0,0x00
	rcall _pulse_enable
	ldi temp0,0x10
	rcall _pulse_enable

	ldi temp0,LOW(10000)
	ldi temp1,HIGH(10000)
	ldi temp2,BYTE3(10000)
	rcall delay

	;Loop through each character and print
	_lcd_print_loop:
		lpm temp0,Z+
		tst temp0
		breq _lcd_print_loop_exit
		rcall _write_char

		ldi temp0,LOW(100)
		ldi temp1,HIGH(100)
		ldi temp2,BYTE3(100)
		rcall delay

		rjmp _lcd_print_loop
	_lcd_print_loop_exit:

	ret