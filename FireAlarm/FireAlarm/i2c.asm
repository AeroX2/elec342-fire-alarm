;
; i2c.asm
;
; Created: 12/0		3/2018
; Author : James Ridey
;

error:
	ret

i2c_wait:
	lds r16,TWCR
	sbrs r16,TWINT 
	call i2c_error_check
	ret

i2c_error_check:
	lds r16,TWSR
	andi r16,0xF8
	cpi r16,START
	brne error
	ret

i2c_start:
	ldi r16,(1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	sts TWCR,r16
	call i2c_wait
	ret

i2c_stop:
	ldi r16, (1<<TWINT)|(1<<TWEN)| (1<<TWSTO)
	sts TWCR, r16 


i2c_slave_write:
	sts TWDR,r16
	ldi r16,(1<<TWINT)|(1<<TWEN)
	sts TWCR,r16
	ret

i2c_data_write:
	sts TWDR,r17
	ldi r16,(1<<TWINT)|(1<<TWEN)
	sts TWCR,r16

i2c_send:
	push r16 ;Save slave address
	push r17 ;Save data to send
	call i2c_start

	pop r16
	call i2c_slave_write

	pop r17
	call i2c_data_write
	call i2c_stop