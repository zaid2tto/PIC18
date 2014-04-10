#include <p18f4620.inc>
#include <delays32.inc>
#include <MainIntegrated1.inc>
#include <lcd18.inc>
code
global  summaryMenu


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
         goto       summaryMenu  ;

end