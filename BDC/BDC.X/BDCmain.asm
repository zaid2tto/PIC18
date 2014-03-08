#include <p18f4620.inc>
#include <lcd18.inc>
; no longer 10Mhz #include <delays.inc>
#include <delays32.inc>

		list P=18F4620, F=INHX32, C=160, N=80, ST=OFF, MM=OFF, R=DEC

;;;;;;Configuration Bits;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		CONFIG OSC=INTIO67;OSC=HS INTERNAL OSCILLATOR!
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

;moved to the delays.asm
;delay1	  EQU		0x25
;delay2	  EQU		0x26
;delay3	  EQU		0x27







;******************************MACROS*******************************************
load_table macro Table
          movlw		upper Table
		  movwf		TBLPTRU
		  movlw		high Table
		  movwf		TBLPTRH
		  movlw		low Table
		  movwf		TBLPTRL
		  tblrd*
		  movf		TABLAT, W
          local     Again    ;Must make it local because each macro call will define Again an extra time
Again:
          call      WR_DATA
		  tblrd+*
		  movf		TABLAT, W
		  bnz		Again

endm

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

;*******************************VECTORS*****************************************
			org		0x0000
			goto	Mainline
			org		0x08				;high priority ISR
			retfie
			org		0x18				;low priority ISR
			retfie

;*******************************TABLES******************************************
Greeting
		db      "Greetings!", 0

Testing_Prompt      ;needs shifting
        db      "To Test Press A",0

Testing_Msg
        db      "Testing...",0
Stage1_Msg
        db      "Stage 1 Complete",0
Stage2_Msg
        db      "Stage 2 Complete",0
Time_Msg
        db      "Time:hh:mm",0
Results_1
        db      "Pass:",0
Results_2
        db      "Fail:",0
Test_Again
        db      "Test Again? Press *",0

SummaryM1_a
        db      "Press candle# to",0
SummaryM1_b
        db      "display details",0
SummaryM2_a
        db      "Press B: Time",0
SummaryM2_b
        db      "Press C: Summary",0

TimeSummary
        db      "Tot.Time:",0




;*****************************MAIN CODE*****************************************
Mainline

;;;;;;;;;;;;;;;;Starting LCD and Providing initial prompt;;;;;;;;;;;;;;;;;;;;
	movlw		B'01110000' ;set to 8Mhz
    movwf		OSCCON
	bsf         OSCTUNE, 6  ;activate PLL multiplier to boost to 32Mhz

		  clrf		TRISA
		  clrf		TRISB
		  clrf		TRISC
		  clrf		TRISD
         ;*****CLEARING IS IMPORTANT SO is calling InitLCD
         clrf      PORTA
         clrf      PORTB
         clrf      PORTC
         clrf      PORTD

		  call      delay5ms		;wait for LCD to start up
          call      delay5ms

          call      InitLCD
          LCDSettings
;;;;;;;;;;Display first prompt
          load_table  Greeting
          call      Switch_Lines
          load_table  Testing_Prompt

;;;;;;;;;;;;;;;;;Get Input from Keypad;;;;;;;;;;;;;;;


         clrf      INTCON         ; No interrupts
        ; clrf      TRISA          ; All port A is output

         movlw     b'11110010'    ; Set required keypad inputs
         movwf     TRISB

test     btfss		PORTB,1   ;Wait until data is available from the keypad
         goto		test

         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F

;test for A key input
         sublw      b'0011'     ;subtract 3 from W: corresponds to A letter on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter A is pressed indeed: previous operation is success
         goto       test        ;otherwise keep checking
         ;now if A is pressed, we want to clear screen and display something else

         call       ClrLCD
         load_table Testing_Msg
         call       delay3s

;         call       ClrLCD
;         load_table Stage1_Msg
;
;         call       delay3s
;
;         call       ClrLCD
;         load_table Testing_Msg
;
;         call       delay3s
;         call       delay3s
;
;         call       ClrLCD
;         load_table Stage2_Msg
;
;         call       delay3s

Summary
         ;movlw      B'00000000' ;it's just not happening!!!! why????!!!
         ;movwf      PORTB
         ;clrf       PORTB
         call       ClrLCD
         load_table SummaryM1_a ;choose candle #
         call       Switch_Lines
         load_table SummaryM1_b ;to Display details or...
         call       delay0.5s
         call       CheckB
         call       delay0.5s
         call       CheckB
         call       delay0.5s
         call       CheckB
         call       delay0.5s
         call       CheckB
         call       delay0.5s
         call       CheckB

         call       ClrLCD
         load_table SummaryM2_a
         call       Switch_Lines
         load_table SummaryM2_b
         call       delay0.5s
         call       CheckB
         call       delay0.5s
         call       CheckB
         call       delay0.5s
         call       CheckB
         call       delay0.5s
         call       CheckB
         call       delay0.5s
         call       CheckB
         goto       Summary

;*****PERIODICAL CHECKING INPUT SUBROUTINE************************
CheckB
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for B key input: Summary
         sublw      b'0111'     ;subtract 3 from W: corresponds to letter B on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter C is pressed indeed: previous operation is success
         goto       CheckC        ;otherwise keep checking
         ;now if B is pressed
         clrf       PORTB
         call       ClrLCD
         load_table TimeSummary
         call       testBCD ;;;;;;;;TESTING
         goto       Check0

CheckC
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for C key input: Summary
         sublw      b'1011'     ;subtract 3 from W: corresponds to letter C on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter C is pressed indeed: previous operation is success
         return;*************************RETURNS HERE***************************
         ;now if C is pressed
         clrf       PORTB
         call       ClrLCD
         load_table Results_1
         call       Switch_Lines
         load_table Results_2
         goto       Check0

Check0   ;Going back to summary menu: WORKS
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for 0 key input: Summary
         sublw      b'1101'     ;subtract 3 from W: corresponds to letter 0 on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter 0 is pressed indeed: previous operation is success
         goto       Check0
         clrf       PORTB
         goto       Summary  ;


; old results summary
;         call       ClrLCD
;         load_table Results_1
;         call       Switch_Lines
;         load_table Results_2

Stop      goto      Stop

;***********************END MAIN************************************************


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

;************************Binary to Digital Converter*************************
cblock
    BIN
    count
    huns
    tens
    ones
endc

testBCD
movlw   B'11111111'; input binary 16
;call    WR_DATA
movwf   BIN
call    BIN2BCD
movff   huns,WREG
call    WR_DATA
movff   tens,WREG
call    WR_DATA
movff   tens,WREG
call    WR_DATA
return

BIN2BCD
        movlw 8
        movwf count
        clrf huns
        clrf tens
        clrf ones

BCDADD3
        movlw 5
        subwf huns, 0
        btfsc STATUS, C
        CALL ADD3HUNS

        movlw 5
        subwf tens, 0
        btfsc STATUS, C
        CALL ADD3TENS

        movlw 5
        subwf ones, 0
        btfsc STATUS, C
        CALL ADD3ONES

        decf count, 1
        bcf STATUS, C
        rlcf BIN, 1
        rlcf ones, 1
        btfsc ones,4 ;
        CALL CARRYONES
        rlcf tens, 1

        btfsc tens,4 ;
        CALL CARRYTENS
        rlcf huns,1
        bcf STATUS, C

        movf count, 0
        btfss STATUS, Z
        GOTO BCDADD3


        movf huns, 0 ; add ASCII Offset
        addlw h'30'
        movwf huns

        movf tens, 0 ; add ASCII Offset
        addlw h'30'
        movwf tens

        movf ones, 0 ; add ASCII Offset
        addlw h'30'
        movwf ones

        RETURN

ADD3HUNS
        movlw 3
        addwf huns,1

        RETURN

ADD3TENS
        movlw 3
        addwf tens,1

        RETURN

ADD3ONES
        movlw 3
        addwf ones,1

        RETURN

CARRYONES
        bcf ones, 4
        bsf STATUS, C
        RETURN

CARRYTENS
        bcf tens, 4
        bsf STATUS, C
        RETURN


end


