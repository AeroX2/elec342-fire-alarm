;
; i2c.asm
;
; Created: 19/03/2018
; Author : James Ridey
;

i2c_init:
	ldi temp0,0xFF
	out DDRC,temp0
	out PORTC,temp0

	ldi temp0,72
	sts TWBR,temp0

	ret

i2c_wait:
	lds temp0,TWCR
	sbrs temp0,TWINT
	rjmp i2c_wait
	ret

i2c_stop_wait:
	lds temp0,TWCR
	andi temp0,0b0001_0000
	brne i2c_stop_wait
	ret

i2c_error_slave:
	lds r16,TWSR
	andi r16,0xF8
	cpi r16,0x28
	brne error

i2c_error_data:
	lds r16,TWSR
	andi r16,0xF8
	cpi r16,0x28
	brne error
	
i2c_send:
	push temp1 ;Save data to send
	push temp0 ;Save slave address
i2c_start:
	clr temp0
	ldi temp0,(1<<TWINT)|(1<<TWEN)|(1<<TWSTA)
	sts TWCR,temp0
	call i2c_wait
i2c_slave_write:
	pop temp0
	sts TWDR,temp0
	ldi temp0,(1<<TWINT)|(1<<TWEN)
	sts TWCR,temp0
	call i2c_wait
	;call i2c_error_slave
i2c_data_write:
	pop temp1
	sts TWDR,temp1
	ldi temp0,(1<<TWINT)|(1<<TWEN)
	sts TWCR,temp0
	call i2c_wait
	;call i2c_error_data
i2c_stop:
	ldi temp0,(1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
	sts TWCR,temp0
	call i2c_stop_wait
	ret

error:
	sbi PORTB,3
	rjmp error