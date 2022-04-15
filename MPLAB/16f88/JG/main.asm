LIST	P=16F88
#include "p16f88.inc"
#include "Macros.inc"

 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BODEN_OFF & _LVP_OFF

 __CONFIG _CONFIG2, _IESO_OFF  & _FCMEN_OFF
 
#DEFINE SH PORTB,1
#DEFINE DS PORTB,2
#DEFINE ST PORTB,3

dogs 	     EQU .10  ; delay de multiplexado  CAMBIAR SI NO SALE
velocidad 	 EQU .10   ; delay de fotograma   minimo 2 SI QUERES
num_foto     EQU .25  ; define el numero de caract.  NUNCA CAMBIAR

CBLOCK 0x20
    C1,C2,CUENTA, i0,i1,i2,i3,delay,k,temp,dato,bit
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

;#####################    
Loop

LOAD PORTB,0xE0

movf i0,0

bcf PCLATH,1
bsf PCLATH,0
call LM_1  
bcf PCLATH,1
bcf PCLATH,0

call Envia
movf i0,0

bcf PCLATH,1
bsf PCLATH,0
call LM_2 
bcf PCLATH,1
bcf PCLATH,0

call Envia
bcf ST
bsf ST
Delay dogs   

LOAD PORTB,0xD0

movf i1,0
bcf PCLATH,1
bsf PCLATH,0
call LM_1  
bcf PCLATH,1
bcf PCLATH,0  
call Envia
movf i1,0
bcf PCLATH,1
bsf PCLATH,0
call LM_2 
bcf PCLATH,1
bcf PCLATH,0  
call Envia
bcf ST
bsf ST
Delay dogs  

LOAD PORTB,0xB0

movf i2,0
bcf PCLATH,1
bsf PCLATH,0
call LM_1  
bcf PCLATH,1
bcf PCLATH,0   
call Envia
movf i2,0
bcf PCLATH,1
bsf PCLATH,0
call LM_2  
bcf PCLATH,1
bcf PCLATH,0  
call Envia
bcf ST
bsf ST
Delay dogs   

LOAD PORTB,0x70

movf i3,0
bcf PCLATH,1
bsf PCLATH,0
call LM_1  
bcf PCLATH,1
bcf PCLATH,0 
call Envia
movf i3,0
bcf PCLATH,1
bsf PCLATH,0
call LM_2 
bcf PCLATH,1
bcf PCLATH,0  
call Envia
bcf ST
bsf ST
Delay dogs  


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

Envia
movwf dato
movlw d'8'      ; Número de bits a transmitir.
movwf bit
	
EnviaBit              ; Comienza a enviar datos.
btfss dato,7  ; ¿Es un "1" el bit a transmitir?
goto $+3
bsf DS    ; Si, Transmite un "1".
goto $+2
bcf DS    ; No, pues envía un "0".
bcf SH  ; Clock=0.
bsf SH  ; Clock=1.

rlf dato,1  ; Rota para envia siguiente bit.-
decfsz bit,1    ; Comprueba si es el último bit. 7,6,5,4,3,2,1,0
goto EnviaBit    ; No es el último bit repite la operación.     

tablaXX
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x00 ;L
retlw 0x22 ;A
retlw 0X00 ;U
retlw 0X08 ;D
retlw 0X08 ;I
retlw 0X00 ;O
retlw 0x00 ;NULL
retlw 0X08 ;D
retlw 0X22 ;E
retlw 0x00 ;L
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x22 ;A
retlw 0X22 ;S
retlw 0X08 ;T
retlw 0X08 ;I
retlw 0x00 ;L
retlw 0x00 ;L
retlw 0X00 ;O
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x00 ;L
retlw 0x22 ;A
retlw 0X00 ;U
retlw 0X08 ;D
retlw 0X08 ;I
retlw 0X00 ;O
retlw 0x00 ;NULL
retlw 0X08 ;D
retlw 0X22 ;E
retlw 0x00 ;L
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x22 ;A
retlw 0X22 ;S
retlw 0X08 ;T
retlw 0X08 ;I
retlw 0x00 ;L
retlw 0x00 ;L
retlw 0X00 ;O
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x00 ;L
retlw 0x22 ;A
retlw 0X00 ;U
retlw 0X08 ;D
retlw 0X08 ;I
retlw 0X00 ;O
retlw 0x00 ;NULL
retlw 0X08 ;D
retlw 0X22 ;E
retlw 0x00 ;L
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x22 ;A
retlw 0X22 ;S
retlw 0X08 ;T
retlw 0X08 ;I
retlw 0x00 ;L
retlw 0x00 ;L
retlw 0X00 ;O
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x00 ;L
retlw 0x22 ;A
retlw 0X00 ;U
retlw 0X08 ;D
retlw 0X08 ;I
retlw 0X00 ;O
retlw 0x00 ;NULL
retlw 0X08 ;D
retlw 0X22 ;E
retlw 0x00 ;L
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x22 ;A
retlw 0X22 ;S
retlw 0X08 ;T
retlw 0X08 ;I
retlw 0x00 ;L
retlw 0x00 ;L
retlw 0X00 ;O
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x00 ;L
retlw 0x22 ;A
retlw 0X00 ;U
retlw 0X08 ;D
retlw 0X08 ;I
retlw 0X00 ;O
retlw 0x00 ;NULL
retlw 0X08 ;D
retlw 0X22 ;E
retlw 0x00 ;L
retlw 0x00 ;NULL
retlw 0x00 ;C
retlw 0x22 ;A
retlw 0X22 ;S
retlw 0X08 ;T
retlw 0X08 ;I
retlw 0x00 ;L
retlw 0x00 ;L
retlw 0X00 ;O
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A
retlw 0x00 ;NULL 0x0A


ALBERT_BLANCO_1 
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x22 ;A
retlw 0x00 ;L
retlw 0x0A ;B
retlw 0X22 ;E
retlw 0x26 ;R
retlw 0X08 ;T
retlw 0x00 ;-
retlw 0X0A ;B
retlw 0x00 ;L
retlw 0x22 ;A
retlw 0x04 ;N
retlw 0x00 ;C
retlw 0x00 ;O
retlw 0X00 ;NULL

ALBERT_BLANCO_2
addwf PCL,1
retlw 0x00;NULL
retlw 0x37;A
retlw 0x38;L
retlw 0x8F;B
retlw 0x39;E
retlw 0x33;R
retlw 0x81;T
retlw 0x08;_
retlw 0x8F;B
retlw 0x38;L
retlw 0x37;A
retlw 0x76;N
retlw 0x39;C
retlw 0x3F;O
retlw 0x00;NULL

U_E_1
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x00 ;U
retlw 0x22 ;P
retlw 0x22 ;A
retlw 0X00 ;O
retlw 0x00 ;_
retlw 0X22 ;E
retlw 0x00 ;L
retlw 0X22 ;E
retlw 0x00 ;C
retlw 0x08 ;T
retlw 0x26 ;R
retlw 0x00 ;O
retlw 0x04 ;N
retlw 0x08 ;I
retlw 0x00 ;C
retlw 0x22 ;A
retlw 0X00 ;NULL

U_E_2
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x3E ;U
retlw 0x33 ;P
retlw 0x37 ;A
retlw 0X3F ;O
retlw 0x08 ;_
retlw 0X39 ;E
retlw 0x38 ;L
retlw 0X39 ;E
retlw 0x39 ;C
retlw 0x81 ;T
retlw 0x33 ;R
retlw 0x3F ;O
retlw 0x76 ;N
retlw 0x89 ;I
retlw 0x39 ;C
retlw 0x37 ;A
retlw 0X00 ;NULL

ED2_1 
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x22 ;E
retlw 0x00 ;L
retlw 0x22 ;E
retlw 0X00 ;C
retlw 0x08 ;T
retlw 0X26 ;R
retlw 0x00 ;O
retlw 0X04 ;N
retlw 0x08 ;I
retlw 0x00 ;C
retlw 0x22 ;A
retlw 0x00 ;_
retlw 0x08 ;D
retlw 0x08 ;I
retlw 0x02 ;G
retlw 0x08 ;I
retlw 0X08 ;T
retlw 0X22 ;A
retlw 0X00 ;L
retlw 0X00 ;_
retlw 0X08 ;I
retlw 0X08 ;I
retlw 0X00 ;NULL

ED2_2
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x39 ;E
retlw 0X38 ;L
retlw 0x39 ;E
retlw 0x39 ;C
retlw 0x81 ;T
retlw 0x33 ;R
retlw 0x3F ;O
retlw 0x76 ;N
retlw 0x89 ;I
retlw 0x39 ;C
retlw 0x37 ;A
retlw 0x08 ;_
retlw 0x8F ;D
retlw 0x89 ;I
retlw 0x3D ;G
retlw 0x89 ;I
retlw 0x81 ;T
retlw 0x37 ;A
retlw 0X38 ;L
retlw 0X08 ;_
retlw 0x89 ;I
retlw 0x89 ;I
retlw 0X00 ;NULL

LM_1 
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x00 ;L
retlw 0x00 ;U
retlw 0x08 ;I
retlw 0X22 ;S
retlw 0x00 ;_
retlw 0X01 ;M
retlw 0x00 ;O
retlw 0X26 ;R
retlw 0x22 ;E
retlw 0x04 ;N
retlw 0x00 ;O
retlw 0X00 ;NULL

LM_2
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x38 ;L
retlw 0x3E ;U
retlw 0x89 ;I
retlw 0X2D ;S
retlw 0x08 ;_
retlw 0X76 ;M
retlw 0x3F ;O
retlw 0X33 ;R
retlw 0x39 ;E
retlw 0x76 ;N
retlw 0x3F ;O
retlw 0X00 ;NULL


Jhon_1 
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x00 ;J
retlw 0x22 ;H
retlw 0x00 ;O
retlw 0X04 ;N
retlw 0x00 ;_
retlw 0X02 ;G
retlw 0x00 ;U
retlw 0X08 ;T
retlw 0x08 ;I
retlw 0x22 ;E
retlw 0x26 ;R
retlw 0x26 ;R
retlw 0X22 ;E
retlw 0x11 ;Z
retlw 0X00 ;NULL

Jhon_2
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x1E ;J
retlw 0x36 ;H
retlw 0x3F ;O
retlw 0X76 ;N
retlw 0x08 ;_
retlw 0X3D ;G
retlw 0x3E ;U
retlw 0X81 ;T
retlw 0x89 ;I
retlw 0x39 ;E
retlw 0x33 ;R
retlw 0x33 ;R
retlw 0X39 ;E
retlw 0x09 ;Z
retlw 0X00 ;NULL

END

