;
; i2c.asm
;
; Created: 19/03/2018
; Author : James Ridey
;

i2c_init:
	ldi temp0,72
	sts TWBR,temp0
	ldi temp0,(1<<TWEN)
	sts TWCR,temp0

	ldi temp0,0
	sts TWSR,temp0
	ret

i2c_wait:
	lds temp0,TWCR
	sbrs temp0,TWINT
	rjmp i2c_wait
	ret

i2c_error_check_start:
	lds temp0,TWSR
	andi temp0,0xF8
	cpi temp0,START
	brne error
	ret

test:
	lds temp0,TWSR
	andi temp0,0xF8
	cpi temp0,0x18
	brne error
	ret

test2:
	lds temp0,TWSR
	andi temp0,0xF8
	cpi temp0,0x28
	brne error
	ret

i2c_send:
	push temp0 ;Save slave address
	push temp1 ;Save data to send
i2c_start:
	ldi temp0,(1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	sts TWCR,temp0
	call i2c_wait
	call i2c_error_check_start
i2c_slave_write:
	ldi temp0,(1<<TWEN)
	sts TWCR,temp0
	pop temp0
	sts TWDR,temp0
	ldi temp0,(1<<TWINT)|(1<<TWEN)
	sts TWCR,temp0
	call i2c_wait
	call test
i2c_data_write:
	pop temp1
	sts TWDR,temp1
	ldi temp0,(1<<TWINT)|(1<<TWEN)
	sts TWCR,temp0
	call i2c_wait
	call test2
i2c_stop:
	ldi temp0,(1<<TWINT)|(1<<TWEN)| (1<<TWSTO)
	sts TWCR,temp0
	call i2c_wait
	ret

error:
	rjmp error