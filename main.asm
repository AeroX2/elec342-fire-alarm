;
; main.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

.include "lcd.asm"

.org 0x0000
start:
	call lcd_init
	rjmp main

;
; Main code goes here.
;
; Firstly, we initialise the I/O ports that we use
;
main:
	ldi	r16,high(RAMEND)
	out	SPH,r16
	ldi	r16,low(RAMEND)
	out	SPL,r16
	sbi	DDRB,5		; port B pin 5 is an output

loop:
	; TODO Put code here
rjmp loop
