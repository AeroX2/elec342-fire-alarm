;
; sound.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

sound_clear:
	push temp0

	clr temp0
	sts TCCR1A,temp0
	sts TCCR1B,temp0

	pop temp0
	ret

sound_alert:
	push temp0
	push temp1

	ldi temp0,LOW(SOUND_ALERT_HERTZ)
	ldi temp1,HIGH(SOUND_ALERT_HERTZ)
	rcall _pwm_8x_50

	pop temp1
	pop temp0
	ret

sound_evacuate:
	push temp0
	push temp1
	push temp2
	push temp3
	
	mov temp2,sound_loop
	mov temp3,slight_delay

	inc temp3
	brvc end_3

	mov temp0,low_hertz
	mov temp1,high_hertz
	rcall _pwm_8x_50

	subi temp0,60
	sbci temp1,0

	;Increase until >=SOUND_LOOP_COUNT and then reset
	inc temp2
	cpi temp2,SOUND_LOOP_COUNT
	brlo end_1

	;Reset sound
	clr temp2
	ldi temp0,LOW(SOUND_EVACUATE_HERTZ)
	ldi temp1,HIGH(SOUND_EVACUATE_HERTZ)
	
	end_1:
	
	mov low_hertz,temp0
	mov high_hertz,temp1

	end_3:

	mov sound_loop,temp2
	mov slight_delay,temp3

	pop temp3
	pop temp2
	pop temp1
	pop temp0
	ret
		
; Delay by the value of the registers in r0/r1/r2 and pass that to the Arduino internal timer
_pwm_8x_50:
	push temp0
	push temp1

	sts OCR1BH,temp1
	sts OCR1BL,temp0

	;Set duty cycle to 50%
	lsr temp1
	ror temp0
	sts OCR1AH,temp1
	sts OCR1AL,temp0

	ldi temp0,(1<<COM1A0)|(1<<WGM11)|(1<<WGM10);0b1010_0011 
	sts TCCR1A,temp0 ;Toggle OC1 pin and use Fast PWM with wave generation
	ldi temp0,(1<<WGM13)|(1<<WGM12)|(1<<CS11)
	sts TCCR1B,temp0 ;8x prescaling, starts the timer

	pop temp1
	pop temp0
	ret