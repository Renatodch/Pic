LIST	P=16F88
#include "p16f88.inc"

__CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BODEN_OFF & _LVP_OFF

__CONFIG _CONFIG2, _IESO_OFF  & _FCMEN_OFF
    
ORG 0x00
GOTO main
ORG 0X04
GOTO Interrupt
ORG 0x05

main:
    
banksel TRISA
movlw 0x00
movwf TRISA
    
movlw 0x00
movwf TRISB

banksel ANSEL
clrf ANSEL   

banksel PORTA
movlw 0x01
movwf PORTA
    
movlw 0xFF
movwf PORTB
    
Interrupt:
    
END