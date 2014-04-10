#include <p18f4620.inc>
#include <delays32.inc>


code
global  IRrelayOn, IRrelayOff, LDrelayOn, LDrelayOff
;Using RC5 to control IR relay, RC7 to control LD relay

IRrelayOn ;let RC5 control the IR relay
    bcf     TRISC,5 ;make it output
    call    delay5ms
    bsf     PORTC,5 ;turn it on
return

IRrelayOff
    bcf     TRISC,5
    call    delay5ms
    bcf     PORTC,5 ;turn it off

;*****************************************************************************

LDrelayOn ;let RC5 control the IR relay
    bcf     TRISC,7 ;make it output
    call    delay5ms
    bsf     PORTC,7 ;turn it on
return

LDrelayOff
    bcf     TRISC,7
    call    delay5ms
    bcf     PORTC,7 ;turn it off

return

end