;
; constants.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

.def temp0 = r16
.def temp1 = r17
.def temp2 = r18
.def temp3 = r19

.def sound_loop = r20
.def low_hertz = r21
.def high_hertz = r22

.def debounce_0 = r23
.def debounce_1 = r24
.def debounce_2 = r25
.def debounce_3 = r26

; Port numbers
.equ SPEAKER_PORT = 1 ; PORTB, line 9 PWM

; Delay amounts
.equ DELAY_1_SEC = (16000000/4)*0.8
.equ DELAY_10 =  DELAY_1_SEC/100   ; 10ms
.equ DELAY_5 =   DELAY_1_SEC/100/2 ; 5ms
.equ DELAY_1 =   DELAY_1_SEC/1000  ; 1ms
.equ DELAY_0P1 = DELAY_1_SEC/10000 ; 0.1ms

;Evac alarm sound
.equ SOUND_LOOP_COUNT = 200
.equ SOUND_STARTING_HERTZ = 20000 ;This value is the top, f = cpu_f / (2*prescale*top) 

;LCD Display
.equ LCD_ADDRESS = 0x27


.db "Hello World",0x00
