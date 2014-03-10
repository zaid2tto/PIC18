#include <p18f4620.inc>
#include <delays32.inc>
#include <MainIntegrated1.inc>


code
global startIR

startIR


   ; bcf		INTCON,GIE	;disable global interrupt
;         movlw   b'00000110'
;         movwf   CMCON
         setf    TRISA       ;problem with AN3,4 dont recieve negative input!
;        setf    TRISE   ;AN5-7
         bsf     TRISB,2    ;this works!!
         bsf     TRISB,3
        ; bcf     PORTB,2
        ; bcf     PORTB,3

        movlw	B'00000101'	;configure ADCON1  ---> this makes AN0-AN9 the only Analogue inputs, volatge ref. set to source
		movwf	ADCON1

		movlw	B'00100110'	;configure ADCON2   bit 7=0 Left justified      bits 5:3=AD acquisition time: 8*Tad= 100    bits 2:0= conversion clock set to Tosc 64=110
		movwf	ADCON2

		;clrf   	TRISD		;configure PORTB as output Okay for now, but not needed later!
;bra		ADSTART


ADSTART
        ;AN1
        movlw   B'00000101' ;ADON=1 for AN1             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp;
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_1                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR1                                     ;*to change
        goto    next1                                    ;*to change
setPresent_1                                            ;*to change
        movlw   b'00000001'
        movwf   IR1                                     ;*to change
        goto    next1                                    ;*to change

next1                                                    ;*to change
        ;AN2
        movlw   B'00001001' ;ADON=1 for AN2             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_2                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR2                                     ;*to change
        goto    next2                                    ;*to change
setPresent_2                                            ;*to change
        movlw   b'00000001'
        movwf   IR2                                     ;*to change
        goto    next2                                    ;*to change

next2                                                    ;*to change
        ;AN3
        movlw   B'00001101' ;ADON=1 for AN3             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_3                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR3                                     ;*to change
        goto    next3                                    ;*to change
setPresent_3                                            ;*to change
        movlw   b'00000001'
        movwf   IR3                                     ;*to change
        goto    next3                                    ;*to change

next3
        ;AN4
        movlw   B'00010001' ;ADON=1 for AN4             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_4                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR4                                     ;*to change
        goto    next4                                    ;*to change
setPresent_4                                            ;*to change
        movlw   b'00000001'
        movwf   IR4                                     ;*to change
        goto    next4                                    ;*to change

next4
        ;AN5
        movlw   B'00010101' ;ADON=1 for AN5             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_5                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR5                                     ;*to change
        goto    next5                                    ;*to change
setPresent_5                                            ;*to change
        movlw   b'00000001'
        movwf   IR5                                     ;*to change
        goto    next5                                    ;*to change

next5
        ;AN6
        movlw   B'00011001' ;ADON=1 for AN6             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_6                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR6                                     ;*to change
        goto    next6                                    ;*to change
setPresent_6                                            ;*to change
        movlw   b'00000001'
        movwf   IR6                                     ;*to change
        goto    next6                                    ;*to change

next6
        ;AN7
        movlw   B'00011101' ;ADON=1 for AN7             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_7                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR7                                     ;*to change
        goto    next7                                    ;*to change
setPresent_7                                            ;*to change
        movlw   b'00000001'
        movwf   IR7                                     ;*to change
        goto    next7                                    ;*to change

next7
        ;AN8
        movlw   B'00100001' ;ADON=1 for AN8             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_8                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR8                                     ;*to change
        goto    next8                                    ;*to change
setPresent_8                                            ;*to change
        movlw   b'00000001'
        movwf   IR8                                     ;*to change
        goto    next8                                    ;*to change

next8
        ;AN9
        movlw   B'00100101' ;ADON=1 for AN9             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_9                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR9                                     ;*to change
        goto    next9                                    ;*to change
setPresent_9                                            ;*to change
        movlw   b'00000001'
        movwf   IR9                                     ;*to change
        goto    next9                                    ;*to change

next9
; movf    ADRESL,WREG    ;move the low 8-bits to W
       ; movwf   IR2
;debugging
;movff    IR1,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
;call    delay5ms
;;goto    ADSTART ;THIS WAS A HUGE PAIN!!!! before it was call!
;here goto here

return

AD_CONV
;        movlw	B'00000001'	;configure ADCON0       set ADON to 1 to turn on AD conversion, input from AN0
;     	movwf	ADCON0
     	bsf		ADCON0,1	;start the conversion   set GO/DONE bit to 1 to start conversion

WAIT	btfsc	ADCON0,1	;wait until the conversion is completed by checking GO/DONE bit once it's 0
     	bra		WAIT		;poll the GO bit in ADCON0
;put after call to subroutine     	movf	ADRESH,W	;move the high 8-bit to W
     	;call delay1s
        return



END


