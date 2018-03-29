;
; constants.asm
;
; Created: 12/03/2018
; Author : James Ridey
;

.def temp0 = r16 ;Temporary/Param 0
.def temp1 = r17 ;Temporary/Param 1
.def temp2 = r18 ;Temporary/Param 2
.def temp3 = r19 ;Temporary/Param 3
.def loop = r20  ;Loop counter

.def state_read = r1;
.def state_write = r2;
.def buttons = r3;
.def buttons_read = r4;

.def sound_loop = r21
.def low_hertz = r22
.def high_hertz = r23
.def state = r24
.def alert_count = r25

; Delay amounts
.equ DELAY_1_SEC = (16000000/4); *0.8
.equ DELAY_10 =  DELAY_1_SEC/100   ; 10ms
.equ DELAY_5 =   DELAY_1_SEC/100/2 ; 5ms
.equ DELAY_1 =   DELAY_1_SEC/1000  ; 1ms
.equ DELAY_0P1 = DELAY_1_SEC/10000 ; 0.1ms

;State
.equ DEBOUNCE_MEMORY_LOCATION = 0x100
.equ BUILDINGS = 4
.equ EMERGENCY_SWITCH = BUILDINGS
.equ ISOLATE_SWITCH = BUILDINGS+1
.equ RESET_SWITCH = BUILDINGS+2

.equ NORMAL = 0
.equ ALERT = 1
.equ EVACUATE = 2
.equ ISOLATE = 3

; Sound
.equ SPEAKER_PORT = 1 ; PORTB, line 9 PWM
;Alert alarm sound
;TODO
;Evac alarm sound
.equ SOUND_LOOP_COUNT = 200
.equ SOUND_ALERT_HERTZ = 10000 ;This value is the top, f = cpu_f / (2*prescale*top) 
.equ SOUND_EVACUATE_HERTZ = 20000 ;This value is the top, f = cpu_f / (2*prescale*top) 

;LCD Display
.equ LCD_ADDRESS = 0x4E
NORMAL_MESSAGE:
.db "NORMAL: All good",0,0
ALERT_MESSAGE:
.db "ALERT: Sector ",0,0
EVACUATE_MESSAGE:
.db "EVACUATE! EVAC!",0
