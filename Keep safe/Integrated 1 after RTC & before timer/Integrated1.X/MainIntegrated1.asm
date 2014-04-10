;**************************USE THIS ONE*****************************************
;*********************
;Binary digital number conversion solved issue here ?>
;KPHexToChar
;          addwf     PCL,f
;          dt        "123A456B789C*0#D"


;---------------------->NEED MORE DELAYS FOR MOTOR*
;******************************
#include <p18f4620.inc>
#include <lcd18.inc>
; no longer 10Mhz #include <delays.inc>
#include <delays32.inc>
;#include <delays.inc>
#include <Motor.inc>
;#include <IRdetectors.inc>
#include <Relays.inc>
#include <rtc_macros.inc>

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

udata
    ;IR related
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
    ;LD related
    temp1 res 1
    temp2 res 1
    temp3 res 1
    LD1 res 1
    LD2 res 1
    LD3 res 1
    LD4 res 1
    LD5 res 1
    LD6 res 1
    LD7 res 1
    LD8 res 1
    LD9 res 1
    startHt res 1
    startHo res 1
    startMt res 1
    startMo res 1
    startSt res 1
    startSo res 1
    endHt res 1
    endHo res 1
    endMt res 1
    endMo res 1
    endSt res 1
    endSo res 1

;dont really need these
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
;*************************************************************************
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
;**************************************************************************
startConversion macro
        call     AD_CONV1
        call     delay1s ;was 1s
        call     AD_CONV2
        call     delay1s ;was 1s
        call     AD_CONV3
endm
;*************************************************************************
IRchecker macro IRx
local   setPresent, next
        btfss   temp,7  ;skip if temp is high
        bra     setPresent                            ;*to change
        movlw   b'00000000' ;set IRx to 0: absent
        movwf   IRx                                     ;*to change
        bra     next                                    ;*to change
setPresent                                            ;*to change
        movlw   b'00000001'
        movwf   IRx
        call    delay0.5s                          ;*to change
        bra    next                                    ;*to change

next
endm
;*************************************************************************
LDAN macro LDx
local checkNonFlickering_0, setOff_0,nextcdl_0, setNonFlickering_0,checkFlickering_0
;Now conversions done: do calculations
;*1 check if temp1=temp2=temp3=11111111
        movlw    b'11111111'
        cpfseq   temp1          ;if temp equal WREG skip next
        bra     checkNonFlickering_0
        cpfseq   temp2
        bra     checkNonFlickering_0
        cpfseq   temp3
        bra     checkNonFlickering_0
        bra     setOff_0 ;cdl light is off

setOff_0
        movlw   b'00000000'
        movwf   LDx         ;variable
        bra    nextcdl_0

checkNonFlickering_0 ;;;;THIS IS EFFY
        movlw   b'00100000' ;for my 6v circuit it was 00100110; this 001 is when tested with the actual circut from varun 
        cpfseq   temp1          ;if temp equal WREG skip next
        bra    checkFlickering_0
        cpfseq   temp2
        bra    checkFlickering_0
        cpfseq   temp3
        bra    checkFlickering_0
        bra    setNonFlickering_0 ;cdl light is off

setNonFlickering_0
        movlw   b'00000001'
        movwf   LDx
        bra    nextcdl_0

checkFlickering_0 ;for now by default becomes true---> later should also test, if not true, should repeat test!
        movlw   b'00000011'
        movwf   LDx
        bra    nextcdl_0


nextcdl_0

endm

displayResults macro IRx, LDx
local   load1, Lstatus, ifNF, ifF, nxt_1, ERR

         ;CHECK IR BIT
         btfss  IRx,0 ;if high skip, meaning present
         bra    load1
         call   loadP
         bra    Lstatus
load1
         call   loadA
         bra    Lstatus

Lstatus
        call    Switch_Lines
        movlw   b'00000000'
        cpfseq  LDx ;if LD is off skip next line
        bra     ifNF
        call    loadOff
        goto    nxt_1

ifNF
        movlw   b'00000001'
        cpfseq  LDx ;if LD is non-flickering skip next line
        bra     ifF
        call    loadNF
        bra     nxt_1
ifF
        movlw   b'00000011' ;/or by default just say its flickering
        cpfseq  LDx
        bra     ERR
        call    loadF
        bra     nxt_1

ERR     call    loadERR
        bra nxt_1


nxt_1
         bra       Check0

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
        db      "Press B: RTC",0
SummaryM2_b
        db      "Press C: Summary",0
Candle_P
        db      "Candle Present",0
Candle_A
        db      "Candle Absent",0
Light_Off
        db      "Light Off",0
Light_NF
        db      "Non-Flickering",0
Light_F
        db      "Flickering",0
error_m
        db      "Error",0
TimeSummary
        db      "Tot.Time:XXX sec",0

;*****************************MAIN CODE*****************************************
Mainline
;;;;;;;;;;;;;;;;Starting LCD and Providing initial prompt;;;;;;;;;;;;;;;;;;;;
	movlw		B'01110000' ;set to 8Mhz
    movwf		OSCCON
	bsf         OSCTUNE, 6  ;activate PLL multiplier to boost to 32Mhz

;;In the beginning only LCD is used hence only port D
;          clrf		TRISA ;IMP
;		  clrf		TRISB
;		  clrf		TRISC
         ;Need those for relays
		 bcf        TRISC,5
         bcf        TRISC,7
         clrf		TRISD
;;*****CLEARING IS IMPORTANT SO is calling InitLCD
         clrf      PORTA
         clrf      PORTB
         clrf      PORTC
         clrf      PORTD

         call      RTCsetup

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

;Get start Time
         call       getStartTime


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


;******NEED TO TURN ON THE RELAY for IR********
;use RC5,7 to signal relays
         call   IRrelayOn
;*****STARTING IR****;
      
         call   startIR
         call   delay0.5s
         call   ClrLCD
         load_table Stage2_Msg ;IR done
         call   delay1s
         call   ClrLCD
         call   delay0.5s
;*****TURN OFF RELAY FOR IR and TURN ON RELAY FFOR LD********;
         call   IRrelayOff

         call   delay0.5s

         call   LDrelayOn
;******STARTING LD*****;
        load_table Testing_Msg ;next stuff after block
        call    startLD

        call  ClrLCD
        load_table  Stage3_Msg
        call    Switch_Lines
        load_table  Stage3b_Msg
        call    delay1s
;********TURN OFF RELAY FOR LD****************
        call    LDrelayOff

;********BACK TO MOTORS***********************
         call   MotorLeft  ;--->WORKS TESTED
         call   delay44us
         call   ClrLCD
         load_table Stage4_Msg  ;Switches off
         call   delay0.5s
;get end time
         call   getEndTime

         goto   summaryMenu
            ;problem wiith not returning back from checking
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
         goto       RTC;go to RTC;load_table TimeSummary     ;******CHANGE
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
;         load_table Results_1       ;*Change
;         call       Switch_Lines
;         load_table Results_2
         call       displayTimeSummary
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
         displayResults IR1,LD1

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
         displayResults IR2,LD2
         
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
         displayResults IR3,LD3
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
         displayResults IR4,LD4
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
         displayResults IR5,LD5
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
         displayResults IR6,LD6

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
         displayResults IR7,LD7
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
         displayResults IR8,LD8
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
         displayResults IR9,LD9
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


;****************************IR DETECTORS*************************************
startIR
        movlw	B'00000101'	;configure ADCON1  ---> this makes AN0-AN9 the only Analogue inputs, volatge ref. set to source
		movwf	ADCON1
        ;SET TRIS HERE
         bsf     TRISB,0
         bsf     TRISB,1
         bsf     TRISB,2    ;this works!!
         bsf     TRISB,3
        ;changed acquisition time from 8Tad to 20Tad and Fosc from 32 to 64
		movlw	B'00111110'	;configure ADCON2   bit 7=0 Left justified      bits 5:3=AD acquisition time: 20*Tad= 111    bits 2:0= conversion clock set to Tosc 64=110
		movwf	ADCON2
        bra     ADSTART

ADSTART
        ;AN0--- substituted for AN1
        call    delay0.5s
        movlw   B'00000001' ;ADON=1 ;*AN1 and AN9 not working for now dk why? so imma try AN0 for AN1
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
     	;ADRESH is already in temp
        IRchecker IR1
                                                  ;*to change
        ;AN2
        movlw   B'00001001' ;ADON=1 for AN2             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        IRchecker IR2
                                                  ;*to change
        ;AN3
        movlw   B'00001101' ;ADON=1 for AN3             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        IRchecker IR3

        ;AN4
        movlw   B'00010001' ;ADON=1 for AN4             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        IRchecker IR4

        ;AN5
        movlw   B'00010101' ;ADON=1 for AN5             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        IRchecker IR5

        ;AN6
        movlw   B'00011001' ;ADON=1 for AN6             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        IRchecker IR6

        ;AN7
        movlw   B'00011101' ;ADON=1 for AN7             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        IRchecker IR7

        ;AN8
        movlw   B'00100001' ;ADON=1 for AN8             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        IRchecker IR8

        ;AN9
        movlw   B'00110001' ;ADON=1 for ;SINCE AN9 & AN10 is not working gonna try AN12-RB0, and AN12-RB0 ;AN9             *to change
        movwf   ADCON0
        call	AD_CONV	;call the A2D subroutine
        IRchecker IR9

return


AD_CONV

     	bsf		ADCON0,1	;start the conversion   set GO/DONE bit to 1 to start conversion

WAIT	btfsc	ADCON0,1	;wait until the conversion is completed by checking GO/DONE bit once it's 0
     	bra		WAIT		;poll the GO bit in ADCON0

        movff   ADRESH,temp

        return

;*******************************LIGHT DETECTOR MODULE**************************
startLD

;same as IR
movlw	B'00000101'	;configure ADCON1  ---> this makes AN0-AN9 the only Analogue inputs, volatge ref. set to source
		movwf	ADCON1
        ;SET TRIS HERE

         bsf     TRISB,0
         bsf     TRISB,1
         bsf     TRISB,2    ;this works!!
         bsf     TRISB,3

		movlw	B'00111110'	;configure ADCON2   bit 7=0 Left justified      bits 5:3=AD acquisition time: 20*Tad= 111    bits 2:0= conversion clock set to Tosc 64=110
		movwf	ADCON2

        bra LDSTART

LDSTART
        ;AN0
        call    delay0.5s ;keep
        movlw   B'00000001' ;AN0 variable
        movwf   ADCON0
        startConversion
        LDAN    LD1
        ;AN2
        call    delay0.5s
        movlw   B'00001001' ;AN2 variable
        movwf   ADCON0
        startConversion
        LDAN    LD2
        ;AN3
        call    delay0.5s
        movlw   B'00001101' ;AN2 variable
        movwf   ADCON0
        startConversion
        LDAN    LD3
        ;AN4
        call    delay0.5s
        movlw   B'00010001' ;AN2 variable
        movwf   ADCON0
        startConversion
        LDAN    LD4
        ;AN5
        call    delay0.5s
        movlw   B'00010101' ;AN2 variable
        movwf   ADCON0
        startConversion
        LDAN    LD5
        ;AN6
        call    delay0.5s
        movlw   B'00011001' ;AN2 variable
        movwf   ADCON0
        startConversion
        LDAN    LD6
        ;AN7
        call    delay0.5s
        movlw   B'00011101' ;AN2 variable
        movwf   ADCON0
        startConversion
        LDAN    LD7
        ;AN8
        call    delay0.5s
        movlw   B'00100001' ;AN2 variable
        movwf   ADCON0
        startConversion
        LDAN    LD8
        ;AN9
        call    delay0.5s
        movlw   B'00110001'
        movwf   ADCON0
        startConversion
        LDAN    LD9
return

AD_CONV1

     	bsf		ADCON0,1

WAIT1	btfsc	ADCON0,1
     	bra		WAIT1

        movff   ADRESH,temp1

        return

AD_CONV2

     	bsf		ADCON0,1

WAIT2	btfsc	ADCON0,1
     	bra		WAIT2

        movff   ADRESH,temp2

        return

AD_CONV3

     	bsf		ADCON0,1

WAIT3	btfsc	ADCON0,1
     	bra		WAIT3

        movff   ADRESH,temp3

        return

;********************************* macro related subroutines*******************
loadP
         load_table Candle_P;present
return

loadA
        load_table Candle_A
return
loadOff
        load_table  Light_Off
return
loadNF
        load_table Light_NF
return
loadERR
        load_table  error_m
return
loadF
        load_table  Light_F
return



;**************************RTC CODE********************************************
RTCsetup

 ;Set SDA and SCL to high-Z first as required for I2C
		 bsf	   TRISC,4
		 bsf	   TRISC,3


         bcf       PORTC,4
         bcf       PORTC,3


		 ;Set up I2C for communication
		 call 	   i2c_common_setup
		 ;rtc_resetAll                   ;comment afterwards

		 ;Used to set up time in RTC, load to the PIC when RTC is used for the first time
		 ;call	   set_rtc_time         ;comment afterwards

        ; call      InitLCD    ;*NOTE: This InitLCD is different than the one in main project code: the settings are different; Not anymore!
        ; LCDSettings
return

RTC
        call    ClrLCD
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
		;goto	show_RTC

Check00   ;Going back to summary menu: WORKS
         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
;test for 0 key input: Summary
         sublw      b'1101'     ;subtract 3 from W: corresponds to letter 0 on keypad
         btfss      STATUS,2    ;check if the z bit is 1--> letter 0 is pressed indeed: previous operation is success
         goto       show_RTC
         clrf       PORTB
         goto       summaryMenu



getStartTime
        ;Get hour
		rtc_read	0x02		;Read Address 0x02 from DS1307---hour
		movf	tens_digit,WREG
		movwf   startHt
		movf	ones_digit,WREG
		movwf   startHo

		;Get minute
		rtc_read	0x01		;Read Address 0x01 from DS1307---min
		movf	tens_digit,WREG
		movwf   startMt
		movf	ones_digit,WREG
		movwf   startMo

		;Get seconds
		rtc_read	0x00		;Read Address 0x00 from DS1307---seconds
		movf	tens_digit,WREG
		movwf   startSt
		movf	ones_digit,WREG
		movwf   startSo

return

getEndTime
        ;Get hour
		rtc_read	0x02		;Read Address 0x02 from DS1307---hour
		movf	tens_digit,WREG
		movwf   endHt
		movf	ones_digit,WREG
		movwf   endHo

		;Get minute
		rtc_read	0x01		;Read Address 0x01 from DS1307---min
		movf	tens_digit,WREG
		movwf   endMt
		movf	ones_digit,WREG
		movwf   endMo

		;Get seconds
		rtc_read	0x00		;Read Address 0x00 from DS1307---seconds
		movf	tens_digit,WREG
		movwf   endSt
		movf	ones_digit,WREG
		movwf   endSo

return

displayTimeSummary
;Starting time first
        ;hours
		movf	startHt,WREG
		call	WR_DATA
		movf	startHo,WREG
		call	WR_DATA
		movlw			":"
		call	WR_DATA

		;minute
		movf	startMt,WREG
		call	WR_DATA
		movf	startMo,WREG
		call	WR_DATA
		movlw			":"
		call	WR_DATA

		;Get seconds
		movf	startSt,WREG
		call	WR_DATA
		movf	startSo,WREG
		call	WR_DATA

        call    Switch_Lines
;end time second
        ;hours
		movf	endHt,WREG
		call	WR_DATA
		movf	endHo,WREG
		call	WR_DATA
		movlw			":"
		call	WR_DATA

		;minute
		movf	endMt,WREG
		call	WR_DATA
		movf	endMo,WREG
		call	WR_DATA
		movlw			":"
		call	WR_DATA

		;Get seconds
		movf	endSt,WREG
		call	WR_DATA
		movf	endSo,WREG
		call	WR_DATA

return

;***************************************
; Setup RTC with time defined by user
;***************************************
set_rtc_time

		rtc_resetAll	;reset rtc

		rtc_set	0x00,	B'10000000'

		;set time
		rtc_set	0x06,	B'00010100'		; Year 2014
		rtc_set	0x05,	B'00000011'		; Month:3
		rtc_set	0x04,	B'00100011'		; Date
		rtc_set	0x03,	B'00000111'		; Day
		rtc_set	0x02,	B'00010000'		; Hours  ;;;;am/pm 3rd high  00010100
		rtc_set	0x01,	B'01001001'		; Minutes
		rtc_set	0x00,	B'00000000'		; Seconds
		return


end