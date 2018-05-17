/*
 * mcp23s17.asm
 *
 *  Created: 11/05/2018 3:56:24 PM
 *   Author: James Ridey
 */ 

mcp_write_pins:
	push temp1
	push temp0

	sbi PORTB,SLAVE_SELECT

	ldi temp0,0x40
	call spi_send
	ldi temp0,0x12
	call spi_send
	pop temp0
	call spi_send
	pop temp1
	call spi_send

	sbc PORTB,SLAVE_SELECT

	ret