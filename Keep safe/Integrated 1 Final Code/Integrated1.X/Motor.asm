#include <p18f4620.inc>
#include <delays32.inc>


code
global  MotorRight, MotorLeft


MotorLeft ;activate RD0
    bcf     TRISD,0
    ;sets the pin
    bsf     PORTD,0
    call    delay1s ;controls how long the motor operates
    
    bcf     PORTD,0
return

MotorRight;activate RD1
    
    bcf     TRISD,1         ;This works too
    ;clears any residual data
    bsf     PORTD,1
    call    delay1s ;controls how long the motor operates
    bcf     PORTD,1
return

END