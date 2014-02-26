#include <p18f4620.inc>
;****************************DELAYS FOR 10Mhz**********************************
delay1	  EQU		0x25
delay2	  EQU		0x26
delay3	  EQU		0x27

code
;this is deactivated cuz Im using 32Mhz now
;global delay44us,delay5ms,delay0.5s,delay1s,delay3s,delay10s


;;;;;;;;;;;;;;;;10 second delay, made possile by replacing the goto $+2 with actual labels
cblock
	dd1
	dd2
	dd3
endc

delay10s
			;24999994 cycles
	movlw	0xE3
	movwf	dd1
	movlw	0x7F
	movwf	dd2
	movlw	0x37
	movwf	dd3
delay10s_0
	decfsz	dd1, f
	goto	delay_01
	decfsz	dd2, f
delay_01    goto    delay_02
	decfsz	dd3, f
delay_02	goto	delay10s_0

	goto	delay_03
delay_03	goto	delay_04
delay_04	goto	delay_05
delay_05    return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;delay1s;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cblock
	s1
	s2
	s3
	endc

delay1s
			;2499992 cycles
	movlw	0x15
	movwf	s1
	movlw	0x74
	movwf	s2
	movlw	0x06
	movwf	s3
delay1s_0
	decfsz	s1, f
	goto	s1_01       ;$+2
	decfsz	s2, f
s1_01       goto	s1_02
	decfsz	s3, f
s1_02   	goto	delay1s_0

			;4 cycles
	nop
    nop
    nop
    nop

			;4 cycles (including call)
	return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;delay0.5s;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cblock
	h1
	h2
	h3
	endc

delay0.5s
			;1249995 cycles
	movlw	0x8A
	movwf	h1
	movlw	0xBA
	movwf	h2
	movlw	0x03
	movwf	h3
delay0.5s_0
	decfsz	h1, f
	goto	hs_01
	decfsz	h2, f
hs_01	goto	hs_02
	decfsz	h3, f
hs_02	goto	delay0.5s_0

			;1 cycle
	nop

			;4 cycles (including call)
	return
;**********************delay3s*************************************************
cblock
	th1
	th2
	th3
	endc

delay3s
			;7499994 cycles
	movlw	0x43
	movwf	th1
	movlw	0x5A
	movwf	th2
	movlw	0x11
	movwf	th3
delay3s_0
	decfsz	th1, f
	goto	th_01
	decfsz	th2, f
th_01	goto	th_02
	decfsz	th3, f
th_02	goto	delay3s_0

			;2 cycles
	nop
    nop

			;4 cycles (including call)
	return
;******************************************************************************
; Delay44us (): wait exactly  110 cycles (44 us)
; <www.piclist.org>

delay44us
		movlw	0x23
		movwf	delay1, 0

Delay44usLoop

		decfsz	delay1, f
		goto	Delay44usLoop
		return

delay5ms
		movlw	0xC2
		movwf	delay1,0
		movlw	0x0A
		movwf	delay2,0

Delay5msLoop
		decfsz	delay1, f
		goto	d2
		decfsz	delay2, f
d2		goto	Delay5msLoop

return


END


