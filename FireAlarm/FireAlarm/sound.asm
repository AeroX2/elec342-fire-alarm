;
; sound.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

sound_init:
	sbi	DDRB,SPEAKER_PORT
	ret

sound_reset:
	ldi sound_loop,SOUND_LOOP_COUNT
	ldi low_hertz,LOW(SOUND_STARTING_HERTZ)
	ldi high_hertz,HIGH(SOUND_STARTING_HERTZ)

sound_evac:
	;Decrease until 0 and then reset
	dec sound_loop
	tst sound_loop
	breq sound_reset

	mov temp0,low_hertz
	mov temp1,high_hertz
	call pwm_8x_50

	subi low_hertz,60
	sbci high_hertz,0

	;Delay for 10 milliseconds
	ldi temp0,LOW(DELAY_10)
	ldi temp1,HIGH(DELAY_10)
	ldi temp2,0
	call delay

	ret
		
; Delay by the value of the registers in r0/r1/r2 and pass that to the Arduino internal timer
pwm_8x_50:

	sts OCR1BH,temp1
	sts OCR1BL,temp0

	;Set duty cycle to 50%
	lsr temp1
	ror temp0
	sts OCR1AH,temp1
	sts OCR1AL,temp0

	ldi temp0,(1<<COM1A0)|(1<<COM1B1)|(1<<WGM11)|(1<<WGM10);0b1010_0011 
	sts TCCR1A,temp0 ;Toggle OC1 pin and use Fast PWM with wave generation
	ldi temp0,(1<<WGM13)|(1<<WGM12)|(1<<CS11)
	sts TCCR1B,temp0 ;8x prescaling, starts the timer

	ret