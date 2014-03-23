#include <p18f4620.inc>
#include <delays32.inc>
		list P=18F4620, F=INHX32, C=160, N=80, ST=OFF, MM=OFF, R=DEC
;SUCCESS MOTOR WORKS! 
;;;;;;Configuration Bits;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		CONFIG OSC=INTIO67;OSC=HS
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

;*****************ORG*******************
            org		0x0000
			goto	Mainline
			org		0x08				;high priority ISR
			retfie
			org		0x18				;low priority ISR
			retfie
;**************CODE************************

Mainline
    movlw		B'01110000' ;set to 8Mhz
    movwf		OSCCON
	bsf         OSCTUNE, 6  ;activate PLL multiplier to boost to 32Mhz
    
    clrf      INTCON         ; No interrupts

    setf      TRISB		     ; All port B is input
    clrf      TRISD

    clrf      PORTB
    clrf      PORTD

; D0 right D1 left


CheckA
         bcf        PORTD,1     ;turn motor left off
         bcf        PORTD,0     ;turn motor right off
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for B key input: Summary
         sublw      b'0011'     ;subtract 3 from W: corresponds to letter A on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter C is pressed indeed: previous operation is success
         goto       CheckC        ;otherwise keep checking ******CHANGE
         ;now if B is pressed
         bsf        PORTD,0 ;pulse motor right
         clrf       PORTB
         goto       CheckA

CheckC
         bcf        PORTD,0 ;turn motor right off
         bcf        PORTD,1
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for C key input: Summary
         sublw      b'1011'     ;subtract 3 from W: corresponds to letter C on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter C is pressed indeed: previous operation is success
         goto       CheckA      ;CheckA
         ;now if C is pressed
         bsf        PORTD,1 ;turn motor left on
         clrf       PORTB
         goto       CheckC



END