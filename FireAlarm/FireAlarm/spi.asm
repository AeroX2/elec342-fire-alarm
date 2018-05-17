/*
 * spi.asm
 *
 *  Created: 6/05/2018 7:59:08 PM
 *   Author: James Ridey
 */

spi_init:
	ldi temp0,(1<<SPE)|(1<<MSTR)
	out SPCR,temp0

	ret

spi_send:
	out SPDR,temp0
_spi_send_loop:
	in temp0,SPSR
	sbrs temp0,SPIF
	rjmp _spi_send_loop

	in temp0,SPDR
	ret