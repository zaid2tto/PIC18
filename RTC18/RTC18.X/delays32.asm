#include <p18f4620.inc>
;****************************DELAYS FOR 32Mhz**********************************


code
global delay44us,delay5ms,delay0.5s,delay1s,delay3s,delay10s

;****************************delay44us*****************************************
cblock
	d1
	endc

delay44us
			;346 cycles
	movlw	0x73
	movwf	d1
delay44us_0
	decfsz	d1, f
	goto	delay44us_0

			;2 cycles
	nop
    nop

			;4 cycles (including call)
	return

;**************************delay5ms*********************************************
cblock
	dd1
	dd2
	endc

delay5ms
			;39993 cycles
	movlw	0x3E
	movwf	dd1
	movlw	0x20
	movwf	dd2
delay5ms_0
	decfsz	dd1, f
    	goto    lA
	decfsz	dd2, f
lA  	goto	delay5ms_0

			;3 cycles
	nop
    nop
	nop

			;4 cycles (including call)
	return
;******************delay0.5s****************************************************
cblock
	b1
	b2
	b3
	endc

delay0.5s
			;3999994 cycles
	movlw	0x23
	movwf	b1
	movlw	0xB9
	movwf	b2
	movlw	0x09
	movwf	b3
delay0.5s_0
	decfsz	b1, f
    	goto	llA
	decfsz	b2, f
llA 	goto	llB
	decfsz	b3, f
llB 	goto	delay0.5s_0

			;2 cycles
	nop
    nop

			;4 cycles (including call)
	return

;************************delay1s***********************************************
cblock
	bb1
	bb2
	bb3
	endc

delay1s
			;7999990 cycles
	movlw	0x47
	movwf	bb1
	movlw	0x71
	movwf	bb2
	movlw	0x12
	movwf	bb3
delay1s_0
	decfsz	bb1, f
        goto	kA
	decfsz	bb2, f
kA  	goto	kB
	decfsz	bb3, f
kB  	goto	delay1s_0

			;6 cycles
	nop
    nop
    nop
    nop
    nop
    nop
			;4 cycles (including call)
	return

;***************************delay3s*********************************************
cblock
	c1
	c2
	c3
	endc

delay3s
			;23999995 cycles
	movlw	0xDA
	movwf	c1
	movlw	0x51
	movwf	c2
	movlw	0x35
	movwf	c3
delay3s_0
	decfsz	c1, f
    	goto	kkA
	decfsz	c2, f
kkA 	goto	kkB
	decfsz	c3, f
kkB 	goto	delay3s_0

			;1 cycle
	nop

			;4 cycles (including call)
	return

;***************************delay10s*******************************************
cblock
	cc1
	cc2
	cc3
	endc

delay10s
			;79999995 cycles
	movlw	0xDA
	movwf	cc1
	movlw	0x63
	movwf	cc2
	movlw	0xAF
	movwf	cc3
delay10s_0
	decfsz	cc1, f
        goto	jA
	decfsz	cc2, f
jA  	goto	jB
	decfsz	cc3, f
jB  	goto	delay10s_0

			;1 cycle
	nop

			;4 cycles (including call)
	return

END