LIST	P=16F88
#include "p16f88.inc"
#include "Macros.inc"

 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BODEN_OFF & _LVP_OFF
 __CONFIG _CONFIG2, _IESO_OFF  & _FCMEN_OFF
 
#DEFINE SH PORTA,1
#DEFINE DS PORTA,0
#DEFINE ST PORTA,2

start_DIG_1 equ 0x00    ; .0
start_DIG_2 equ 0x0A 	; .10
start_DIG_3 equ 0x64 	; .100
start_DIG_4 equ 0x3E8	; .1000

Inc_DIG_1 equ 0x00	; .0
Inc_DIG_2 equ 0x06 	; .6
Inc_DIG_3 equ 0x9C 	; .156

Inc_DIG_4 equ 0xC18	; .3096
Inc_DIG_4_L equ 0x18	
Inc_DIG_4_H equ 0x0C	

CBLOCK 0x20
    C1,C2,CUENTA,dato,bit,ABC
ENDC
CBLOCK 0x40
	htemp,ltemp,Digi0,Digi1,Digi2,Digi3
ENDC
CBLOCK 0x60
	_U,_D,_C,_M,temp2,temp,val,Num_H,Num_L

ENDC

ORG  0X00  
GOTO  INICIO 
ORG  0x05  
    
INICIO

BANKSEL TRISA
LOAD TRISA,0x18 
LOAD TRISB,0xF8 

BANKSEL ANSEL
CLRF ANSEL

BANKSEL PORTA
CLRF PORTB
CLRF PORTA


Loop ;##################################### BUCLE ############################
	;sub_process
	;bcf PCLATH,1
	;bsf PCLATH,0

	clrf temp
	clrf ABC
;Leyendo nibble H
	movf PORTB,0
	andlw 0x38   ;0Y111000
	movwf temp
	bcf STATUS,C
	rrf temp
	rrf temp
	rrf temp
	movf temp,0
	movwf Num_H
	movf PORTB,0
	andlw 0x80 ;1Y000000
	movwf temp
	swapf temp
	movf temp,0
	xorwf Num_H	
	

;Leyendo nibble L

	movlw .8
	movwf ABC

READING_MUX

	decf ABC,1	


	movf ABC,0
	movwf PORTB
	Delay .1	
	btfss PORTB,6
	goto LOW_N	
	bsf Num_L,0
	goto _R
LOW_N
	bcf Num_L,0
_R

	movlw .0
	bcf STATUS,Z
	xorwf ABC,0
	btfss STATUS,Z
	goto rotate
	goto _Ci
rotate
	rlf Num_L
	goto READING_MUX
	
_Ci	;################################ Num_H  Num_L rdy#########################3
	movf Num_L,0
	movwf ltemp
	movf Num_H,0
	movwf htemp

;##### determinar incrementos

Process

;################### determina el numero 

	movf ltemp,0
	movwf temp	
	movf htemp,0
	movwf temp2	

;#########################################

Determina_M
				  ;0x06  0x9C  0xC18
				  ;0x0A  0x64  0x3E8
	movlw 0x03
	bcf STATUS,C
	subwf temp2,1
	btfss STATUS,C    
		goto Determina_C_1  ;si  desborda
	
	check_low
	movlw 0xE8    
	bcf STATUS,C
	subwf temp,1
	btfss STATUS,C    
		goto check_c 			;si desborda
	incf _M					; incrementa por cada vez que resta 0xE8
	goto Determina_M
	
	check_c
		movlw 0x1    
		bcf STATUS,C
		subwf temp2,1
		btfss STATUS,C 
			goto Determina_C_1  ; se desborda
		incf _M
		goto Determina_M

Determina_C_1
	movlw .0
	bcf STATUS,Z
	xorwf _M,0
	btfsc STATUS,Z
	goto noupdate

	movlw .3
	addwf temp2   ; porque al final se le resto para que entre aqui

	movf temp,0
	movwf ltemp

	goto Determina_C

noupdate
	movf htemp,0
	movwf temp2	
	movf ltemp,0
	movwf temp

Determina_C

	movlw 0x64
	bcf STATUS,C
	subwf temp,1
	btfss STATUS,C    
		goto check_h_c 	;SE DESBORDA	
	incf _C  ;SINO,  INCREMENTAMOS LAS CENTENAS
	goto Determina_C

	check_h_c 
		movlw 0x1    
		bcf STATUS,C
		subwf temp2
		btfss STATUS,C 
			goto Determina_D_1 ; SE DESBORDA ! QUIERE DECIR QUE YA NO HAY CENTENAS 
		incf _C ;SINO,  INCREMENTAMOS LAS CENTENAS
		goto Determina_C

Determina_D_1
	movlw .0
	bcf STATUS,Z
	xorwf _C,0
	btfsc STATUS,Z
	goto noupdate_2
	movlw 0x64
	addwf temp

	goto Determina_D

noupdate_2
	movf ltemp,0
	movwf temp

Determina_D
	
	movlw 0x0A
	bcf STATUS,C
	subwf temp,1
	btfss STATUS,C    
		goto Determina_U_1  ;SE DESBORDA:  temp = [0 - 9]
	incf _D
	goto Determina_D

Determina_U_1 
	movlw .0
	bcf STATUS,Z
	xorwf _D,0
	btfsc STATUS,Z
	goto noupdate_3
	movlw 0x0A
	addwf temp
	goto Determina_U

noupdate_3
	movf ltemp,0
	movwf temp

Determina_U

	movf temp,0	
	movwf _U

	movf _U,0   
		movwf Digi0
	movf _D,0   
		movwf Digi1
	movf _C,0   
		movwf Digi2
	movf _M,0   
		movwf Digi3


_End ;################### END ###############

clrf _U
clrf _D
clrf _C
clrf _M
clrf temp2
clrf temp
bcf STATUS,C

movf PORTA,0
andlw 0x18
movwf temp
rrf temp
rrf temp
rrf temp
;#################### Selecciona Digito ################
None
movlw .0
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
goto S0
	movf Digi0,0
goto Show
S0
movlw .1
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
goto S1
	movf Digi1,0
goto Show
S1
movlw .2
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
goto s1S0
	movf Digi2,0
goto Show
s1S0
	movf Digi3,0

Show
	bcf PCLATH,1
	bsf PCLATH,0

	call NUMEROS


	bcf PCLATH,1
	bcf PCLATH,0

	call Envia	

GOTO Loop


;####################################################################
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
bcf ST
bsf ST
return 

N
addwf PCL
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00
retlw 0x00

NUMEROS
addwf PCL
retlw 0x3F ;0
retlw 0X06 ;1
retlw 0X5B ;2
retlw 0X4F ;3
retlw 0X66 ;4
retlw 0X6D ;5
retlw 0X7D ;6
retlw 0X07 ;7
retlw 0X7F ;8
retlw 0X67 ;9


END

