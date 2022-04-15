LIST	P=16F88
#include "p16f88.inc"
#include "Macros.inc"

 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BODEN_OFF & _LVP_OFF
 __CONFIG _CONFIG2, _IESO_OFF  & _FCMEN_OFF & _CCP1_RB0 

;s4 s3 s2 s1
;0  0  0  1   func normal

;1  1  1  1  todos activados

_1 			equ 0x10
_2 			equ 0x20
_3 			equ 0x40
_4 			equ 0x80
_1_3 		equ 0x50
_1_4 		equ 0x90
_1_3_4		equ 0xD0
_1_2_3_4 	equ 0xF0
none  		equ 0x00


CBLOCK 0x20
    temp,mask,C1,C2,CUENTA
ENDC

ORG  0X00
GOTO  INICIO 
ORG  0X05   
    
INICIO

BANKSEL ANSEL
	CLRF ANSEL

BANKSEL T2CON
	LOAD T2CON,0x07 ; pre =16, tmr2 on 
	LOAD CCP1CON,0x3F ; <4:5> 2 bits dc , <3:0> pwm mode
	LOAD CCPR1L,0x00
BANKSEL PR2
	LOAD PR2,0x3E  		; 4Mhz

BANKSEL TRISA
	LOAD TRISA,0x00 
	LOAD TRISB,0xF0 

BANKSEL PORTA
	CLRF PORTB
	CLRF PORTB

Call InitLineFollower
  
Bucle
movf PORTB,0 
andlw 0xF0
movwf temp

_1_Caso
movlw _1
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO _2_Caso 

	Call Defrente
	GOTO Bucle

_2_Caso
movlw _2
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO _3_Caso
	
	Call Izquierda
	GOTO Bucle

_3_Caso	
movlw _3
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO _4_Caso
	
	Call Izquierda
	GOTO Bucle

_4_Caso	
movlw _4
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO _1_3_4_Caso
	
	Call Derecha
	GOTO Bucle

_1_3_4_Caso ; Defrente
movlw _1_3_4
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO _1_3_Caso

	Call Defrente
	GOTO Bucle

_1_3_Caso ;dont care s2
bcf STATUS,Z
movf temp,0
movwf mask
movlw 0xDF
andwf mask
movlw _1_3
xorwf mask,0
btfss STATUS,Z
GOTO _1_4_Caso  

	Call Izquierda
	GOTO Bucle

_1_4_Caso ;dont care s2
bcf STATUS,Z
movf temp,0
movwf mask
movlw 0xDF
andwf mask
movlw _1_4
xorwf mask,0
btfss STATUS,Z
GOTO _1_2_3_4_Caso

	Call Derecha
	GOTO Bucle

_1_2_3_4_Caso
movlw _1_2_3_4
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO Detener_Caso
	
	Call Parar
	GOTO Bucle

Detener_Caso
movlw none
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO Bucle
	Call Parar
GOTO Bucle
 
;$$$$$$$$$$$$$$$$$SUbRoutineS$$$$$$$$$$$$$$$$$$$$$
InitLineFollower
	LOAD CCPR1L,0x1F
	LOAD PR2,0x3E
	movlw 0xF0	
	andwf PORTA 
return

Izquierda ;  1110
	
	bcf PORTA ,.0	
	bsf PORTA ,.1
	bsf PORTA ,.2
	bsf PORTA ,.3
return

Derecha;  1011

	bsf PORTA ,.0
	bsf PORTA ,.1
	bcf PORTA ,.2
	bsf PORTA ,.3
return

Defrente;  1010

	bcf PORTA ,.0
	bsf PORTA ,.1
	bcf PORTA ,.2
	bsf PORTA ,.3
return

Parar ;  1111
	movlw 0x0F
	iorwf PORTA
return


END


