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

INIT    ;Test if RB1 is high or low then based on that display results on portD for RD1
        setf    TRISB ;all port B is inputs
        movlw   B'11111101' ;RD1 is output
        movwf   TRISD
        clrf    PORTB ;clear port B
       ; clrf    PORTD
        ;check for PIN 1 RB1
test
        clrf        PORTD ;IMPORTANT TO GET RID OF BUGGINESS! KEEP THIS LINE, clears RD1
        btfss		PORTB,2   ;If RB2 is high--> do next
        goto		test
        ;RB1 is high--> turn RD1 on
        btg         PORTD,RD1
        call        test




END


