LIST	P=16F886
#include "p16f886.inc"
#include "Macros.inc"

; __config 0xE0F1
 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 
#DEFINE SH PORTC,0
#DEFINE DS PORTC,1
dogs 	     EQU .16 ; delay de multiplexado
velocidad 	 EQU .5 ; delay de fotograma   minimo 2
num_foto     EQU .9 
#DEFINE ST PORTC,2

CBLOCK 0x20
    C1,C2,CUENTA,dato,bit, i0,i1,i2,i3,delay,k
ENDC

ORG  0X00  
GOTO  INICIO 
ORG  0X05   

    
INICIO
BANKSEL TRISA

CLRF TRISA 
CLRF TRISC
CLRF TRISB
BANKSEL ANSEL
CLRF ANSEL
CLRF ANSELH
BANKSEL PORTA
CLRF PORTC
CLRF PORTB
CLRF PORTA

clrf delay
clrf i0
clrf i1
clrf i2
clrf i3
    
BUCLE 

LOAD PORTB,0xE0
movf i0,0
call tabla1  
call Envia
movf i0,0
call tabla2  
call Envia
bcf ST
bsf ST
Delay dogs   

LOAD PORTB,0xD0
movf i1,0
call tabla1  
call Envia
movf i1,0
call tabla2  
call Envia
bcf ST
bsf ST
Delay dogs  

LOAD PORTB,0xB0
movf i2,0
call tabla1  
call Envia
movf i2,0
call tabla2  
call Envia
bcf ST
bsf ST
Delay dogs   

LOAD PORTB,0x70
movf i3,0
call tabla1  
call Envia
movf i3,0
call tabla2  
call Envia
bcf ST
bsf ST
Delay dogs  


incf delay
movlw velocidad
bcf STATUS,Z
xorwf delay,0
btfss STATUS,Z
GOTO BUCLE
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
GOTO BUCLE
clrf i0

GOTO BUCLE  

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

return  

tabla1 
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



tabla2
addwf PCL,1
retlw 0x00 ;NULL
retlw 0x39;C
retlw 0x38;L
retlw 0x37;A
retlw 0x3E;U
retlw 0x8F;D
retlw 0x89;I
retlw 0x3F;O
retlw 0x00;NULL
retlw 0x8F;D
retlw 0x39;E
retlw 0x38;L
retlw 0x00;NULL
retlw 0x39;C
retlw 0x37;A
retlw 0x2D;S
retlw 0x81;T
retlw 0x89;I
retlw 0x38;L
retlw 0x38;L
retlw 0x3F;O
retlw 0x00;NULL
retlw 0x00;NULL
retlw 0x00;NULL
retlw 0x00;NULL

retlw 0x0A ;B
retlw 0x8F ;B
retlw 0x26 ;R
retlw 0x33 ;R
retlw 0x04 ;N
retlw 0x76 ;N
retlw 0x22 ;P
retlw 0x33 ;P
retlw 0x00 ;_
retlw 0x08 ;_
retlw 0x01 ;M
retlw 0x76 ;M
retlw 0x02 ;G
retlw 0x3D ;G
retlw 0x11 ;Z
retlw 0x09 ;Z
retlw 0x22 ;H
retlw 0x36 ;H
retlw 0x00 ;J
retlw 0x1E ;J
tiempo 
movwf C1
LOAD C2,0xff    ; Iniciamos contador2 
decfsz C2,1    ; Decrementa Contador2 y si es 0 sale.-     
goto $-1       ; Si no es 0 repetimos ciclo.- 
decfsz C1,1    ; Decrementa Contador1.- 
goto $-4    ; Si no es cero repetimos ciclo.- 
return

END