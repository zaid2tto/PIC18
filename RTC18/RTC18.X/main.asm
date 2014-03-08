#include <p18f4620.inc>
#include <lcd18.inc>
#include <rtc_macros.inc>
#include <delays32.inc>
		list P=18F4620, F=INHX32, C=160, N=80, ST=OFF, MM=OFF, R=DEC

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

;;;;;;Equates;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;*******************************************************************
;Constant Defines
;*******************************************************************
#define   RS        LATD,2        ; for v 1.0 used PORTD.3
#define   E         LATD,3        ; for v 1.0 used PORTD.2

temp_lcd  EQU       0x20           ; buffer for Instruction
dat       EQU       0x21           ; buffer for data


delay1	  EQU		0x25
delay2	  EQU		0x26
delay3	  EQU		0x27

LCDSettings macro
          movlw     B'00101000'    ; 4 bits, 2 lines,5X7 dots seems to work best instead of the above setting
          call      WR_INS

          movlw     B'00001100'    ; display on/off
          call      WR_INS
         ; movlw     B'00000110'    ; Entry mode
         ; call      WR_INS
          movlw     B'00000001'    ; Clear ram
          call      WR_INS
endm
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
         clrf	   TRISB		  ; All port B is output
         clrf      TRISC          ; All port C is output
         clrf      TRISD          ; All port D is output

         ;Set SDA and SCL to high-Z first as required for I2C
		 bsf	   TRISC,4
		 bsf	   TRISC,3

         
         clrf      PORTA
         clrf      PORTB
         clrf      PORTC
         clrf      PORTD


		 ;Set up I2C for communication
		 call 	   i2c_common_setup
		 ;rtc_resetAll                   ;comment afterwards

		 ;Used to set up time in RTC, load to the PIC when RTC is used for the first time
		; call	   set_rtc_time         ;comment afterwards

         call      InitLCD    ;*NOTE: This InitLCD is different than the one in main project code: the settings are different; Not anymore!
         LCDSettings

show_RTC
		;clear LCD screen
		movlw	b'00000001'
		call	WR_INS

		;Get year
		movlw	"2"				;First line shows 20**/**/**
		call	WR_DATA
		movlw	"0"
		call	WR_DATA
		rtc_read	0x06		;Read Address 0x06 from DS1307---year
		movf	tens_digit,WREG ;GOTTTA USE tens_digit, ones_digit
		call	WR_DATA
		movf	ones_digit,WREG
		call	WR_DATA

		movlw	"/"
		call	WR_DATA

		;Get month
		rtc_read	0x05		;Read Address 0x05 from DS1307---month
		movf	tens_digit,WREG
		call	WR_DATA
		movf	ones_digit,WREG
		call	WR_DATA

		movlw	"/"
		call	WR_DATA

		;Get day
		rtc_read	0x04		;Read Address 0x04 from DS1307---day
		movf	tens_digit,WREG
		call	WR_DATA
		movf	ones_digit,WREG
		call	WR_DATA

		movlw	B'11000000'		;Next line displays (hour):(min):(sec) **:**:**
		call	WR_INS

		;Get hour
		rtc_read	0x02		;Read Address 0x02 from DS1307---hour
		movf	tens_digit,WREG
		call	WR_DATA
		movf	ones_digit,WREG
		call	WR_DATA
		movlw			":"
		call	WR_DATA

		;Get minute
		rtc_read	0x01		;Read Address 0x01 from DS1307---min
		movf	tens_digit,WREG
		call	WR_DATA
		movf	ones_digit,WREG
		call	WR_DATA
		movlw			":"
		call	WR_DATA

		;Get seconds
		rtc_read	0x00		;Read Address 0x00 from DS1307---seconds
		movf	tens_digit,WREG
		call	WR_DATA
		movf	ones_digit,WREG
		call	WR_DATA

		call	delay1s			;Delay for exactly one seconds and read DS1307 again
		goto	show_RTC

;***************************************
; Setup RTC with time defined by user
;***************************************
set_rtc_time

		rtc_resetAll	;reset rtc

		rtc_set	0x00,	B'10000000'

		;set time
		rtc_set	0x06,	B'00010100'		; Year 2014
		rtc_set	0x05,	B'00000010'		; Month
		rtc_set	0x04,	B'00100110'		; Date
		rtc_set	0x03,	B'00000011'		; Day
		rtc_set	0x02,	B'00000000'		; Hours  ;;;;am/pm 3rd high  00010100
		rtc_set	0x01,	B'00010000'		; Minutes
		rtc_set	0x00,	B'00000000'		; Seconds
		return

;**********************VARIOUS SUBROUTINES**************************************

; Write command to LCD
; Input  : W
; output : -
;****************************************
WR_INS

		bcf		RS	  				; clear Register Status bit
		movwf	temp_lcd			; store instruction
		andlw	0xF0			  	; mask 4 bits MSB
		movwf	LATD			  	; send 4 bits MSB

		bsf		E					; pulse enable high
		swapf	temp_lcd, WREG		  	; swap nibbles
		andlw	0xF0			  	; mask 4 bits LSB
		bcf		E
		movwf	LATD			  	; send 4 bits LSB
		bsf		E					; pulse enable high
		nop
		bcf		E
		call	delay5ms

		return


;***************************************
; Write data to LCD
; Input  : W
; Output : -
;***************************************
WR_DATA

		bcf		RS					; clear Register Status bit
        movwf   dat				; store character
        movf	dat, WREG
		andlw   0xF0			  	; mask 4 bits MSB
        addlw   4			  	; set Register Status
        movwf   PORTD			  	; send 4 bits MSB

		bsf		E					; pulse enable high
        swapf   dat, WREG		  	; swap nibbles
        andlw   0xF0			  	; mask 4 bits LSB
		bcf		E
        addlw   4				; set Register Status
        movwf   PORTD			  	; send 4 bits LSB
		bsf		E					; pulse enable high
		nop
		bcf		E

		call	delay44us

        return

;;;;;;;;;;;;;;;;LCD FUNCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Switch_Lines
		movlw	B'11000000'
		call	WR_INS
		return





end