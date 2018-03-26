;
; i2c.asm
;
; Created: 19/03/2018
; Author : James Ridey
;

i2c_init:
	push temp0

	ldi temp0,0xFF
	out DDRC,temp0
	out PORTC,temp0

	ldi temp0,72
	sts TWBR,temp0

	pop temp0
	ret

_i2c_wait:
	lds temp0,TWCR
	sbrs temp0,TWINT
	rjmp _i2c_wait
	ret

_i2c_stop_wait:
	lds temp0,TWCR
	andi temp0,0b0001_0000
	brne _i2c_stop_wait
	ret

/*_i2c_error_slave:
	lds r16,TWSR
	andi r16,0xF8
	cpi r16,0x28
	brne error

_i2c_error_data:
	lds r16,TWSR
	andi r16,0xF8
	cpi r16,0x28
	brne error*/
	
i2c_send:
	push temp0
	push temp1

	push temp1 ;Save data to send
	push temp0 ;Save slave address
_i2c_start:
	clr temp0
	ldi temp0,(1<<TWINT)|(1<<TWEN)|(1<<TWSTA)
	sts TWCR,temp0
	call _i2c_wait
_i2c_slave_write:
	pop temp0
	sts TWDR,temp0
	ldi temp0,(1<<TWINT)|(1<<TWEN)
	sts TWCR,temp0
	call _i2c_wait
	;call i2c_error_slave
_i2c_data_write:
	pop temp1
	sts TWDR,temp1
	ldi temp0,(1<<TWINT)|(1<<TWEN)
	sts TWCR,temp0
	call _i2c_wait
	;call i2c_error_data
_i2c_stop:
	ldi temp0,(1<<TWINT)|(1<<TWEN)|(1<<TWSTO)
	sts TWCR,temp0
	call _i2c_stop_wait

	pop temp1
	pop temp0
	ret

_error:
	sbi PORTB,3
	rjmp _error