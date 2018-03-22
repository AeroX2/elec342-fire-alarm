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
	ldi r20,SOUND_LOOP
	ldi r21,LOW(SOUND_STARTING_HERTZ)
	ldi r22,HIGH(SOUND_STARTING_HERTZ)

sound_alarm:
	;Decrease until 0 and then reset
	dec r20
	tst r20
	breq sound_reset

	mov r16,r21
	mov r17,r22
	call pwm_8x_50

	subi r21,60
	sbci r22,0

	;Delay for 10 milliseconds
	ldi r16,LOW(DELAY_10)
	ldi r17,HIGH(DELAY_10)
	ldi r18,0
	call delay

	ret
		
; Delay by the value of the registers in r0/r1/r2 and pass that to the Arduino internal timer
pwm_8x_50:

	sts OCR1BH,r17
	sts OCR1BL,r16

	;Set duty cycle to 50%
	lsr r17
	ror r16
	sts OCR1AH,r17
	sts OCR1AL,r16

	ldi r16,(1<<COM1A0)|(1<<COM1B1)|(1<<WGM11)|(1<<WGM10);0b1010_0011 
	sts TCCR1A,r16 ;Toggle OC1 pin and use Fast PWM with wave generation
	ldi r16,(1<<WGM13)|(1<<WGM12)|(1<<CS11)
	sts TCCR1B,r16 ;8x prescaling, starts the timer

	ret