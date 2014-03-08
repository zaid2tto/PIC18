



#include <p18f4620.inc>
        list P=18F4620,F=INHX32, C=160, N=80, ST=OFF, MM=OFF, R=DEC

;;;;;;Configuration Bits;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		CONFIG OSC=HS,FCMEN=OFF, IESO=OFF
		CONFIG PWRT = OFF, BOREN = SBORDIS, BORV = 3
		CONFIG WDT = OFF, WDTPS = 32768
		CONFIG MCLRE = ON, LPT1OSC = OFF, PBADEN = OFF, CCP2MX = PORTC
		CONFIG STVREN = ON, LVP = OFF, XINST = OFF
		CONFIG DEBUG = ON
		CONFIG CP0 = OFF, CP1 = OFF, CP2 = OFF, CP3 = OFF
		CONFIG CPB = OFF, CPD = OFF
		CONFIG WRT0 = OFF, WRT1 = OFF, WRT2 = OFF, WRT3 = OFF
		CONFIG WRTB = OFF, WRTC = OFF, WRTD = OFF
		CONFIG EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
		CONFIG EBTRB = OFF

	cblock	0x71
		dt1			;0x71		 addresses are used for the RTC module
        dt2			;0x72
        ADD			;0x73
        DAT			;0x74
        DOUT		;0x75
        B1			;0x76
		dig10		;0x77
		dig1		;0x78

		COUNTH
		COUNTM
		COUNTL
		Table_Counter
		lcd_tmp
		lcd_d1
		counter_PWM
		lcd_d2
		com
		lcd_number
		pack_one
		pack_two
		selected
		pack_temp
		amberChipCount
		camelChipCount
		operationCount
		distanceLeft
		distanceRight
		amberChipHeight ;amber will be left
		camelChipHeight ;camel will be right
		reservoirHeight
		chipThickness
		divisionCount
		toDivide
		divideBy
		chipsDispensed
		temptemp
		delay_timer
		amber_divided
		checkDone
		divTemp
		d1
		d2
		d3
		d4
		totprogcount
		curmem

		dat
		runnum
	endc

	;Declare constants for pin assignments (LCD on PORTD)
		#define	RS 	PORTD,2
		#define	E 	PORTD,3


         ORG       0x0000     ;RESET vector must always be at 0x00
         goto      Main_Method       ;Just jump to the main code section.


;***************************************
; Delay: ~160us macro
;***************************************
i2c_common_check_ack	macro	err_address		;If bad ACK bit received, goto err_address
	banksel		SSPCON2
    btfsc       SSPCON2,ACKSTAT
    goto        err_address
	endm


i2c_common_start	macro
;input:		none
;output:	none
;desc:		initiate start conditionon the bus
	banksel     SSPCON2
    bsf         SSPCON2,SEN
	nop
    btfsc       SSPCON2,SEN
    goto         $-2
	endm

i2c_common_stop	macro
;input: 	none
;output:	none
;desc:		initiate stop condition on the bus
	banksel     SSPCON2
    bsf         SSPCON2,PEN
	nop
    btfsc       SSPCON2,PEN
    goto        $-2
	endm

i2c_common_repeatedstart	macro
;input:		none
;output:	none
;desc:		initiate repeated start on the bus. Usually used for
;			changing direction of SDA without STOP event
	banksel     SSPCON2
    bsf         SSPCON2,RSEN
	nop
    btfsc       SSPCON2,RSEN
    goto        $-2
	endm

i2c_common_ack		macro
;input:		none
;output:	none
;desc:		send an acknowledge to slave device
    banksel     SSPCON2
    bcf         SSPCON2,ACKDT
    bsf         SSPCON2,ACKEN
	nop
    btfsc       SSPCON2,ACKEN
    goto        $-2
    endm

i2c_common_nack	macro
;input:		none
;output:	none
;desc:		send an not acknowledge to slave device
   banksel     SSPCON2
   bsf         SSPCON2,ACKDT
   bsf         SSPCON2,ACKEN
   nop
   btfsc       SSPCON2,ACKEN
   goto        $-2
   endm

i2c_common_write	macro
;input:		W
;output:	to slave device
;desc:		writes W to SSPBUF and send to slave device. Make sure
;			transmit is finished before continuing
   banksel     SSPBUF
   movwf       SSPBUF
   banksel     SSPSTAT
	nop
   btfsc       SSPSTAT,R_W 		;While transmit is in progress, wait
   goto        $-2
   banksel     SSPCON2
   endm

i2c_common_read	macro
;input:		none
;output:	W
;desc:		reads data from slave and saves it in W.
   banksel     SSPCON2
   bsf         SSPCON2,RCEN    ;Begin receiving byte from
   nop
   btfsc       SSPCON2,RCEN
   goto        $-2
   banksel     SSPBUF
   movf        SSPBUF,w
   endm

rtc_resetAll	macro
;input:		none
;output:	none
;desc:		Resets all the time keeping registers on the RTC to zero
	clrf		DAT
	clrf		ADD
    call        write_rtc		;Write 0 to Seconds
    incf        ADD   			;Set register address to 1
	call		write_rtc
    incf        ADD   			;Set register address to 2
	call		write_rtc
    incf        ADD   			;Set register address to 3
	call		write_rtc
    incf        ADD   			;Set register address to 4
	call		write_rtc
    incf        ADD   			;Set register address to 5
	call		write_rtc
    incf        ADD   			;Set register address to 6
	call		write_rtc
	endm

rtc_set		macro	addliteral,datliteral
;input:		addliteral: value of address
;			datliteral: value of data
;output:	none
;desc:		loads the data in datliteral into the
;			address specified by addliteral in the RTC
	movlw	addliteral
	movwf	ADD
	movlw	datliteral
	movwf	DAT
	call	write_rtc
	endm

rtc_read	macro	addliteral
;input:		addliteral
;output:	DOUT, dig10, dig1
;desc:		From the selected register in the RTC, read the data
;			and load it into DOUT. DOUT is also converted into
;			ASCII characters and the tens digit is placed into
;			dig10 and the ones digit is placed in dig1
	movlw	addliteral
	movwf	ADD
	call	read_rtc
	movf	DOUT,w
	call	rtc_convert
	endm

LCD_DELAY macro
	movlw   0xFF
	movwf   lcd_d1
lcd_delay_1
	decfsz  lcd_d1,f
	goto    lcd_delay_1
	endm

;***************************************
; Write Macro
;***************************************
;WRT_LCD macro val
;	movlw   val
;	call    WrtLCD
;	endm

;***************************************
; Display macro
;***************************************
;Display macro	Message
;		local	loop_
;		local 	end_
;		clrf	Table_Counter
;		clrw
;loop_	movf	Table_Counter,W
;		call 	Message
;		xorlw	B'00000000' ;check WORK reg to see if 0 is returned
;		btfsc	STATUS,Z
;			goto	end_
;		call	WR_DATA
;		incf	Table_Counter,F
;		goto	loop_
;end_
;		endm

;***************************************
; Look up table
;***************************************

Input_Prompt_1
        movlw   "P"
        call    WR_DATA
        movlw   "l"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "s"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "s"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "l"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "c"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "P"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "n"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "("
        call    WR_DATA
        movlw   "1"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "6"
        call    WR_DATA
        movlw   ")"
        call    WR_DATA
        return

Input_Prompt_2
        movlw   "1"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "h"
        call    WR_DATA
        movlw   "i"
        call    WR_DATA
        movlw   "p"
        call    WR_DATA
        movlw   "s"
        call    WR_DATA
        movlw   ","
        call    WR_DATA
        movlw   "2"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "T"
        call    WR_DATA
        movlw   "i"
        call    WR_DATA
        movlw   "m"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "3"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "P"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "n"
        call    WR_DATA
        movlw   "s"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "4"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
		movlw   "L"
        call    WR_DATA
        movlw   "o"
        call    WR_DATA
        movlw   "g"
        call    WR_DATA
		movlw   "s"
        call    WR_DATA
        return

Pattern_1
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "S"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ","
        call    WR_DATA
        movlw   "B"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        return

Pattern_2
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "S"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ","
        call    WR_DATA
        movlw   "B"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        return

Pattern_3
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "S"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ","
        call    WR_DATA
        movlw   "B"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        return

Pattern_4
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "S"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ","
        call    WR_DATA
        movlw   "B"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        return

Pattern_5
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "S"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ","
        call    WR_DATA
        movlw   "B"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        return

Pattern_6
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "S"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ","
        call    WR_DATA
        movlw   "B"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        return

Start_Op
        movlw   "S"
        call    WR_DATA
        movlw   "T"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "R"
        call    WR_DATA
        movlw   "T"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "O"
        call    WR_DATA
        movlw   "P"
        call    WR_DATA
        movlw   "E"
        call    WR_DATA
        movlw   "R"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "T"
        call    WR_DATA
        movlw   "I"
        call    WR_DATA
        movlw   "O"
        call    WR_DATA
        movlw   "N"
        call    WR_DATA
        return

Pack_One
        movlw   "P"
        call    WR_DATA
        movlw   "1"
        call    WR_DATA
        movlw   ":"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        return

Pack_Two
        movlw   "P"
        call    WR_DATA
        movlw   "2"
        call    WR_DATA
        movlw   ":"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        return
Num_1
        movlw   "1"
        call    WR_DATA
		movlw   ":"
        call    WR_DATA
        return

Num_2
		movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
		movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "2"
        call    WR_DATA
		movlw   ":"
        call    WR_DATA
        return

DD_0
        movlw   "0"
        call    WR_DATA
        return

DD_1
        movlw   "1"
        call    WR_DATA
        return

DD_2
        movlw   "2"
        call    WR_DATA
        return

DD_3
        movlw   "3"
        call    WR_DATA
        return

DD_4
        movlw   "4"
        call    WR_DATA
        return

DD_5
        movlw   "5"
        call    WR_DATA
        return

DD_6
        movlw   "6"
        call    WR_DATA
        return

DD_7
        movlw   "7"
        call    WR_DATA
        return

DD_8
        movlw   "8"
        call    WR_DATA
        return

DD_9
        movlw   "9"
        call    WR_DATA
        return

DD_10
        movlw   "1"
        call    WR_DATA
		movlw   "0"
        call    WR_DATA
        return

DD_Op_Time
        movlw   "O"
        call    WR_DATA
        movlw   "p"
        call    WR_DATA
        movlw   "-"
        call    WR_DATA
        movlw   "T"
        call    WR_DATA
        movlw   "i"
        call    WR_DATA
        movlw   "m"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   ":"
        call    WR_DATA
        movlw   "1"
        call    WR_DATA
        movlw   ":"
        call    WR_DATA
        movlw   "1"
        call    WR_DATA
        movlw   "2"
		call    WR_DATA
        return

Pat_1
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        return

Pat_2
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
       return

Pat_3
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        return

Pat_4
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        return

Pat_5
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        return

Pat_6
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        movlw   "A"
        call    WR_DATA
        movlw   "C"
        call    WR_DATA
        return

DD_Amber_Chip
		movlw   "A"
        call    WR_DATA
        movlw   "m"
        call    WR_DATA
        movlw   "b"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "r"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "c"
        call    WR_DATA
        movlw   "o"
        call    WR_DATA
        movlw   "u"
        call    WR_DATA
        movlw   "n"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ":"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
		return


DD_Camel_Chip
		movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
		movlw   "C"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "m"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "l"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "c"
        call    WR_DATA
        movlw   "o"
        call    WR_DATA
        movlw   "u"
        call    WR_DATA
        movlw   "n"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ":"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
		return

Compla
		movlw   "O"
        call    WR_DATA
        movlw   "P"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "C
        call    WR_DATA
        movlw   "O
        call    WR_DATA
        movlw   "M
        call    WR_DATA
        movlw   "P
        call    WR_DATA
        movlw   "L
        call    WR_DATA
        movlw   "E
        call    WR_DATA
        movlw   "T
        call    WR_DATA
        movlw   "E
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   " "
        call    WR_DATA
		movlw   "C"
        call    WR_DATA
        movlw   "a"
        call    WR_DATA
        movlw   "m"
        call    WR_DATA
        movlw   "e"
        call    WR_DATA
        movlw   "l"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
        movlw   "c"
        call    WR_DATA
        movlw   "o"
        call    WR_DATA
        movlw   "u"
        call    WR_DATA
        movlw   "n"
        call    WR_DATA
        movlw   "t"
        call    WR_DATA
        movlw   ":"
        call    WR_DATA
        movlw   " "
        call    WR_DATA
		return
;***************************************
; Initialize LCD
;***************************************
Main_Method
		 goto init
init_complete
		 goto Counting_Chips
counting_chips_complete
		 goto Dispensing_Chips
dispensing_chips_complete_1
		 goto Cycling_Containers
cycling_containers_complete_1

		 goto Dispensing_Chips
dispensing_chips_complete_2
		 goto Cycling_Containers
cycling_containers_complete_2

		 goto Cycling_Containers
cycling_containers_complete_3

		goto Display_Information


init
         clrf      INTCON         ; No interrupts

         movlb 	   b'0001'     ; select bank 1
         clrf      TRISA          ; All port A is output
         movlw     b'11110010'    ; Set required keypad inputs
         movwf     TRISB
		 movlw     b'11100000'    ; Set required keypad inputs
         movwf     TRISC
         clrf      TRISD          ; All port D is output
		 bsf	   TRISC,4
		 bsf	   TRISC,3
         movlb 	   b'0000'     ; select bank 0
         clrf      PORTA
         clrf      PORTB
         clrf      PORTC
         clrf      PORTD
         call 	   i2c_common_setup
         call      InitLCD  	  ;Initialize the LCD (code in lcd.asm; imported by lcd.inc)

		movlw   H'01'
		movwf	EEADRH
		movlw   H'00'
		movwf	EEADR
		bcf		EECON1, EEPGD
		bcf		EECON1, CFGS
		bsf		EECON1, RD
		movf	EEDATA, w
		movwf	runnum
		movlw H'00'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'01'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'02'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'03'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'04'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'05'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'06'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'07'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'08'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'09'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play
		movlw H'0A'
 	    xorwf runnum, w
		btfsc STATUS, Z
		goto play

		 movlw     H'00'
		 movwf     runnum
play		 goto show_RTC
rdone

	 call 	   Clear_Display
  		 call  	   Input_Prompt_1
		 movlw     H'01'
		 addwf     runnum, F
		 movlw     H'00'
         movwf     selected

test     btfss		PORTB,1     ;Wait until data is available from the keypad
         goto		test

         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
		 movwf      pack_temp
		 movlw 		H'01'
 		 xorwf 		selected, w
	   	 btfss 		STATUS, Z
         goto       WrtLCD      ;Write the value in W to LCD
		 goto       WrtLCDTwo
nest
         btfsc		PORTB,1     ;Wait until key is released
         goto		nest
         goto       test

Counting_Chips

		; bsf		PORTA,1
;spin	 btfss		PORTC,6     ;Wait until data is available from the keypad
 ;        goto		spin
;		 bcf	PORTA, 1


	;	 bsf		PORTA,5
;hello_world_2	 btfsc		PORTC,7     ;Wait until key is released
 ;        goto		hello_world_2

;spin	 ;call Delay_1
;		 btfss		PORTC,7     ;Wait until data is available from the keypad
 ;        goto		spin
;		 bcf	PORTA, 5
;		 call Delay_2yea
;		 goto Counting_Chips

	  	 ;bsf		PORTA,4
		 ;btfsc		PORTC,7     ;Wait until key is released
        ;goto		Counting_Chips

;spin	 ;call Delay_1
		 ;bcf		PORTA, 5
		 ;call		Delay_PWM_Rem
		 ;bsf		PORTA, 5
		 ;call 		Delay_PWM_Rem_1
;		 btfss		PORTC,7     ;Wait until data is available from the keypad
 ;       goto		spin
;		call Delay_PWM_Rem
;		 bcf	PORTA, 4
;		 call Delay_2yea
;		 goto Counting_Chips

		 movlw H'00'
		 movwf  amberChipCount
		 movwf  camelChipCount
		 movwf	operationCount
		 movwf	distanceLeft
		 movwf	distanceRight



	;	 bsf	PORTC, 0
	;	 bsf	PORTC, 1
	 ;   	bsf	PORTA, 0
	;	 bsf	PORTA, 1
	;	 call Delay_10
	;	 bcf	PORTA, 0
	;	 bcf	PORTA, 1
	;	 bcf    PORTC, 0
	;	 bcf    PORTC, 1
		 call Delay_1
		 ;Do all the sensor crap
		 movlw H'0E'             ;
		 movwf  amberChipCount   ;
		 movlw H'0E'             ;
		 movwf  camelChipCount   ;
		 goto counting_chips_complete




Dispensing_Chips
		 movlw H'09'
		 movwf  chipsDispensed
		 movlw H'0A'
		 movwf	checkDone

		 movlw H'00'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
		 movff pack_one, selected

		 movlw H'01'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
		 movff pack_two, selected

		 movlw H'00'
 	     xorwf selected, w
		 btfsc STATUS, Z
	     goto dispense_1
		 movlw H'01'
 	     xorwf selected, w
		 btfsc STATUS, Z
	     goto dispense_2
		 movlw H'02'
 	     xorwf selected, w
		 btfsc STATUS, Z
	     goto dispense_3
		 movlw H'04'
 	     xorwf selected, w
		 btfsc STATUS, Z
	     goto dispense_4
		 movlw H'05'
 	     xorwf selected, w
		 btfsc STATUS, Z
	     goto dispense_5
		 movlw H'06'
 	     xorwf selected, w
		 btfsc STATUS, Z
	     goto dispense_6

dispense_1
		 call dispense_amber_chip
		 movlw H'00'
 	     xorwf checkDone, w
		 btfsc STATUS, Z
		 goto dispensing_chips_complete_check
		 goto dispense_1
dispense_2
		 call dispense_camel_chip
		 movlw H'00'
 	     xorwf checkDone, w
		 btfsc STATUS, Z
		 goto dispensing_chips_complete_check
		 goto dispense_2
dispense_3
		 movff chipsDispensed, toDivide
		 movlw H'05'
		 movwf divideBy
		 call Divide_Dispense
		 movlw H'00'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_amber_chip
		 movlw H'01'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_camel_chip
		 movlw H'00'
 	     xorwf checkDone, w
		 btfsc STATUS, Z
		 goto dispensing_chips_complete_check
		 goto dispense_3
dispense_4
		 movff chipsDispensed, toDivide
		 movlw H'02'
		 movwf divideBy
		 call Divide_Dispense
		 movlw H'00'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_camel_chip
		 movlw H'01'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_amber_chip
		 movlw H'02'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_camel_chip
		 movlw H'03'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_amber_chip
		 movlw H'04'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_camel_chip
		 movlw H'00'
 	     xorwf checkDone, w
		 btfsc STATUS, Z
		 goto dispensing_chips_complete_check
		 goto dispense_4
dispense_5
		 movff chipsDispensed, toDivide
		 movlw H'02'
		 movwf divideBy
		 call Divide_Dispense
		 movlw H'00'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_amber_chip
		 movlw H'01'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_camel_chip
		 movlw H'02'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_amber_chip
		 movlw H'03'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_camel_chip
		 movlw H'04'
 	     xorwf divisionCount, w
		 btfsc STATUS, Z
		 call dispense_amber_chip
		 movlw H'00'
 	     xorwf checkDone, w
		 btfsc STATUS, Z
		 goto dispensing_chips_complete_check
		 goto dispense_5
dispense_6
		 movff chipsDispensed, toDivide
		 movlw H'02'
		 movwf divideBy
		 call Divide_Dispense
		 movlw H'00'
 	     xorwf divTemp, w
		 btfsc STATUS, Z
		 call dispense_camel_chip
		 movlw H'01'
 	     xorwf divTemp, w
		 btfsc STATUS, Z
		 call dispense_amber_chip
		 movlw H'00'
 	     xorwf checkDone, w
		 btfsc STATUS, Z
		 goto dispensing_chips_complete_check
		 goto dispense_6

dispense_amber_chip
		 bsf		PORTA,0
		 btfsc		PORTC,6     ;Wait until key is released
         goto		dispense_amber_chip

spin_1	 call Delay_1
		 btfss		PORTC,6     ;Wait until data is available from the keypad
         goto		spin_1
		 bcf	PORTA, 0
		 call Delay_2yea
		 goto	Delay_1_0_1
amber_2
		 movlw H'01'
		 subwf chipsDispensed, F
		 subwf checkDone, F
		 subwf amberChipCount, F
         return

dispense_camel_chip
		 bsf		PORTA,4
		 btfsc		PORTC,5     ;Wait until key is released
         goto		dispense_camel_chip
spin_2	 call Delay_1
		 btfss		PORTC,5     ;Wait until data is available from the keypad
         goto		spin_2
		 bcf	PORTA, 4
		 call Delay_2yea
		 goto	Delay_1_1_1
camel_2
		 movlw H'01'
		 subwf chipsDispensed, F
		 subwf checkDone, F
		 subwf camelChipCount, F
         return

dispensing_chips_complete_check
		 movlw H'00'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
	     goto dispensing_chips_complete_1
		 movlw H'01'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
	     goto dispensing_chips_complete_2


Closing_Containers
		 call	Delay_1
		 call	Delay_1
		 ;bsf	PORTA, 2
		 call	Delay_1
		 ;bcf	PORTA, 2
		 call	Delay_1
		 bsf	PORTA, 3
		 call	Delay_1
		 bcf	PORTA, 3
		 call Delay_1
		 goto closing_containers_check
closing_containers_check
		 movlw H'01'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
;	     goto closing_containers_complete_2
		 movlw H'02'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
;	     goto closing_containers_complete_3

;Removing_Containers
;		 call	Delay_2yea
;		 goto PWM_Mod_Rem
;PWM_Mod_Rem_Donnne
;		 bsf	PORTA, 4
;		 call	Delay_2yea
;		 bcf	PORTA, 4
;		 call Delay_2yea
;		 goto removing_containers_check
;removing_containers_check
;		 movlw H'02'
 ;	     xorwf operationCount, w
;		 btfsc STATUS, Z
;	     goto removing_containers_complete_3
;		 movlw H'03'
 ;	     xorwf operationCount, w
;		 btfsc STATUS, Z
;	     goto removing_containers_complete_4

Cycling_Containers
		 call	Delay_1
		 call	Delay_1
hello_world
		 bsf		PORTA,5
		 btfsc		PORTC,7     ;Wait until key is released
         goto		hello_world

spin_3
		 btfss		PORTC,7     ;Wait until data is available from the keypad
         goto		spin_3
		 bcf	PORTA, 5
		 call Delay_2yea
		 call	Delay_1
		 call	Delay_1
		 movlw H'01'
		 addwf operationCount, F
		 goto cycling_containers_check
cycling_containers_check
		 movlw H'01'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
	     goto cycling_containers_complete_1
		 movlw H'02'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
	     goto cycling_containers_complete_2
		 movlw H'03'
 	     xorwf operationCount, w
		 btfsc STATUS, Z
	     goto cycling_containers_complete_3

Display_Information

		 movlw	   H'00'
		 movwf	   EEADRH
		 movf     runnum,w
		 movwf	   EEADR
		 movf	   pack_one,w
		 movwf     EEDATA
		 bcf	   EECON1, EEPGD
		 bcf	   EECON1, CFGS
		 bsf	   EECON1, WREN
		 bcf	   INTCON, GIE
		 movlw	   55h
		 movwf	   EECON2
		 movlw	   0xAA
		 movwf	   EECON2
		 bsf	   EECON1, WR
		 bcf	   EECON1, WREN

		 movlw     H'01'
		 addwf     runnum, F

		 nop
		 btfsc EECON1, WR
         bra $-2

		 movlw	   H'00'
		 movwf	   EEADRH
		 movf     runnum,w
		 movwf	   EEADR
		 movf	   pack_two,w
		 movwf     EEDATA
		 bcf	   EECON1, EEPGD
		 bcf	   EECON1, CFGS
		 bsf	   EECON1, WREN
		 movlw	   55h
		 movwf	   EECON2
		 movlw	   0xAA
		 movwf	   EECON2
		 bsf	   EECON1, WR
		 bcf	   EECON1, WREN

		 nop
		 btfsc EECON1, WR
         bra $-2
		 movlw	   H'01'
		 movwf	   EEADRH
		 movlw      H'00'
		 movwf	   EEADR
		 movf	   runnum,w
		 movwf     EEDATA
		 bcf	   EECON1, EEPGD
		 bcf	   EECON1, CFGS
		 bsf	   EECON1, WREN
		 movlw	   55h
		 movwf	   EECON2
		 movlw	   0xAA
		 movwf	   EECON2
		 bsf	   EECON1, WR
		 bcf	   EECON1, WREN

		 call 	   Clear_Display ;pack one
  		 call  	   Compla
		 call Delay_2yea
		 call Delay_2yea
		 call Delay_2yea
		 call Delay_2yea
display_postwrite

		 call 	   Clear_Display ;pack one
  		 call  	   Input_Prompt_2

		 movlw     H'00'
         movwf     selected

display_info_loop
	     btfss		PORTB,1     ;Wait until data is available from the keypad
         goto		display_info_loop

         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
		 movwf      pack_temp
         goto       display_determine      ;Write the value in W to LCD
display_loop_info_end
         btfsc		PORTB,1     ;Wait until key is released
         goto		display_loop_info_end
         goto       display_info_loop
display_determine
		movlw H'00'
 		xorwf pack_temp, w
		btfsc STATUS, Z
		goto display_count

		movlw H'01'
 		xorwf pack_temp, w
		btfsc STATUS, Z
		goto display_op_time

		movlw H'02'
 		xorwf pack_temp, w
		btfsc STATUS, Z
		goto display_pattern

		movlw H'04'
 		xorwf pack_temp, w
		btfsc STATUS, Z
		goto display_logs

		movlw H'03'
 		xorwf pack_temp, w
		btfsc STATUS, Z
		goto display_return

		movlw H'07'
 		xorwf pack_temp, w
		btfsc STATUS, Z
		goto display_restart
		goto display_info_loop
display_logs
		movff  runnum, curmem
display_again
		movlw H'00'
 		xorwf curmem, w
		btfsc STATUS, Z
		goto display_postwrite

		movlw   H'00'
		movwf	EEADRH
		movf	curmem, w
		movwf	EEADR
		bcf		EECON1, EEPGD
		bcf		EECON1, CFGS
		bsf		EECON1, RD
		movf	EEDATA, w
		movwf	pack_two

	;	movlw H'01'
 	;	xorwf pack_two, w
	;	btfsc STATUS, Z
	;	goto yolo
	;	goto notyolo
;yolo
;		;call 		Clear_Display
;		call		Num_1
;		goto yolo
;notyolo
		;call 		Clear_Display
;		call		Num_2
;		goto notyolo


		movlw  H'01'
		subwf  curmem

		movlw   H'00'
		movwf	EEADRH
		movf	curmem, w
		movwf	EEADR
		bcf		EECON1, EEPGD
		bcf		EECON1, CFGS
		bsf		EECON1, RD
		movf	EEDATA, w
		movwf	pack_one

		call 		Clear_Display
		call		Num_1

		movlw H'00'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_1

		movlw H'01'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_2

		movlw H'02'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_3

		movlw H'04'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_4

		movlw H'05'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_5

		movlw H'06'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_6

		call		Num_2

		movlw H'00'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_1

		movlw H'01'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_2

		movlw H'02'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_3

		movlw H'04'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_4

		movlw H'05'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_5

		movlw H'06'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_6
display_info_loop_1
	     btfss		PORTB,1     ;Wait until data is available from the keypad
         goto		display_info_loop_1

         swapf		PORTB,W     ;Read PortB<7:4> into W<3:0>
         andlw		0x0F
		 movwf      pack_temp

display_loop_info_end_11
         btfsc		PORTB,1     ;Wait until key is released
         goto		display_loop_info_end_11
         goto       display_log_det
display_log_det
		movlw H'03'
 		xorwf pack_temp, w
		btfsc STATUS, Z
		goto display_again_mod

		movlw H'07'
 		xorwf pack_temp, w
		btfsc STATUS, Z
		goto display_postwrite
display_again_mod
		movlw  H'01'
		subwf  curmem
		goto display_again
display_op_time
		call 		Clear_Display
		call  	DD_Op_Time
		;call  	Pattern_2
		goto display_loop_info_end
display_count
		call 		Clear_Display

		call  DD_Amber_Chip
		movlw H'00'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_0
		movlw H'01'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_1
		movlw H'02'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_2
		movlw H'03'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_3
		movlw H'04'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_4
		movlw H'05'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_5
		movlw H'06'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_6
		movlw H'07'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_7
		movlw H'08'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_8
		movlw H'09'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_9
		movlw H'0A'
 	    xorwf amberChipCount, w
		btfsc STATUS, Z
	    call DD_10

		call  DD_Camel_Chip
		movlw H'00'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_0
		movlw H'01'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_1
		movlw H'02'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_2
		movlw H'03'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_3
		movlw H'04'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_4
		movlw H'05'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_5
		movlw H'06'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_6
		movlw H'07'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_7
		movlw H'08'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_8
		movlw H'09'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_9
		movlw H'0A'
 	    xorwf camelChipCount, w
		btfsc STATUS, Z
	    call DD_10

		goto display_loop_info_end
display_pattern
		call 		Clear_Display
		call		Num_1

		movlw H'00'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_1

		movlw H'01'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_2

		movlw H'02'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_3

		movlw H'04'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_4

		movlw H'05'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_5

		movlw H'06'
 	    xorwf pack_one, w
		btfsc STATUS, Z
	    call Pat_6

		call		Num_2

		movlw H'00'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_1

		movlw H'01'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_2

		movlw H'02'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_3

		movlw H'04'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_4

		movlw H'05'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_5

		movlw H'06'
 	    xorwf pack_two, w
		btfsc STATUS, Z
	    call Pat_6

		goto display_loop_info_end
display_return
		goto play
display_restart
		goto Display_Information
;***************************************
; Useful Operations
;***************************************
;Divide ;FIND A WAY TO ROUND PROPERLY
;		movlw     H'00'
;		movwf     divisionCount
;divide_loop
;		movf	  divideBy, w
;		subwf	  toDivide, F
 ;       movf 	  toDivide, w
  ;      bn        check_which_chip_count
;		movlw  	  H'01'
;		addwf     divisionCount, F
;		goto 	  divide_loop
;check_which_chip_count
;		movf 	  camelChipCount
;		bz		  amber_divided
;		goto 	  camel_divided

KPHexToChar
          addwf     PCL,f
          dt        "123A456B789C*0#D"

Divide_Dispense ;FIND A WAY TO ROUND PROPERLY
		movlw     H'00'
		movwf     divisionCount
divide_loop
		movf	  divideBy, w
		movff	  toDivide, divTemp
		subwf	  toDivide, F
        ;movf 	  toDivide, w
		movlw H'00'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		movlw H'01'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		movlw H'02'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		movlw H'03'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		movlw H'04'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		movlw H'05'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		movlw H'06'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		movlw H'07'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		movlw H'08'
 	    xorwf toDivide, w
		btfsc STATUS, Z
	    goto divide_increment
		return
divide_increment
		movlw  	  H'01'
		addwf     divisionCount, F
		goto 	  divide_loop
;***************************************
; LCD control
;***************************************

Switch_Lines
		movlw	B'11000000'
		call	WR_INS
		return

Clear_Display
		movlw	B'00000001'
		call	WR_INS
		return

;***************************************
; Delay 0.5s
;***************************************
HalfS
	local	HalfS_0
      movlw 0x88
      movwf COUNTH
      movlw 0xBD
      movwf COUNTM
      movlw 0x03
      movwf COUNTL

HalfS_0
      decfsz COUNTH, f
      goto   hal_s_1
      decfsz COUNTM, f
      goto   hal_s_2
hal_s_1
	  decfsz COUNTL, f
      goto   HalfS_0
hal_s_2
      goto hal_s_3
      nop
hal_s_3
      nop
		return
;******* LCD-related subroutines ******
    ;***********************************
InitLCD
	movlb 	   b'0000'
	bsf E     ;E default high

	;Wait for LCD POR to finish (~15ms)
	call lcdLongDelay
	call lcdLongDelay
	call lcdLongDelay

	;Ensure 8-bit mode first (no way to immediately guarantee 4-bit mode)
	; -> Send b'0011' 3 times
	movlw	b'00110011'
	call	WR_INS
	movlw	b'00110010'
	call	WR_INS



	; 4 bits, 2 lines, 5x7 dots
	movlw	b'00101000'
	call	WR_INS

	; display on/off
	movlw	b'00001100'
	call	WR_INS

	; Entry mode
	movlw	b'00000110'
	call	WR_INS

	; Clear ram
	movlw	b'00000001'
	call	WR_INS
	return
    ;************************************

    ;ClrLCD: Clear the LCD display
ClrLCD
	movlw	B'00000001'
	call	WR_INS
	call    lcdLongDelay
    return

;ClkLCD
 ;   LCD_DELAY
  ;  bcf PORTD,E
  ;  LCD_DELAY   ; __    __
  ;  bsf PORTD,E ;   |__|
   ; return

WrtLCD
	movf pack_temp, w
	movwf lcd_number
	movlw H'00'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto One
	movlw H'01'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Two
	movlw H'02'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Three
	movlw H'04'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Four
	movlw H'05'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Five
	movlw H'06'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Six
	movlw H'03'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto A_one
	movlw H'07'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto C_Key
	goto nest

WrtLCDTwo
	movf pack_temp, w

	movwf lcd_number
	movlw H'00'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto One_p

	movlw H'01'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Two_p

	movlw H'02'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Three_p

	movlw H'04'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Four_p

	movlw H'05'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Five_p

	movlw H'06'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto Six_p

	movlw H'03'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto A_p

	movlw H'07'
 	xorwf lcd_number, w
	btfsc STATUS, Z
	goto C_Key_p
	goto nest

One_p
	call 		Clear_Display
	movff   lcd_number, pack_two
	call  	Pack_Two
	call  	Pattern_1
	goto nest
Two_p
	call 		Clear_Display
	movff   lcd_number, pack_two
	call  	Pack_Two
	call  	Pattern_2
	goto nest
Three_p
	call 		Clear_Display
	movff   lcd_number, pack_two
	call  	Pack_Two
	call  	Pattern_3
	goto nest
Four_p
	call 		Clear_Display
	movff   lcd_number, pack_two
	call  	Pack_Two
	call  	Pattern_4
	goto nest
Five_p
	call 		Clear_Display
	movff   lcd_number, pack_two
	call  	Pack_Two
	call  	Pattern_5
	goto nest
Six_p
	call 		Clear_Display
	movff   lcd_number, pack_two
	call  	Pack_Two
	call  	Pattern_6
	goto nest
A_p
	call 		Clear_Display
	call  	Start_Op
	goto init_complete

C_Key_p
	movlw  H'01'
	subwf  selected
	call 		Clear_Display
	call  	Input_Prompt_1
	goto nest

One
	call 		Clear_Display
	movff   lcd_number, pack_one
	call  	Pack_One
	call  	Pattern_1
	goto nest
Two
	call 		Clear_Display
	movff   lcd_number, pack_one
	call  	Pack_One
	call  	Pattern_2
	goto nest
Three
	call 		Clear_Display
	movff   lcd_number, pack_one
	call  	Pack_One
	call 	Pattern_3
	goto nest
Four
	call 		Clear_Display
	movff   lcd_number, pack_one
	call  	Pack_One
	call  	Pattern_4
	goto nest
Five
	call 		Clear_Display
	movff   lcd_number, pack_one
	call  	Pack_One
	call  	Pattern_5
	goto nest
Six
	call 		Clear_Display
	movff   lcd_number, pack_one
	call 	Pack_One
	call  	Pattern_6
	goto nest
A_one
	movlw  H'01'
	addwf  selected, F
	call 		Clear_Display
	call  	Input_Prompt_1
	goto nest
C_Key
	call 		Clear_Display
	call  	Input_Prompt_1
	goto    nest

    ;****************************************
    ; Write command to LCD - Input : W , output : -
    ;****************************************
WR_INS
	bcf		RS				;clear RS
	movwf	com				;W --> com
	andlw	0xF0			;mask 4 bits MSB w = X0
	movwf	PORTD			;Send 4 bits MSB
	bsf		E				;
	call	lcdLongDelay	;__    __
	bcf		E				;  |__|
	swapf	com,w
	andlw	0xF0			;1111 0010
	movwf	PORTD			;send 4 bits LSB
	bsf		E				;
	call	lcdLongDelay	;__    __
	bcf		E				;  |__|
	call	lcdLongDelay
	return

i2c_common_setup
;input:		none
;output:	none
;desc:		sets up I2C as master device with 100kHz baud rate
	banksel		SSPSTAT
    clrf        SSPSTAT         ;I2C line levels, and clear all flags
    movlw       d'24'         	;100kHz baud rate: 10MHz osc / [4*(24+1)]
	banksel		SSPADD
    movwf       SSPADD          ;RTC only supports 100kHz

    movlw       b'00001000'     ;Config SSP for Master Mode I2C
	banksel		SSPCON1
    movwf       SSPCON1
    bsf         SSPCON1,SSPEN    ;Enable SSP module
    i2c_common_stop        		;Ensure the bus is free
	return
;rtc Algorithms;;;;;;

write_rtc
;input:		address of register in RTC
;output:	none
;Desc:		handles writing data to RTC
        ;Select the DS1307 on the bus, in WRITE mode
        i2c_common_start
        movlw       0xD0        ;DS1307 address | WRITE bit
        i2c_common_write
        i2c_common_check_ack   WR_ERR

        ;Write data to I2C bus (Register Address in RTC)
		banksel		0x73
        movf        0x73,w       ;Set register pointer in RTC
        i2c_common_write
        i2c_common_check_ack   WR_ERR

        ;Write data to I2C bus (Data to be placed in RTC register)
		banksel		0x74
        movf        0x74,w       ;Write data to register in RTC
        i2c_common_write
        i2c_common_check_ack   WR_ERR
        goto        WR_END
WR_ERR
        nop
WR_END
		i2c_common_stop	;Release the I2C bus
        return

read_rtc
;input:		address of RTC
;output:	DOUT or 0x75
;Desc:		This reads from the selected address of the RTC
;			and saves it into DOUT or address 0x75
        ;Select the DS1307 on the bus, in WRITE mode
        i2c_common_start
        movlw       0xD0        ;DS1307 address | WRITE bit
        i2c_common_write
        i2c_common_check_ack   RD_ERR

        ;Write data to I2C bus (Register Address in RTC)
		banksel		0x73
        movf        0x73,w       ;Set register pointer in RTC
        i2c_common_write
        i2c_common_check_ack   RD_ERR

        ;Re-Select the DS1307 on the bus, in READ mode
        i2c_common_repeatedstart
        movlw       0xD1        ;DS1307 address | READ bit
        i2c_common_write
        i2c_common_check_ack   RD_ERR

        ;Read data from I2C bus (Contents of Register in RTC)
        i2c_common_read
		banksel		0x75
        movwf       0x75
        i2c_common_nack      ;Send acknowledgement of data reception

        goto        RD_END

RD_ERR
        nop

        ;Release the I2C bus
RD_END  i2c_common_stop
        return

rtc_convert
;input:		W
;output:	dig10 (0x77), dig1 (0x78)
;desc:		This subroutine converts the binary number
;			in W into a two digit ASCII number and place
;			each digit into the corresponding registers
;			dig10 or dig1
	banksel	0x76
	movwf   0x76             ; B1 = HHHH LLLL
    swapf   0x76,w           ; W  = LLLL HHHH
    andlw   0x0f           ; Mask upper four bits 0000 HHHH
    addlw   0x30           ; convert to ASCII
    movwf	0x77		   ;saves into 10ths digit

	banksel	0x76
    movf    0x76,w
    andlw   0x0f           ; w  = 0000 LLLL
    addlw   0x30           ; convert to ASCII
    movwf	0x78	       ; saves into 1s digit
   	return

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
		movf	dig10, w
		call	WR_DATA
		movf	dig1, w
		call	WR_DATA

		movlw	"/"
		call	WR_DATA

		;Get month
		rtc_read	0x05		;Read Address 0x05 from DS1307---month
		movf	dig10, w
		call	WR_DATA
		movf	dig1, w
		call	WR_DATA

		movlw	"/"
		call	WR_DATA

		;Get day
		rtc_read	0x04		;Read Address 0x04 from DS1307---day
		movf	dig10, w
		call	WR_DATA
		movf	dig1, w
		call	WR_DATA

		movlw	B'11000000'		;Next line displays (hour):(min):(sec) **:**:**
		call	WR_INS

		;Get hour
		rtc_read	0x02		;Read Address 0x02 from DS1307---hour
		movf	dig10, w
		call	WR_DATA
		movf	dig1, w
		call	WR_DATA
		movlw			":"
		call	WR_DATA

		;Get minute
		rtc_read	0x01		;Read Address 0x01 from DS1307---min
		movf	dig10, w
		call	WR_DATA
		movf	dig1, w
		call	WR_DATA
		movlw			":"
		call	WR_DATA

		;Get seconds
		rtc_read	0x00		;Read Address 0x00 from DS1307---seconds
		movf	dig10, w
		call	WR_DATA
		movf	dig1, w
		call	WR_DATA

		call	Delay_10_rtc			;Delay for exactly one seconds and read DS1307 again
         btfss		PORTB,1     ;Wait until data is available from the keypad
         goto		show_RTC
rrel     btfsc		PORTB,1     ;Wait until key is released
         goto		rrel
		 goto	rdone

;***************************************
; Setup RTC with time defined by user
;***************************************
set_rtc_time

		rtc_resetAll	;reset rtc

		rtc_set	0x00,	B'10000000'

		;set time
		rtc_set	0x06,	B'00010011'		; Year
		rtc_set	0x05,	B'00000100'		; Month
		rtc_set	0x04,	B'00001001'		; Date
		rtc_set	0x03,	B'00000000'		; Day
		rtc_set	0x02,	B'00000010'		; Hours
		rtc_set	0x01,	B'00110101'		; Minutes
		rtc_set	0x00,	B'00000000'		; Seconds
		return

    ;****************************************
    ; Write data to LCD - Input : W , output : -
    ;****************************************
WR_DATA
	bsf		RS
	movwf	dat
	movf	dat,w
	andlw	0xF0
	addlw	4
	movwf	PORTD
	bsf		E				;
	call	lcdLongDelay	;__    __
	bcf		E				;  |__|
	swapf	dat,w
	andlw	0xF0
	addlw	4
	movwf	PORTD
	bsf		E				;
	call	lcdLongDelay	;__    __
	bcf		E				;  |__|
	return

MovMSB
    andlw 0xF0
    iorwf PORTD,f
    iorlw 0x0F
    andwf PORTD,f
    return


    ;Delay: ~5ms
lcdLongDelay
    movlw d'20'
    movwf lcd_d2


LLD_LOOP
    LCD_DELAY
    decfsz lcd_d2,f
    goto LLD_LOOP
    return

Delay_55555
	movlw	0x86
	movwf	d1
	movlw	0xA3
	movwf	d2
	movlw	0x02
	movwf	d3
Delay_555551
			decfsz	d1, f
			goto	delay_555552
			decfsz	d2, f
delay_555552	goto	delay_555553
			decfsz	d3, f
delay_555553	goto	Delay_555551

		;	goto	delay_555554
;delay_555554	goto	delay_555555
;delay_555555	goto delay_555556
;delay_555556
			 return

Delay_10
	movlw	0xE3
	movwf	d1
	movlw	0x7F
	movwf	d2
	movlw	0x37
	movwf	d3
Delay_0
			decfsz	d1, f
			goto	delay_01
			decfsz	d2, f
delay_01	goto	delay_02
			decfsz	d3, f
delay_02	goto	Delay_0

			goto	delay_03
delay_03	goto	delay_04
delay_04	goto	delay_05
delay_05    return

;Delay_1_0_0 ;0.36
;	movlw	0x8A
;	movwf	d1
;	movlw	0xBA
;	movwf	d2
;	movlw	0x03
;	movwf	d3
;Delay_1212
;			decfsz	d1, f
;			goto	delay_11
;			decfsz	d2, f
;;delay_11	goto	delay_12
;			decfsz  d3, f
;;delay_12	goto	Delay_1212
;
;;			goto	delay_13
;;delay_13	goto	delay_14
;;delay_14    nop
;			goto delay_13
;;delay_13;	goto delay_14
;;delay_14
;;goto amber_1

Delay_1_0_1
	movlw	0xA1
	movwf	d1
	movlw	0x2D
	movwf	d2
	movlw	0x09
	movwf	d3
Delay_2
			decfsz	d1, f
			goto	delay_21
			decfsz	d2, f
delay_21	goto	delay_22
			decfsz  d3, f
delay_22	goto	Delay_2

		    goto	delay_23
delay_23	goto	delay_24
delay_24 	nop
		    goto amber_2

;Delay_1_1_0
;	movlw	0xC5
;	movwf	d1
;	movlw	0x5D
;	movwf	d2
;	movlw	0x02
;	movwf	d3
;Delay_3
;			decfsz	d1, f
;			goto	delay_31
;			decfsz	d2, f
;delay_31	goto	delay_32
;			decfsz  d3, f
;delay_32	goto	Delay_3
;
;			goto	delay_33
;delay_33	goto camel_1

Delay_1_1_1
	movlw	0xA1
	movwf	d1
	movlw	0x2D
	movwf	d2
	movlw	0x09
	movwf	d3
Delay_4
			decfsz	d1, f
			goto	delay_41
			decfsz	d2, f
delay_41	goto	delay_42
			decfsz  d3, f
delay_42	goto	Delay_4

			goto	delay_43
delay_43	goto	delay_44
delay_44 	nop
		    goto camel_2



Delay_1
	movlw	0x87
	movwf	d1
	movlw	0x14
	movwf	d2
Delay_111
			decfsz	d1, f
			goto	delay_11111
			decfsz	d2, f
delay_11111	;goto	delay_11112
			;decfsz	d3, f
;delay_11112
			goto	Delay_111
			goto asshat
asshat	    return

Delay_2yea
	movlw	0x16
	movwf	d1
	movlw	0x74
	movwf	d2
	movlw	0x06
	movwf	d3
Delay_1111
			decfsz	d1, f
			goto	delay_111112
			decfsz	d2, f
delay_111112	goto	delay_111123
			decfsz	d3, f
delay_111123	goto	Delay_1111

		;	nop
		    return
Delay_10_rtc
	movlw	0x16
	movwf	d1
	movlw	0x74
	movwf	d2
	movlw	0x06
	movwf	d3
Delay_0_rtc
			decfsz	d1, f
			goto	delay_01_rtc
			decfsz	d2, f
delay_01_rtc	goto	delay_02_rtc
			decfsz	d3, f
delay_02_rtc	goto	Delay_0_rtc

			nop
		    return

Delay_stop
	movlw	0x4F
	movwf	d1
	movlw	0xC4
	movwf	d2
Delay_1111_st
			decfsz	d1, f
			goto	delay_111112_st
			decfsz	d2, f
delay_111112_st	goto	delay_111123_st
			decfsz	d3, f
delay_111123_st	goto	Delay_1111_st

			goto asshat_2
asshat_2		return
;**************************
; Amber PWM Code
;**************************

;PWM_Mod_Amber
;	movlw   b'00001111'
;	movwf   counter_PWM
;PWM_Mod_Loop
;	bsf PORTA, 0
;	goto Delay_PWM_Amber
;amber_delay_finished
;	bcf PORTA, 0
;	goto Delay_PWM_Amber_1
;amber_delay_finished_1
;	movlw b'00000001'
;	subwf counter_PWM, F
;	movlw b'00000000'
; 	xorwf counter_PWM, w
;	btfsc STATUS, Z
;	goto end_PWM
;	goto PWM_Mod_Loop
;end_PWM
;	goto PWM_Mod_Amber_Donnne
;
;0.002
;Delay_PWM_Amber
;	movlw	0x0F
;	movwf	d1
;	movlw	0x28
;	movwf	d2
;Delay_PWM_1
;			decfsz	d1, f
;			goto	delay_PWM_11
;			decfsz	d2, f
;delay_PWM_11	goto	Delay_PWM_1
;			goto delay_PWM_12
;delay_PWM_12	    goto amber_delay_finished
;
;Delay_PWM_Amber_1
;	movlw	0x0F
;	movwf	d1
;	movlw	0x28
;	movwf	d2
;Delay_PWM_1_1
;			decfsz	d1, f
;			goto	delay_PWM_11_1
;			decfsz	d2, f
;delay_PWM_11_1	goto	Delay_PWM_1_1
;			goto delay_PWM_12_1
;delay_PWM_12_1	    goto amber_delay_finished_1

;**************************
; Camel PWM Code
;**************************


;PWM_Mod_Camel
;	movlw   b'00001010'
;	movwf   counter_PWM
;PWM_Mod_Loop_C
;	bsf PORTA, 1
;	goto Delay_PWM_Camel
;camel_delay_finished
;	bcf PORTA, 1
;	goto Delay_PWM_Camel_1
;camel_delay_finished_1
;	movlw b'00000001'
;	subwf counter_PWM, F
;	movlw b'00000000'
 ;	xorwf counter_PWM, w
;	btfsc STATUS, Z
;	goto end_PWM_C
;	goto PWM_Mod_Loop_C
;end_PWM_C
;	goto PWM_Mod_Camel_Donnne

;0.002
;Delay_PWM_Camel
;	movlw	0x0F
;	movwf	d1
;	movlw	0x28
;	movwf	d2
;Delay_PWM_1_C
;			decfsz	d1, f
;			goto	delay_PWM_11_C
;			decfsz	d2, f
;delay_PWM_11_C	goto	Delay_PWM_1_C
;			goto delay_PWM_12_C
;delay_PWM_12_C	    goto camel_delay_finished
;
;Delay_PWM_Camel_1
;	movlw	0x0F
;	movwf	d1
;	movlw	0x28
;	movwf	d2
;Delay_PWM_1_1_C
;			decfsz	d1, f
;			goto	delay_PWM_11_1_C
;			decfsz	d2, f
;delay_PWM_11_1_C	goto	Delay_PWM_1_1_C
;			goto delay_PWM_12_1_C
;delay_PWM_12_1_C	    goto camel_delay_finished_1

;**************************
; Removing PWM Code
;**************************
;PWM_Mod_Rem
;	movlw   b'00001010'
;	movwf   counter_PWM
;PWM_Mod_Loop_R
;	bsf PORTA, 1
;	goto Delay_PWM_Rem
;rem_delay_finished
;	bcf PORTA, 1
;	goto Delay_PWM_Rem_1
;rem_delay_finished_1
;	movlw b'00000001'
;	subwf counter_PWM, F
;	movlw b'00000000'
 ;	xorwf counter_PWM, w
;	btfsc STATUS, Z
;	goto end_PWM_R
;	goto PWM_Mod_Loop_R
;end_PWM_R
;	goto PWM_Mod_Rem_Donnne

;0.002
Delay_PWM_Rem
	movlw	0x4F
	movwf	d1
	movlw	0xC4
	movwf	d2
Delay_PWM_1_R
			decfsz	d1, f
			goto	delay_PWM_11_R
			decfsz	d2, f
delay_PWM_11_R	goto	Delay_PWM_1_R
			goto delay_PWM_12_R
delay_PWM_12_R	    return

Delay_PWM_Rem_1
	movlw	0x03
	movwf	d1
	movlw	0x18
	movwf	d2
	movlw	0x02
	movwf	d3
Delay_PWM_1_1_R
			decfsz	d1, f
			goto	delay_PWM_11_1_R
			decfsz	d2, f
delay_PWM_11_1_R	goto	Delay_PWM_1_1_R
			goto delay_PWM_12_1_R
delay_PWM_12_1_R goto delay_PWM_13_1_R
delay_PWM_13_1_R goto delay_PWM_14_1_R
delay_PWM_14_1_R	    return



	END
