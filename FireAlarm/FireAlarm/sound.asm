;
; sound.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

sound_reset:
	ldi r20,SOUND_LOOP
	ldi r21,LOW(SOUND_STARTING_HERTZ)
	ldi r22,HIGH(SOUND_STARTING_HERTZ)

sound_alarm:
	;Decrease until 0 and then reset
	dec r10
	tst r10
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

/*;Timer interrupt
.org 0x001E
	;Toggle the speaker port
	sbic PORTB,SPEAKER_PORT
	rjmp speaker_off
	sbi PORTB,SPEAKER_PORT
	reti

	speaker_off:
		cbi PORTB,SPEAKER_PORT
		reti*/