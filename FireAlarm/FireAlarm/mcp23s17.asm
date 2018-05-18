/*
 * mcp23s17.asm
 *
 *  Created: 11/05/2018 3:56:24 PM
 *   Author: James Ridey
 */ 

mcp_init:
	ldi temp0,0x00
	ldi temp1,0b1000_0000 ;Configure pin 8 as an INPUT
	ldi temp2,0b0000_0000
	rcall _mcp_write

	ldi temp0,0x0c
	ldi temp1,0b1000_0000 ;Configure pin 8 as a PULLUP
	ldi temp2,0b0000_0000
	rcall _mcp_write

	ret

mcp_write_pins:
	mov temp2,temp1
	mov temp1,temp0
	ldi temp0,0x12
	rcall _mcp_write
	ret

mcp_read_pins:
	mov temp2,temp1
	mov temp1,temp0
	ldi temp0,0x12
	rcall _mcp_read
	ret

_mcp_write:
	push temp0

	cbi PORTB,SLAVE_SELECT

	ldi temp0,0x40
	rcall spi_send
	pop temp0
	rcall spi_send
	mov temp0,temp1
	rcall spi_send
	mov temp0,temp2
	rcall spi_send

	sbi PORTB,SLAVE_SELECT
	ret

_mcp_read:
	push temp0

	cbi PORTB,SLAVE_SELECT

	ldi temp0,0x41
	rcall spi_send
	pop temp0
	rcall spi_send
	mov temp0,temp1
	rcall spi_send
	mov temp0,temp2
	rcall spi_send

	sbi PORTB,SLAVE_SELECT
	ret
