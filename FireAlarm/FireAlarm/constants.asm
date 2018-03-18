;
; constants.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

; Port numbers
.equ SPEAKER_PORT = 0 ; PORTB, line 8

; Delay amounts
.equ DELAY_1_SEC = (16000000/4)*0.8
.equ DELAY_10 =  DELAY_1_SEC/100   ; 10ms
.equ DELAY_5 =   DELAY_1_SEC/100/2 ; 5ms
.equ DELAY_1 =   DELAY_1_SEC/1000  ; 1ms
.equ DELAY_0P1 = DELAY_1_SEC/10000 ; 0.1ms

;Fire alarm sound
.equ SOUND_LOOP = 200
.equ SOUND_STARTING_HERTZ = 20000 ;This value is the top, f = cpu_f / (2*prescale*top) 

;LCD Display
.equ LCD_ADDRESS = 0x27


.db "Hello World"
