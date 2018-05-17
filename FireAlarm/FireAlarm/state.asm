;
; state.asm
;
; Created: 24/03/2018
; Author : James Ridey
;

state_init:
	push temp0

	; Enable interupts on PCMSK2
	ldi temp0,0b0000_0100
	sts PCICR,temp0
	
	; Enable interupts on pins 0 to 3
	ldi temp0,0b0000_1111
	sts PCMSK2,temp0

	;Enable global interupts
	sei

	pop temp0
	ret

state_interrupt:
	;TODO Wake out of sleep
	;cli
	reti

_state_scan:
	push loop
	push temp2

	ldi loop,BUILDINGS
	_state_scan_loop:
		;Check if the state is the same
		mov temp2,temp0
		andi temp2,0b0000_0011
		cp temp2,temp1
		breq found

		;Next state to read
		lsr temp0
		lsr temp0

		dec loop
	brge _state_scan_loop
	rjmp not_found
	
	;State was found, set temp0 to 1
	found:
	ldi temp0,1
	pop temp2
	pop loop
	ret
	
	not_found:
	ldi temp0,0

	pop temp2
	pop loop
	ret

state_update:
	push temp0
	push temp1
	push temp2
	push temp3
	push loop
	;Fall through
_state_poll_buttons:	
	;TODO This debouncing code doesn't work or does it?????

	in temp1,PIND ;Hold pin state
	ldi temp2,0b1111_1110 ;Hold constant compare value
	
	in temp0,PINC
	andi temp1,0b0000_1111 ;Ignore the LED pins
	lsl temp0
	lsl temp0
	lsl temp0
	lsl temp0
	or temp1,temp0

	clr temp0 ;Hold button pressed state

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
_state_machine_update:	
	clr state_write
	mov state_read,state
	mov buttons,temp0
	mov buttons_read,temp0

	;Check if any state is in alert
	mov temp0,state
	ldi temp1,ALERT
	call _state_scan
	mov alert_on,temp0

	;Check if any state is in evacuate
	mov temp0,state
	ldi temp1,EVACUATE
	call _state_scan
	mov evac_on,temp0

	;Loop 4 times for each sensor
	clr loop
	_machine_loop:
		rcall _state_machine_jump_table

		inc loop
		cpi loop,BUILDINGS
	brlt _machine_loop

	;Store the final state
	mov state,state_write

	;Write led state to MCP
	ldi temp0,0x00
	in temp1,PORTD
	lsr temp1
	lsr temp1
	lsr temp1
	lsr temp1
	call mcp_write_pins

	pop loop
	pop temp3
	pop temp2
	pop temp1
	pop temp0
	ret

_state_machine_jump_table:
	;Shift the state to write
	lsr state_write
	lsr state_write

	mov temp0,state_read
	andi temp0,0b0000_0011
	cpi temp0,NORMAL
	breq _state_normal_jump
	cpi temp0,ALERT
	breq _state_alert_jump
	cpi temp0,EVACUATE
	breq _state_evacuate_jump
	cpi temp0,ISOLATE
	breq _state_isolate_jump

	_state_normal_jump:
		rcall _state_normal
		rjmp end
	_state_alert_jump:
		rcall _state_alert
		rjmp end
	_state_evacuate_jump:
		rcall _state_evacuate
		rjmp end
	_state_isolate_jump:
		rcall _state_isolate
		;Uneeded rjmp end
	end:

	;Shift the state to read
	lsr state_read
	lsr state_read
	;Shift the button pressed to read
	lsr buttons_read

	ret

_set_state_normal_reset:
	ldi last_alert_time_l,0
	ldi last_alert_time_h,0
	ldi last_alert_time_h2,0
_set_state_normal:
	ldi temp0,LOW(NORMAL_MESSAGE*2)
	ldi temp1,HIGH(NORMAL_MESSAGE*2)
	rcall lcd_print
	rcall sound_clear

	push loop
		;Turn off the led associated with this sensor
		in temp0,PORTD
		ldi temp1,0b1111_0111
		shift:
			lsl temp1
			dec loop
		brge shift
		and temp0,temp1
		out PORTD,temp0
	pop loop

	;Fall through
_state_normal:
	cbr state_write,0b1100_0000
	ori state_write,(NORMAL<<6)

	;Skip if the emergency button isn't pressed
	sbrs buttons,EMERGENCY_SWITCH
	rjmp _state_normal_jump1

	;Set state to evac if there isn't already an alert or evac happening
	mov temp0,alert_on
	or temp0,evac_on
	cpi temp0,0
	breq _set_state_evacuate

	_state_normal_jump1:

	;If a button has been pressed
	;Set state to alert
	sbrc buttons_read,0
	rjmp _set_state_alert

	ret

_set_state_alert:
	ldi temp0,LOW(ALERT_MESSAGE*2)
	ldi temp1,HIGH(ALERT_MESSAGE*2)
	rcall lcd_print

	;Reset last_alert_time if it is zero
	ldi temp0,0
	cp temp0,last_alert_time_l
	cpc temp0,last_alert_time_h
	cpc temp0,last_alert_time_h2
	breq _set_state_alert_jump2

	ldi last_alert_time_l,LOW(ALERT_TIMEOUT)
	ldi last_alert_time_h,HIGH(ALERT_TIMEOUT)
	ldi last_alert_time_h2,BYTE3(ALERT_TIMEOUT)

	_set_state_alert_jump2:

	push loop
		;Write the sensor value to the LCD
		mov temp0,loop
		ldi temp1,49
		add temp0,temp1
		rcall _write_char
	pop loop
	;Fall through
_state_alert:
	;There is another alert/evac happening
	mov temp0,state_write
	ldi temp1,ALERT
	rcall _state_scan
	mov temp2,temp0
	mov temp0,state_write
	ldi temp1,EVACUATE
	rcall _state_scan
	or temp2,temp0
	cpi temp2,1
	breq _set_state_evacuate

	;Deliberate: this needs to be after the code above
	cbr state_write,0b1100_0000
	ori state_write,(ALERT<<6)
	rcall sound_alert

	;Toggle led
	in temp0,PORTD
	ldi temp1,0b0000_1000
	mov temp2,loop
	shift2:
		lsl temp1
		dec temp2
	brge shift2
	or temp0,temp1
	out PORTD,temp0

	;Reset switch pressed
	sbrc buttons,RESET_SWITCH
	rjmp _set_state_normal_reset

	;Emergency switch pressed
	sbrc buttons,EMERGENCY_SWITCH
	rjmp _set_state_evacuate

	;Isolate switch pressed
	sbrc buttons,ISOLATE_SWITCH
	rjmp _set_state_isolate

	subi last_alert_time_l,1
	sbci last_alert_time_h,0
	sbci last_alert_time_h2,0
	brne _state_alert_jump1
	rjmp _set_state_evacuate

	_state_alert_jump1:

	ret

_set_state_evacuate:
	;TODO PORTD led for evac?
	ldi temp0,LOW(EVACUATE_MESSAGE*2)
	ldi temp1,HIGH(EVACUATE_MESSAGE*2)
	rcall lcd_print
	;Fall through
_state_evacuate:
	cbr state_write,0b1100_0000
	ori state_write,(EVACUATE<<6)
	rcall sound_evacuate

	;Toggle led
	in temp0,PORTD
	ldi temp1,0b0000_1000
	mov temp2,loop
	shift3:
		lsl temp1
		dec temp2
	brge shift3
	or temp0,temp1
	out PORTD,temp0

	;Reset switch pressed
	sbrc buttons,RESET_SWITCH
	rjmp _set_state_normal_reset
		
	;Isolate switch pressed
	sbrc buttons,ISOLATE_SWITCH
	rjmp _set_state_isolate

	ret

_set_state_isolate:
	;TODO Display which sectors are isolated
	ldi temp0,LOW(NORMAL_MESSAGE*2)
	ldi temp1,HIGH(NORMAL_MESSAGE*2)
	rcall lcd_print
	rcall sound_clear
	;Fall through
_state_isolate:
	cbr state_write,0b1100_0000
	ori state_write,(ISOLATE<<6)

	;Reset switch pressed
	sbrs buttons,RESET_SWITCH
	rjmp _state_isolate_jump1

	;Set state to normal if there isn't already an alert or evac happening
	mov temp0,alert_on
	or temp0,evac_on
	cpi temp0,0
	brne _state_isolate_jump1

	clr state
	;Lazy way of clearing the outputs
	cbi PORTD,4
	cbi PORTD,5
	cbi PORTD,6
	cbi PORTD,7
	rjmp _set_state_normal

	_state_isolate_jump1:

	ret