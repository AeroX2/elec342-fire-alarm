;
; state.asm
;
; Created: 24/03/2018
; Author : James Ridey
;

state_init:
	; Enable interupts on PCMSK2
	ldi temp0,0b0000_0100
	sts PCICR,temp0
	
	; Enable interupts on pins 0 to 3
	ldi temp0,0b0000_1111
	sts PCMSK2,temp0

	sei
	ret

state_update:
	;Fall Through
state_poll_buttons:	
	clr temp0 ;Hold button pressed state
	in temp1,PIND ;Hold pin state
	ldi temp2,0b1111_1110 ;Hold constant compare value
	
	ldi mem0l,LOW(DEBOUNCE_MEMORY_LOCATION)
	ldi mem0h,HIGH(DEBOUNCE_MEMORY_LOCATION)
	debounce_loop:
		;Load debounce state
		ld temp3,X

		;Add 1 to memory if button down
		sbrc temp1,0
		ori temp3,1

		lsr temp1
		lsr temp0
		ori temp0,0b1000_0000

		;Check debounce state
		cpse temp3,temp2
		cbr temp0,0b1000_0000

		;Shift left and save
		lsl temp3
		st X+,temp3

		;Loop 8 times
		inc mem0l
		cpi mem0l,DEBOUNCE_MEMORY_LOCATION+8*2
	brlt debounce_loop
	;Fall Through
state_machine_update:
	sbrc temp0,0
	rjmp toggle
	sbrc temp0,1
	rjmp toggle
	sbrc temp0,2
	rjmp toggle
	sbrc temp0,3
	rjmp toggle
	rjmp done

	toggle:
	in temp0,PORTB
	ldi temp1,1
	eor temp0,temp1
	out PORTB,temp0

	done:
	ret

state_interrupt:
	;TODO Wake out of sleep
	;TODO Disable pin interrupts
	reti

