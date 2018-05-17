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
.def state_read = r1
.def state_write = r28 ;TODO Should figure out a better temporary variable
.def buttons = r3
.def buttons_read = r4
;.def normal_on = r5
.def alert_on = r6
.def evac_on = r7
;.def isolate_on = r8
.def last_alert_time_l = r29 ;TODO Should figure out a better temporary variable
.def last_alert_time_h = r30 ;TODO Should figure out a better temporary variable
.def last_alert_time_h2 = r31 ;TODO Should figure out a better temporary variable

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

.equ EMERGENCY_SWITCH = 4 ;A3
.equ ISOLATE_SWITCH = 5 ;A2
.equ RESET_SWITCH = 6 ;A1
.equ EMERGENCY_SWITCH_MCP = 7 ;MCP

.equ NORMAL = 0
.equ ALERT = 1
.equ EVACUATE = 2
.equ ISOLATE = 3

.equ ALERT_TIMEOUT = 400000 ; 15~17s, not exact due to implementation

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