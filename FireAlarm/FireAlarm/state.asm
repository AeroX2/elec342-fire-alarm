;
; state.asm
;
; Created: 24/03/2018
; Author : James Ridey
;

state_init:
	; Enable interupts on PCMSK0
	ldi temp0,0b0000_0100
	sts PCICR,temp0
	
	; Enable interupts on pins 2 to 5
	ldi temp0,0b0011_1100
	sts PCMSK2,temp0

	sei
	ret

state_poll_buttons:	
	;TODO Probably a better way of doing this
	;Load each bit and set the respective debounce
	in temp0,PIND
	sbrc temp0,2
	ori debounce_0,1
	sbrc temp0,3
	ori debounce_1,1
	sbrc temp0,4
	ori debounce_2,1
	sbrc temp0,5
	ori debounce_3,1

	;Check if a button has been released
	ldi temp0,0x0F
	ldi temp1,0b1111_1110
	cpse debounce_0,temp1
	cbr temp0,0b0001
	cpse debounce_1,temp1
	cbr temp0,0b0010
	cpse debounce_2,temp1
	cbr temp0,0b0100
	cpse debounce_3,temp1
	cbr temp0,0b1000

	sbrs temp0,0
	rjmp done

	in temp0,PORTB
	ldi temp1,1
	eor temp0,temp1
	out PORTB,temp0

	done:
	
	;Shift all the debounce registers
	lsl debounce_0
	lsl debounce_1
	lsl debounce_2
	lsl debounce_3

	ret

state_interrupt:
	;TODO Wake out of sleep
	;TODO Disable pin interrupts
	reti

