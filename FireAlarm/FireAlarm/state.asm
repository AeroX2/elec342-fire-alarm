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
	push temp0
	push temp1
	push temp2
	push temp3
	push loop
	;Fall through
state_poll_buttons:	
	;TODO This debouncing code doesn't work
	clr temp0 ;Hold button pressed state
	in temp1,PIND ;Hold pin state
	ldi temp2,0b1111_1110 ;Hold constant compare value
	
	ldi XL,LOW(DEBOUNCE_MEMORY_LOCATION)
	ldi XH,HIGH(DEBOUNCE_MEMORY_LOCATION)
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
		inc XL
		cpi XL,LOW(DEBOUNCE_MEMORY_LOCATION+8*2)
	brlt debounce_loop
	;Fall Through
state_machine_update:
	clr loop ;Loop counter holder
	clr temp1 ;Current state holder
	mov temp2,temp0 ;Current button

	machine_loop:
	;Shift the state to write
	lsr temp1
	lsr temp1

	mov temp3,state
	andi temp3,0b0000_0011
	cpi temp3,NORMAL
	breq state_normal
	cpi temp3,ALERT
	breq state_alert
	cpi temp3,EVACUATE
	breq state_evacuate
	cpi temp3,ISOLATE
	breq state_isolate

	set_state_normal:
		;TODO Call LCD
		call sound_clear

	state_normal:
		cbr temp1,0b1100_0000
		ori temp1,(NORMAL<<6)

		;Emergency switch pressed
		;sbrc temp0,EMERGENCY_SWITCH
		;rjmp set_state_evacuate

		;If a button has been pressed
		;Set state to alert
		sbrc temp2,0
		rjmp set_state_alert
				
		;Reset switch pressed
		sbrc temp0,RESET_SWITCH
		clr state

		rjmp end

	set_state_alert:
		;TODO Call LCD
	state_alert:
		cbr temp1,0b1100_0000
		ori temp1,(ALERT<<6)
		call sound_alert

		;Emergency switch pressed
		sbrc temp0,EMERGENCY_SWITCH
		rjmp set_state_evacuate

		;Isolate switch pressed
		sbrc temp0,ISOLATE_SWITCH
		rjmp set_state_isolate

		;Reset switch pressed
		sbrc temp0,RESET_SWITCH
		rjmp set_state_normal

		rjmp end

	set_state_evacuate:
		;TODO Call LCD
	state_evacuate:
		cbr temp1,0b1100_0000
		ori temp1,(EVACUATE<<6)
		call sound_evacuate
		
		;Isolate switch pressed
		sbrc temp0,ISOLATE_SWITCH
		rjmp set_state_isolate

		;Reset switch pressed
		sbrc temp0,RESET_SWITCH
		rjmp set_state_normal

		rjmp end

	set_state_isolate:
		call sound_clear
		;TODO Call LCD
	state_isolate:
		cbr temp1,0b1100_0000
		ori temp1,(ISOLATE<<6)

		;Reset switch pressed
		sbrc temp0,RESET_SWITCH
		rjmp set_state_normal

		;Uneeded rjmp end
	end:

	;Shift the state to read
	lsr state
	lsr state
	;Shift the button pressed to read
	lsr temp2

	;Loop
	inc loop
	cpi loop,BUILDINGS
	brlt machine_loop

	;Store the final state
	mov state,temp1

	pop loop
	pop temp3
	pop temp2
	pop temp1
	pop temp0
	ret

state_interrupt:
	;TODO Wake out of sleep
	;cli
	reti

