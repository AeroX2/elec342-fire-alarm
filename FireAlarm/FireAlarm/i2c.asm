;
; i2c.asm
;
; Created: 19/03/2018
; Author : James Ridey
;

i2c_init:
	ldi r16,72
	sts TWBR,r16
	ldi r16,(1<<TWEN)
	sts TWCR,r16

	ldi r16,0
	sts TWSR,r16
	ret

i2c_wait:
	lds r16,TWCR
	sbrs r16,TWINT
	rjmp i2c_wait
	ret

i2c_error_check_start:
	lds r16,TWSR
	andi r16,0xF8
	cpi r16,START
	brne error
	ret

test:
	lds r16,TWSR
	andi r16,0xF8
	cpi r16,0x18
	brne error
	ret

test2:
	lds r16,TWSR
	andi r16,0xF8
	cpi r16,0x28
	brne error
	ret

i2c_send:
	push r16 ;Save slave address
	push r17 ;Save data to send
i2c_start:
	ldi r16,(1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	sts TWCR,r16
	call i2c_wait
	call i2c_error_check_start
i2c_slave_write:
	ldi r16,(1<<TWEN)
	sts TWCR,r16
	pop r16
	sts TWDR,r16
	ldi r16,(1<<TWINT)|(1<<TWEN)
	sts TWCR,r16
	call i2c_wait
	call test
i2c_data_write:
	pop r17
	sts TWDR,r17
	ldi r16,(1<<TWINT)|(1<<TWEN)
	sts TWCR,r16
	call i2c_wait
	call test2
i2c_stop:
	ldi r16, (1<<TWINT)|(1<<TWEN)| (1<<TWSTO)
	sts TWCR, r16
	call i2c_wait
	ret

error:
	rjmp error