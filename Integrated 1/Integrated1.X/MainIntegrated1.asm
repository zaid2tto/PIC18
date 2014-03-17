;**************************USE THIS ONE*****************************************
#include <p18f4620.inc>
#include <lcd18.inc>
; no longer 10Mhz #include <delays.inc>
#include <delays32.inc>
;#include <delays.inc>
#include <Motor.inc>
;#include <IRdetectors.inc>


		list P=18F4620, F=INHX32, C=160, N=80, ST=OFF, MM=OFF, R=DEC

;;;;;;Configuration Bits;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		CONFIG OSC=INTIO67;OSC=HS INTERNAL OSCILLATOR!
        ;CONFIG OSC=HS
        CONFIG FCMEN=OFF, IESO=OFF
		CONFIG PWRT = OFF, BOREN = SBORDIS ;ON,
        CONFIG BORV = 3
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


;defines global IR variables
    
;YES IR works in a separate file!
udata
    temp res 1
    IR1 res 1
    IR2 res 1
    IR3 res 1
    IR4 res 1
    IR5 res 1
    IR6 res 1
    IR7 res 1
    IR8 res 1
    IR9 res 1

global  temp, IR1, IR2, IR3, IR4, IR5, IR6, IR7, IR8, IR9


;    temp EQU 0x74
;    IR2 EQU 0x76
;    IR3 EQU 0x77
;    IR4 EQU 0x78
;    IR5 EQU 0x79
;    IR6 EQU 0x80
;    IR7 EQU 0x81
;    IR8 EQU 0x82
;    IR9 EQU 0x83


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

;IRTester    macro   IRx, P, A
;        call    delay44us
;        call    delay44us
;        btfss   IRx,0
;        local   loadA
;        load_table  P
;        local   next_1
;loadA:
;        load_table  A
;next_1:
;
;endm


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
        db      "Switches Are On",0
Stage2_Msg
        db      "IR Testing Done",0
Stage3_Msg
        db      "Light detection",0
Stage3b_Msg
        db      "Complete",0
Stage4_Msg
        db      "Switches off",0
Time_Msg
        db      "Time:hh:mm",0
Results_1
        db      "CNDL:",0       ;shows the present candles
Results_2
        db      "Pass:",0       ;display Y/N for pass fail
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
Candle_P
        db      "Candle Present",0
Candle_A
        db      "Candle Absent",0
TimeSummary
        db      "Tot.Time:XXX sec",0




;*****************************MAIN CODE*****************************************
Mainline

;;;;;;;;;;;;;;;;Starting LCD and Providing initial prompt;;;;;;;;;;;;;;;;;;;;
	movlw		B'01110000' ;set to 8Mhz
    movwf		OSCCON
	bsf         OSCTUNE, 6  ;activate PLL multiplier to boost to 32Mhz
   ;* *
    ;bcf		INTCON,GIE


;;In the beginning only LCD is used hence only port D
;;          clrf		TRISA ;IMP
;;		  clrf		TRISB
;;		  clrf		TRISC
		  clrf		TRISD
;;*****CLEARING IS IMPORTANT SO is calling InitLCD
         clrf      PORTA
         clrf      PORTB
         clrf      PORTC
         clrf      PORTD
;
          call      delay5ms		;wait for LCD to start up
          call      delay5ms

          ;*VERY IMP*
          call      InitLCD
          LCDSettings
;;;;;;;;;;Display first prompt
          ;call  ClrLCD
          load_table  Greeting
          call      Switch_Lines
          load_table  Testing_Prompt

;;;;;;;;;;;;;;;;;Get Input from Keypad;;;;;;;;;;;;;;;


         clrf      INTCON         ; No interrupts


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
         ;************************START OF OPERATIONS**************************;

         call   delay1s
         call   delay1s
         call   MotorRight ;WORKS!
         ;call   delay1s
         ; reset ports/bits
         call   ClrLCD
         load_table Stage1_Msg
         call   delay1s
         call   ClrLCD
         load_table Testing_Msg
;*****STARTING IR****;
      
         call   startIR
         call   delay0.5s
         call   ClrLCD
         load_table Stage2_Msg ;IR done
       ; testing results
  ;       call   delay1s
         call   delay1s
         call   ClrLCD
         call   delay0.5s
         

;**************IMP IR RESULT TELLER******************************
;         btfss  IR1,0 ;if high skip, meaning present
;         goto   loadA
;         load_table Candle_P;present
;         goto   next_1
;loadA
;        load_table  Candle_A
;        goto    next_1
;
;next_1
;        call    delay3s

;******************************************************************************
;IRTester    IR1, Candle_P, Candle_A
;call    delay3s

;here goto here


;         ;call startLD ---->WORK ON NEXT!
        load_table Testing_Msg ;next stuff after block
        call  ClrLCD
        load_table  Stage3_Msg
        call    Switch_Lines
        load_table  Stage3b_Msg
        call    delay1s
   ;     call    delay3s

;         ; reset ports/bits
         call   MotorLeft  ;--->WORKS TESTED
         call   delay44us
         call   ClrLCD
         load_table Stage4_Msg  ;Switches off
   ;      call   delay1s
  ;       call   delay1s
         call   delay0.5s



         goto   summaryMenu

summaryMenu
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
         goto       summaryMenu

;*****PERIODICAL CHECKING INPUT SUBROUTINE************************
CheckB
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for B key input: Summary
         sublw      b'0111'     ;subtract 3 from W: corresponds to letter B on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter C is pressed indeed: previous operation is success
         goto       CheckC        ;otherwise keep checking ******CHANGE
         ;now if B is pressed
         clrf       PORTB
         call       ClrLCD
         load_table TimeSummary     ;******CHANGE
         goto       Check0

CheckC
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for C key input: Summary
         sublw      b'1011'     ;subtract 3 from W: corresponds to letter C on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter C is pressed indeed: previous operation is success
         goto       Check1           ;***Change
;old code         return;*************************RETURNS HERE***************************
         ;now if C is pressed
         clrf       PORTB
         call       ClrLCD
         load_table Results_1       ;*Change
         call       Switch_Lines
         load_table Results_2
         goto       Check0

Check1
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for 1 key input: Summary
         sublw      b'0000'     
         btfss      STATUS,2    
         goto       Check2           
         ;now if 1 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR1,0 ;if high skip, meaning present
         goto   load1
         load_table Candle_P;present
         goto   nxt_1
load1
         load_table  Candle_A
         goto    nxt_1

nxt_1
         goto       Check0

Check2
         swapf		PORTB,W     
         andlw		0x0F
;test for 2 key input: Summary
         sublw      b'0001'     
         btfss      STATUS,2    
         goto       Check3           
         ;now if 2 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR2,0 ;if high skip, meaning present
         goto   load2
         load_table Candle_P;present
         goto   nxt_2
load2
         load_table  Candle_A
         goto    nxt_2

nxt_2
         goto       Check0

Check3
         swapf		PORTB,W     
         andlw		0x0F
;test for 3 key input: Summary
         sublw      b'0010'     
         btfss      STATUS,2    
         goto       Check4           
         ;now if 3 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR3,0 ;if high skip, meaning present
         goto   load3
         load_table Candle_P;present
         goto   nxt_3
load3
         load_table  Candle_A
         goto    nxt_3

nxt_3
         goto       Check0

Check4
         swapf		PORTB,W
         andlw		0x0F
;test for 4 key input: Summary
         sublw      b'0100'
         btfss      STATUS,2
         goto       Check5           ;***Change
         ;now if 4 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR4,0 ;if high skip, meaning present
         goto   load4
         load_table Candle_P;present
         goto   nxt_4
load4
         load_table  Candle_A
         goto    nxt_4

nxt_4
         goto       Check0

Check5
         swapf		PORTB,W
         andlw		0x0F
;test for 5 key input: Summary
         sublw      b'0101'
         btfss      STATUS,2
         goto       Check6           ;***Change
         ;now if 5 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR5,0 ;if high skip, meaning present
         goto   load5
         load_table Candle_P;present
         goto   nxt_5
load5
         load_table  Candle_A
         goto    nxt_5

nxt_5
         goto       Check0

Check6
         swapf		PORTB,W
         andlw		0x0F
;test for 6 key input: Summary
         sublw      b'0110'
         btfss      STATUS,2
         goto       Check7           ;***Change
         ;now if 6 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR6,0 ;if high skip, meaning present
         goto   load6
         load_table Candle_P;present
         goto   nxt_6
load6
         load_table  Candle_A
         goto    nxt_6

nxt_6
         goto       Check0

Check7
         swapf		PORTB,W
         andlw		0x0F
;test for 7 key input: Summary
         sublw      b'1000'
         btfss      STATUS,2
         goto       Check8           ;***Change
         ;now if 7 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR7,0 ;if high skip, meaning present
         goto   load7
         load_table Candle_P;present
         goto   nxt_7
load7
         load_table  Candle_A
         goto    nxt_7

nxt_7
         goto       Check0

Check8
         swapf		PORTB,W
         andlw		0x0F
;test for 8 key input: Summary
         sublw      b'1001'
         btfss      STATUS,2
         goto       Check9           ;***Change
         ;now if 8 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR8,0 ;if high skip, meaning present
         goto   load8
         load_table Candle_P;present
         goto   nxt_8
load8
         load_table  Candle_A
         goto    nxt_8

nxt_8
         goto       Check0

Check9
         swapf		PORTB,W
         andlw		0x0F
;test for 9 key input: Summary
         sublw      b'1010'
         btfss      STATUS,2

         return       ;*****************RETURN FROM CHECK HERE*************;

         ;now if 9 is pressed
         clrf       PORTB
         call       ClrLCD
         ;CHECK IR BIT
         btfss  IR9,0 ;if high skip, meaning present
         goto   load9
         load_table Candle_P;present
         goto   nxt_9
load9
         load_table  Candle_A
         goto    nxt_9

nxt_9
         goto       Check0


Check0   ;Going back to summary menu: WORKS
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for 0 key input: Summary
         sublw      b'1101'     ;subtract 3 from W: corresponds to letter 0 on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter 0 is pressed indeed: previous operation is success
         goto       Check0
         clrf       PORTB
         goto       summaryMenu  ;



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


;**************IR****************************
startIR
        movlw	B'00000101'	;configure ADCON1  ---> this makes AN0-AN9 the only Analogue inputs, volatge ref. set to source
		movwf	ADCON1
        ;SET TRIS HERE
;        setf    TRISA
;        setf    TRISE
         bsf     TRISB,0
         bsf     TRISB,1
         bsf     TRISB,2    ;this works!!
         bsf     TRISB,3
;        clrf    PORTA
;        clrf    PORTE
;        clrf    PORTB
;        bcf     PORTB,2
;        bcf     PORTB,3
        ;changed acquisition time from 8Tad to 20Tad and Fosc from 32 to 64
		movlw	B'00111110'	;configure ADCON2   bit 7=0 Left justified      bits 5:3=AD acquisition time: 20*Tad= 111    bits 2:0= conversion clock set to Tosc 64=110
		movwf	ADCON2

        bra     ADSTART


ADSTART
        ;AN1
        call    delay0.5s
        movlw   B'00000001' ;ADON=1 ;*AN1 and AN9 not working for now dk why? so imma try AN0 for AN1
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	;ADRESH is already in temp
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_1                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR1                                     ;*to change
        goto    next1                                    ;*to change
setPresent_1                                            ;*to change
        movlw   b'00000001'
        movwf   IR1
        call    delay0.5s                          ;*to change
        goto    next1                                    ;*to change

next1                                                    ;*to change
        ;AN2
        movlw   B'00001001' ;ADON=1 for AN2             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_2                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR2                                     ;*to change
        goto    next2                                    ;*to change
setPresent_2                                            ;*to change
        movlw   b'00000001'
        movwf   IR2
        call    delay0.5s        ;*to change
        goto    next2                                    ;*to change

next2                                                    ;*to change
        ;AN3
        movlw   B'00001101' ;ADON=1 for AN3             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_3                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR3                                     ;*to change
        goto    next3                                    ;*to change
setPresent_3                                            ;*to change
        movlw   b'00000001'
        movwf   IR3
        call    delay0.5s        ;*to change
        goto    next3                                    ;*to change

next3
        ;AN4
        movlw   B'00010001' ;ADON=1 for AN4             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_4                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR4                                     ;*to change
        goto    next4                                    ;*to change
setPresent_4                                            ;*to change
        movlw   b'00000001'
        movwf   IR4
        call    delay0.5s        ;*to change
        goto    next4                                    ;*to change

next4
        ;AN5
        movlw   B'00010101' ;ADON=1 for AN5             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_5                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR5                                     ;*to change
        goto    next5                                    ;*to change
setPresent_5                                            ;*to change
        movlw   b'00000001'
        movwf   IR5
        call    delay0.5s        ;*to change
        goto    next5                                    ;*to change

next5
        ;AN6
        movlw   B'00011001' ;ADON=1 for AN6             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_6                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR6                                     ;*to change
        goto    next6                                    ;*to change
setPresent_6                                            ;*to change
        movlw   b'00000001'
        movwf   IR6
        call    delay0.5s                                 ;*to change
        goto    next6                                    ;*to change

next6
        ;AN7
        movlw   B'00011101' ;ADON=1 for AN7             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_7                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR7                                     ;*to change
        goto    next7                                    ;*to change
setPresent_7                                            ;*to change
        movlw   b'00000001'
        movwf   IR7
        call    delay0.5s                                    ;*to change
        goto    next7                                    ;*to change

next7
        ;AN8
        movlw   B'00100001' ;ADON=1 for AN8             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        btfss   temp,7  ;skip if temp is high
        goto    setPresent_8                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IR8                                     ;*to change
        goto    next8                                    ;*to change
setPresent_8                                            ;*to change
        movlw   b'00000001'
        movwf   IR8
        call    delay0.5s                                    ;*to change
        goto    next8                                    ;*to change

next8
        ;AN9
        movlw   B'00110001' ;ADON=1 for ;SINCE AN9 & AN10 is not working gonna try AN12-RB0, and AN12-RB0 ;AN9             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
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

     	bsf		ADCON0,1	;start the conversion   set GO/DONE bit to 1 to start conversion

WAIT	btfsc	ADCON0,1	;wait until the conversion is completed by checking GO/DONE bit once it's 0
     	bra		WAIT		;poll the GO bit in ADCON0

        movff   ADRESH,temp
;put after call to subroutine     	movf	ADRESH,W	;move the high 8-bit to W
     	;call delay1s
        return







end





