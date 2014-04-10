#include <p18f4620.inc>
#include <delays32.inc>
		list P=18F4620, F=INHX32, C=160, N=80, ST=OFF, MM=OFF, R=DEC
;Take 3 -5 samples and then subtract to make sure they're flickering
;;;;;;Configuration Bits;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		CONFIG OSC=INTIO67
        CONFIG FCMEN=OFF, IESO=OFF
		CONFIG PWRT = OFF, BOREN = SBORDIS, BORV = 3
		CONFIG WDT = OFF, WDTPS = 32768
		CONFIG MCLRE = ON, LPT1OSC = OFF, PBADEN = OFF, CCP2MX = PORTC
		CONFIG STVREN = ON, LVP = OFF, XINST = OFF
		CONFIG DEBUG = OFF
		CONFIG CP0 = OFF, CP1 = OFF, CP2 = OFF, CP3 = OFF
		CONFIG CPB = OFF, CPD = OFF
		CONFIG WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF
		CONFIG WRTB = OFF, WRTC = OFF, WRTD = OFF
		CONFIG EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
		CONFIG EBTRB = OFF
;******************************************************************************;
;********KEEP IN MIND THE ADRESH HOLDS THE 8 HIGHEST BITS AND ADRESL THE LAST 2;
;I GUESS YOU CAN ASSUME the least significant digits would range from 00-11, assume any
;******************************************************************************;
cblock
    AN0h,AN0l
    AN1h,AN1l
    AN2h,AN2l
    AN3h,AN3l
    AN4h,AN4l
    AN5h,AN5l
    AN6h,AN6l
    AN7h,AN7l
    AN8h,AN8l
endc

;*******************************VECTORS*****************************************
			org		0x0000
			goto	Mainline
			org		0x08				;high priority ISR
			retfie
			org		0x18				;low priority ISR
			retfie

;**************************************************************
; Initialize Part
;
; ADCON1 - AN0/RA0 as the only analog input
; ADCON2 - Acquisition time = 8 TAD    --> 8* 1us
;		 - Conversion clock = Fosc/64 ---> 2 us
; TRISB - PORTB as output
;**************************************************************

Mainline
		movlw	B'01110000'	;set internal oscillator frequency
		movwf	OSCCON		;to 8 MHz
		bsf		OSCTUNE, 6	;turn on PLL to enable 32MHz clock frequency
		bra		INIT

INIT	bcf		INTCON,GIE	;disable global interrupt
		
;        movlw	B'00000110'	;configure ADCON1  ---> this makes AN0-AN8 the only Analogue inputs, volatge ref. set to source
;		movwf	ADCON1
;
;		movlw	B'00100110'	;configure ADCON2   bit 7=0 Left justified      bits 5:3=AD acquisition time: 8*Tad= 100    bits 2:0= conversion clock set to Tosc 64=110
;		movwf	ADCON2

;Slower sampling
        movlw	B'0000101'	;configure ADCON1  ---> this makes AN0-AN9 the only Analogue inputs, volatge ref. set to source
		movwf	ADCON1
        movlw	B'00111110'	;configure ADCON2   bit 7=0 Left justified      bits 5:3=AD acquisition time: 20*Tad= 111    bits 2:0= conversion clock set to Tosc 64=110
		movwf	ADCON2

;        setf    TRISA
;        setf    TRISB
        setf    TRISE
		clrf   	TRISD		;configure PORTB as output Okay for now, but not needed later!
        
;        ;let LD relay on
;        bcf     TRISC,7
;        bsf     PORTC,7
        ;let IR relay on
        bcf     TRISC,5
        bsf     PORTC,5


bra		ADSTART


;***************************************************************
; MAIN PROGRAM
;***************************************************************
ADSTART
;        AN0
;        movlw   B'00000001' ;ADON=1 for AN0
;        movwf   ADCON0
;        rcall	AD_CONV	;call the A2D subroutine
;     	movf	ADRESH,WREG	;move the high 8-bits to W
;        movwf   AN0h
;        movf    ADRESL,WREG    ;move the low 8-bits to W
;        movwf   AN0l
;;debugging
;movff    AN0h,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
;call    delay5ms
;call    ADSTART
;;*******************************************************************************
;;        ;AN1
;        movlw   B'00010001' ;ADCON=1 for AN1
;        movwf   ADCON0
;        rcall	AD_CONV	;call the A2D subroutine
;     	movf	ADRESH,WREG	;move the high 8-bits to W
;        movwf   AN1h
;        movf    ADRESL,WREG    ;move the low 8-bits to W
;        movwf   AN1l
;;debugging
;movff    AN1h,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
; call   delay5ms
; call   ADSTART
;
;;*******************************************************************************
;        ;AN2
;        movlw   B'00001001' ;ADON=1 for AN2
;        movwf   ADCON0
;        rcall	AD_CONV	;call the A2D subroutine
;     	movf	ADRESH,WREG	;move the high 8-bits to W
;        movwf   AN2h
;        movf    ADRESL,WREG    ;move the low 8-bits to W
;        movwf   AN2l
;;debugging
;movff    AN2h,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
;;call    delay5ms
;call    ADSTART
;
;;;*******************************************************************************
;        ;AN3
;        movlw   B'00001101' ;ADON=1 for AN3
;        movwf   ADCON0
;        rcall	AD_CONV	;call the A2D subroutine
;     	movf	ADRESH,WREG	;move the high 8-bits to W
;        movwf   AN3h
;        movf    ADRESL,WREG    ;move the low 8-bits to W
;        movwf   AN3l
;;debugging
;movff    AN3h,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
;call    delay5ms
;goto    ADSTART

;;*******************************************************************************
        ;AN4
        movlw   B'00010001' ;ADCON=1 for AN1
        movwf   ADCON0
        rcall	AD_CONV	;call the A2D subroutine
     	movf	ADRESH,WREG	;move the high 8-bits to W
        movwf   AN4h
        movf    ADRESL,WREG    ;move the low 8-bits to W
        movwf   AN4l
;debugging
movff    AN4h,WREG ;into WREG
movwf	PORTD	;display the high 8-bit result to the LEDs
call    delay5ms
goto    ADSTART
;
;;*******************************************************************************
;        ;AN5
;        movlw   B'01010001' ;ADCON=1 for AN5
;        movwf   ADCON0
;        rcall	AD_CONV	;call the A2D subroutine
;     	movf	ADRESH,WREG	;move the high 8-bits to W
;        movwf   AN5h
;        movf    ADRESL,WREG    ;move the low 8-bits to W
;        movwf   AN5l
;;debugging
;movff   AN5h,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
;call    delay5ms
;call    ADSTART
;;
;;*******************************************************************************
;        ;AN6
;        movlw   B'01100001' ;ADCON=1 for AN6
;        movwf   ADCON0
;        rcall	AD_CONV	;call the A2D subroutine
;     	movf	ADRESH,WREG	;move the high 8-bits to W
;        movwf   AN6h
;        movf    ADRESL,WREG    ;move the low 8-bits to W
;        movwf   AN6l
;;debugging
;movff   AN6h,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
;call    ADSTART
;;
;;*******************************************************************************
;        ;AN7
;        movlw   B'01110001' ;ADCON=1 for AN1
;        movwf   ADCON0
;        rcall	AD_CONV	;call the A2D subroutine
;     	movf	ADRESH,WREG	;move the high 8-bits to W
;        movwf   AN7h
;        movf    ADRESL,WREG    ;move the low 8-bits to W
;        movwf   AN7l
;;debugging
;movff   AN7h,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
;
;;*******************************************************************************
;;        ;AN8
;        movlw   B'10000001' ;ADCON=1 for AN1
;        movwf   ADCON0
;        rcall	AD_CONV	;call the A2D subroutine
;     	movf	ADRESH,WREG	;move the high 8-bits to W
;        movwf   AN8h
;        movf    ADRESL,WREG    ;move the low 8-bits to W
;        movwf   AN8l
;;debugging
;movff   AN8h,WREG ;into WREG
;movwf	PORTD	;display the high 8-bit result to the LEDs
;
;
;    call    delay0.5s
;    call    ADSTART



;***************************************************************
; AD CONVERT ROUTINE:
; OUTPUT: NOTHING, ADRESH and ADRESL must be used after routine call
;***************************************************************
AD_CONV	
;        movlw	B'00000001'	;configure ADCON0       set ADON to 1 to turn on AD conversion, input from AN0
;     	movwf	ADCON0
        call    delay5ms
     	bsf		ADCON0,1	;start the conversion   set GO/DONE bit to 1 to start conversion

WAIT	btfsc	ADCON0,1	;wait until the conversion is completed by checking GO/DONE bit once it's 0
     	bra		WAIT		;poll the GO bit in ADCON0
;put after call to subroutine     	movf	ADRESH,W	;move the high 8-bit to W
     	;call delay1s
        return


end

