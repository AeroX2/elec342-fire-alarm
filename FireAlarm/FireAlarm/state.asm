;
; state.asm
;
; Created: 24/03/2018
; Author : James Ridey
;

state_init:
	push temp0

	; Enable interupts on PCMSK2
	ldi temp0,0b0000_0111
	sts PCICR,temp0
	
	; Enable interupts on pins A3 to A5
	ldi temp0,0b0000_1110
	sts PCMSK1,temp0

	; Enable interupts on pins 0 to 4
	ldi temp0,0b0000_1111
	sts PCMSK2,temp0

	ldi temp0,0b0000_0111
	sts PCIFR,temp0

	;Enable global interupts
	sei

	;Enable sleep mode
	ldi temp0,0b0001
	out SMCR,temp0

	pop temp0
	ret

state_interrupt:
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

	cpi temp1,0
	brne no_sleep
	cpi state,0
	brne no_sleep
	sleep

	no_sleep:

	;Fall Through
_state_machine_update:	
	clr state_write
	mov state_read,state
	mov buttons,temp0
	mov buttons_read,temp0

	;Read MCP pin for the emergency pin
	rcall mcp_read_pins
	lsr temp0
	lsr temp0
	or buttons,temp0
	or buttons_read,temp0

	;Check if any state is in alert
	mov temp0,state
	ldi temp1,ALERT
	rcall _state_scan
	mov alert_on,temp0

	;Check if any state is in evacuate
	mov temp0,state
	ldi temp1,EVACUATE
	rcall _state_scan
	mov evac_on,temp0

	;Loop 4 times for each sensor
	clr loop
	_machine_loop:
		rcall _state_machine_jump_table

		inc loop
		cpi loop,BUILDINGS
	brlt _machine_loop

	cp state,state_write
	breq state_changed

	;Store the final state
	mov state,state_write

	cli
	EEPROM_write:
	sbic EECR,EEPE
	rjmp EEPROM_write

	ldi r16,0x10
	out EEARH,r16
	out EEARL,r16

	out EEDR,state
	sbi EECR,EEMPE
	sbi EECR,EEPE
	sei

	state_changed:

	;Write led state to MCP
	ldi temp0,0x00
	in temp1,PORTD
	lsr temp1
	lsr temp1
	lsr temp1
	lsr temp1
	rcall mcp_write_pins

	;If blink_count <= 0, reset to initial
	ldi temp0,0
	cp temp0,blink_alert_l
	cpc temp0,blink_alert_h
	brne _skip_reset_alert
	
	ldi blink_alert_l,LOW(ALERT_BLINK)
	ldi blink_alert_h,HIGH(ALERT_BLINK)
	
	_skip_reset_alert:

	;If blink_count <= 0, reset to initial
	cp temp0,blink_evac_l
	cpc temp0,blink_evac_h
	brne _skip_reset_evac
	
	ldi blink_evac_l,LOW(EVAC_BLINK)
	ldi blink_evac_h,HIGH(EVAC_BLINK)
	
	_skip_reset_evac:

	;Subtract the blink count
	subi blink_alert_l,1
	sbci blink_alert_h,0

	;Subtract the blink count
	subi blink_evac_l,1
	sbci blink_evac_h,0

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
_set_state_normal:
	ldi temp0,LOW(NORMAL_MESSAGE*2)
	ldi temp1,HIGH(NORMAL_MESSAGE*2)
	rcall lcd_print
	rcall sound_clear

	mov temp0,loop
	rcall _turn_off_led

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
	breq _set_state_alert_jump2

	ldi last_alert_time_l,LOW(ALERT_TIMEOUT)
	ldi last_alert_time_h,HIGH(ALERT_TIMEOUT)

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
	
/*	; TODO Check why I need a _state_scan in here
	mov temp0,state_write
	ldi temp1,ALERT
	rcall _state_scan
	mov temp2,temp0
	mov temp0,state_write
	ldi temp1,EVACUATE
	rcall _state_scan
	
	;There is another alert/evac happening
	mov temp0,alert_on
	or temp0,evac_on
	cpi temp0,1
	breq _set_state_evacuate*/

	;TODO QUICK FIX
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
	;rcall sound_alert

	ldi temp0,LOW(ALERT_BLINK/2)
	ldi temp1,HIGH(ALERT_BLINK/2)
	cp temp0,blink_alert_l
	cpc temp1,blink_alert_h
	brlo _led_alert_on

	rcall sound_clear
	mov temp0,loop
	rcall _turn_off_led
	rjmp _led_alert_end

	_led_alert_on:
	rcall sound_alert

	mov temp0,loop
	rcall _turn_on_led
	
	_led_alert_end:
		
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
	brne _state_alert_jump1
	rjmp _set_state_evacuate

	_state_alert_jump1:

	ret

_set_state_evacuate:
	ldi temp0,LOW(EVACUATE_MESSAGE*2)
	ldi temp1,HIGH(EVACUATE_MESSAGE*2)
	rcall lcd_print
	;Fall through
_state_evacuate:
	ldi temp0,LOW(EVAC_BLINK/2)
	ldi temp1,HIGH(EVAC_BLINK/2)
	cp temp0,blink_evac_l
	cpc temp1,blink_evac_h
	brlo _led_alert_on_2

	mov temp0,loop
	rcall _turn_off_led
	rjmp _led_alert_end_2

	_led_alert_on_2:
	mov temp0,loop
	rcall _turn_on_led
	
	_led_alert_end_2:

	;TODO Its not a BUG its a feature
	;Sound gets faster depending on how many sensors are triggered
	cbr state_write,0b1100_0000
	ori state_write,(EVACUATE<<6)
	rcall sound_evacuate
	
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
	
	mov temp0,loop
	rcall _turn_on_led
	
	;Fall through
_state_isolate:
	;If everything is in evac mode, don't enable isolate
	cpi state,0b1111_1111
	breq _state_isolate_jump2

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

	_state_isolate_jump2:
	mov temp0,loop
	rcall _turn_off_led
	rjmp _set_state_normal

	_state_isolate_jump1:

	ret
	
_turn_on_led:	
	ldi temp1,0b0000_1000
	in temp2,PORTD
	_turn_on_led_jump1:
		lsl temp1
		dec temp0
	brge _turn_on_led_jump1
	or temp2,temp1
	out PORTD,temp2
	
	ret
	
_turn_off_led:	
	ldi temp1,0b1111_0111
	in temp2,PORTD
	_turn_off_led_jump1:
		lsl temp1
		ori temp1,1
		dec temp0
	brge _turn_off_led_jump1
	and temp2,temp1
	out PORTD,temp2
	
	ret