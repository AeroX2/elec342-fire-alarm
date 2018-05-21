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

;Temporary state.asm variables
.def state = r28
.def state_read = r1
.def state_write = r29 ;TODO Should figure out a better temporary variable
.def buttons = r3
.def buttons_read = r4

;.def normal_on = r5
.def alert_on = r6
.def evac_on = r7
;.def isolate_on = r8

.def blink_alert_l = r21
.def blink_alert_h = r22
.def blink_evac_l = r23
.def blink_evac_h = r24

.def last_alert_time_l = r30 ;TODO Should figure out a better temporary variable
.def last_alert_time_h = r31 ;TODO Should figure out a better temporary variable

;sound.asm variables
.def sound_loop = r8
.def low_hertz = r9
.def high_hertz = r10
.def slight_delay = r11

; Delay amounts
.equ DELAY_1_SEC = (16000000/4); *0.8
.equ DELAY_10 =  DELAY_1_SEC/100   ; 10ms
.equ DELAY_5 =   DELAY_1_SEC/100/2 ; 5ms
.equ DELAY_1 =   DELAY_1_SEC/1000  ; 1ms
.equ DELAY_0P1 = DELAY_1_SEC/10000 ; 0.1ms

;State
.equ DEBOUNCE_MEMORY_LOCATION = 0x100
.equ BUILDINGS = 4

.equ EMERGENCY_SWITCH = 5 ;A3
.equ ISOLATE_SWITCH = 6 ;A2
.equ RESET_SWITCH = 7 ;A1
.equ EMERGENCY_SWITCH_MCP = 8 ;MCP

.equ NORMAL = 0
.equ ALERT = 1
.equ EVACUATE = 2
.equ ISOLATE = 3

.equ ALERT_TIMEOUT = 65535 ; 2s~3s, not exact due to implementation
.equ ALERT_BLINK = 20000 
.equ EVAC_BLINK = 10000 ;50 

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

;SPI
.equ SLAVE_SELECT = 2 ; PORTB, line 10