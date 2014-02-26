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

    clrf      TRISA          ; All port A is output
    clrf      TRISB		     ; All port B is output
    clrf      TRISC          ; All port C is output

    ;Different ways of making RD1 an output
    ;clrf      TRISD          ; All port D is output
    bcf     TRISD,1         ;This works too
   ; movlw   B'11111101'     ;make pin1 out
   ; movwf   TRISD

    ;clears any residual data
         clrf      PORTA
         clrf      PORTB
         clrf      PORTC
         clrf      PORTD

loop
    btg     PORTD,1
    call    delay3s
    goto    loop


END