#include <p18f4620.inc>
#include <delays32.inc>


code
global  MotorRight, MotorLeft


;    clrf      TRISA          ; All port A is output
;    clrf      TRISB		     ; All port B is output
;    clrf      TRISC          ; All port C is output



MotorRight ;activate RD0
    bcf     TRISD,0
    ;sets the pin
    bsf     PORTD,0
   ; call    delay3s ;waay tooo long
    call    delay100ms
    call    delay100ms
    bcf     PORTD,0
return


MotorLeft ;activate RD1 
    
    bcf     TRISD,1         ;This works too
    ;clears any residual data
    bsf     PORTD,1
    ;call    delay3s
    call    delay100ms
    call    delay100ms
    bcf     PORTD,1
return

loop
    btg     PORTD,1
    call    delay3s
    goto    loop


END