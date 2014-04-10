#include <p18f4620.inc>
;these delays are obtained for a 32MHz clock source from
;http://www.piclist.com/techref/piclist/codegen/delay.htm
;
;****************************DELAYS FOR 32Mhz**********************************


code
global delay44us,delay5ms,delay25ms, delay50ms, delay100ms,delay0.5s,delay1s,delay3s,delay10s

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
;****************************delay25ms*****************************************
cblock
	w6
	w7
	endc

delay25ms
			;199998 cycles
	movlw	0x3F
	movwf	w6
	movlw	0x9D
	movwf	w7
delay0.025_0
	decfsz	w6, f
	goto	ff1
	decfsz	w7, f
ff1	goto	delay0.025_0

			;2 cycles
	nop
    nop

return
;****************************delay50ms*****************************************
cblock
	w1
	w2
	w3
	endc

delay50ms
			;399999 cycles
	movlw	0x36
	movwf	w1
	movlw	0xE0
	movwf	w2
	movlw	0x01
	movwf	w3
delay0.05_0
	decfsz	w1, f
	goto	f1
	decfsz	w2, f
f1	goto	f2
	decfsz	w3, f
f2	goto	delay0.05_0

			;1 cycle
	nop
return
;*************************delay100ms*******************************************
delay100ms
cblock
	u1
	u2
	u3
	endc

			;800000 cycles
	movlw	0x6D
	movwf	u1
	movlw	0xBF
	movwf	u2
	movlw	0x02
	movwf	u3
delay100ms_0
	decfsz	u1, f
	goto	here1
	decfsz	u2, f
here1	goto    here2
	decfsz	u3, f
here2	goto	delay100ms_0

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


