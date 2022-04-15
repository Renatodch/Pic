LIST	P=16F88
#include "p16f88.inc"
#include "Macros.inc"

 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BODEN_OFF & _LVP_OFF

 __CONFIG _CONFIG2, _IESO_OFF  & _FCMEN_OFF
 
dogs 	     EQU .10  ; delay de multiplexado  CAMBIAR SI NO SALE
velocidad 	 EQU .10   ; delay de fotograma   minimo 2 SI QUERES
num_foto     EQU .16  ; define el numero de caract.  NUNCA CAMBIAR

CBLOCK 0x20
    C1,C2,CUENTA, i0,i1,i2,i3,delay,k,temp,ste
ENDC

ORG  0X00  
GOTO  INICIO 
ORG  0X05   
    
INICIO
; ###INICIALIZA PUERTOS Y VARIABLES#########
BANKSEL TRISA
LOAD TRISA,0x18 
CLRF TRISB

BANKSEL ANSEL
CLRF ANSEL

BANKSEL PORTA
CLRF PORTB
CLRF PORTA

clrf delay
clrf i0
clrf i1
clrf i2
clrf i3
clrf ste
;#####################    
Loop

LOAD PORTB,0xE0
Print i0
Delay dogs   

LOAD PORTB,0xD0
Print i1
Delay dogs  

LOAD PORTB,0xB0
Print i2
Delay dogs   

LOAD PORTB,0x70
Print i3
Delay dogs  

movf PORTA,0 ;UPAO
andlw 0x18
movwf temp
movlw 0x00
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO ELEC

bcf ste,0
LOAD i0,0x04
LOAD i1,0x03
LOAD i2,0x02
LOAD i3,0x01
goto Loop

ELEC		 ;ELEC
movf PORTA,0
andlw 0x18
movwf temp
movlw 0x08
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO _2018

bcf ste,0
LOAD i0,0x09
LOAD i1,0x08
LOAD i2,0x07
LOAD i3,0x06
goto Loop

_2018        ; 2018
movf PORTA,0
andlw 0x18
movwf temp
movlw 0x10
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO SHIFT

bcf ste,0
LOAD i0,0x0E
LOAD i0,0x0E
LOAD i0,0x0E
LOAD i0,0x0E
LOAD i1,0x0D
LOAD i2,0x0C
LOAD i3,0x0B
goto Loop

SHIFT         ; Shift UPAO_ELEC_2018
movf PORTA,0
movwf temp
movlw 0x18
andwf temp
movlw 0x18
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO Loop

btfsc ste,0
goto continue

clrf delay
clrf i0
clrf i1
clrf i2
clrf i3
bsf ste,0

continue

incf delay
movlw velocidad
bcf STATUS,Z
xorwf delay,0
btfss STATUS,Z
GOTO Loop
clrf delay

movf i2,0
movwf i3
movf i1,0
movwf i2
movf i0,0
movwf i1
incf i0

movlw num_foto 		;numero de fotogramas + 1
bcf STATUS,Z
xorwf i0,0
btfss STATUS,Z
GOTO Loop
clrf i0

GOTO Loop
 

msg 
addwf PCL,1
retlw 0x00 ;null
retlw 0x3E ;U
retlw 0x67 ;P
retlw 0x77 ;A
retlw 0x7E ;O
retlw 0x08 ;_
retlw 0x4F ;E
retlw 0x0E ;L
retlw 0x4F ;E
retlw 0x4E ;C
retlw 0x08 ;_
retlw 0x6D ;2
retlw 0x7E ;0
retlw 0x30 ;1
retlw 0x7F ;8
retlw 0x00 ;null

END

