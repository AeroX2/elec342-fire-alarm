/*;
; i2c.asm
;
; Created: 12/0		3/2018
; Author : James Ridey
;

i2c_wait:
	in r16,TWCR0
	sbrs r16,TWINT
	rjmp i2c_wait	call i2c_error_check
	ret

i2c_error_check:
	in r16,TWSR0
	andi r16,0xF8
	cpi r16,START
	brne ERROR
	ret

i2c_start:
	ldi r16,(1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	out TWCR0,r16	call i2c_wait	reti2c_slave_write:
	out TWDR0,r16
	ldi r16,(1<<TWINT)|(1<<TWEN)
	out TWCR0,r16	call i2c_wait	ret
i2c_data_write:
	ldi r16,DATA
	out TWDR0,r16
	ldi r16,(1<<TWINT)|(1<<TWEN)
	out TWCR,r16
	call i2c_wait
	ret

i2c_stop:
	ldi r16,(1<<TWINT)|(1<<TWEN)| (1<<TWSTO)
	out TWCR0,r16
	ret

i2c_send:
	push r16 ;Save slave address
	push r17 ;Save data to send
	call i2c_start

	;pop r16
	;call i2c_slave_write

	;pop r17
	;call i2c_data_write
	;call i2c_stop
*/