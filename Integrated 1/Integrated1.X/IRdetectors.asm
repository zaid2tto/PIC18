#include <p18f4620.inc>
#include <delays32.inc>
#include <MainIntegrated1.inc>


code
global startIR




startIR
      
        ;As soon as I set them to inputs: they all turn on!
        ;clrf    PORTA
        movlw   b'00000010'
        movwf   TRISA
        
        
startTesting
;The IR circuit signals low when light is present; signals high when light is not present
        call    delay0.5s

        btfss   PORTA,1 ;if signal 1= absent skip next line
            goto setPresent
       ; bcf     IR1,0 ;absent light
        ;goto    A2

setPresent
      ;  bsf     IR1,0 ;present light
        ;goto    A2

;A2
;
;        ;clrf    PORTA
;        movlw   b'00000100'
;        movwf   TRISA
;        call    delay1s
;        btfss   PORTA,2
;            goto setPresent2
;        bcf     IR2,0
;        ;goto A3...
;setPresent2
;        bsf     IR2,0

return



END


