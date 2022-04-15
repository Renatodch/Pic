LIST	P=16F88
#include "p16f88.inc"
#include "Macros.inc"

 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BODEN_OFF & _LVP_OFF

 __CONFIG _CONFIG2, _IESO_OFF  & _FCMEN_OFF
 
#DEFINE SH PORTB,1
#DEFINE DS PORTB,2
#DEFINE ST PORTB,3

mensaje1 EQU .1
mensaje2 EQU .16
mensaje3 EQU .34

mensaje1_len EQU .16 ; fin - inicio + 1
mensaje2_len EQU .34 ; fin - inicio + 1
mensaje3_len EQU .58

tiempo 	     EQU .10  ; delay de multiplexado  CAMBIAR SI SALE PARPADEANDO , MENOR TIEMPO MENOS PARPADEO
velocidad 	 EQU .10  ; delay de LETRA  

CBLOCK 0x20
    C1,C2,CUENTA,i0,i1,i2,i3,delay,k,temp,dato,bit,w_temp,msg,pulse,cant,flag,len,num
ENDC

ORG  0X00  
GOTO  INICIO 
ORG  0x04  
GOTO  IRQ
ORG  0X05   
    
INICIO

BANKSEL TRISA
LOAD TRISA,0x18 
LOAD TRISB,0x01 

BANKSEL ANSEL
CLRF ANSEL

BANKSEL PORTA
CLRF PORTB
CLRF PORTA
LOAD OPTION_REG,0x60
LOAD INTCON, 0xB0
LOAD TMR0,0xFF

clrf delay
clrf i0
clrf i1
clrf i2
clrf i3
clrf msg
clrf flag 


Call Clear

Loop ;##################################### BUCLE ############################

btfss flag,1
goto show_msj

btfss flag,2
goto msg1
goto process

msg1
movlw .1
bcf STATUS,Z
xorwf msg,0
btfss STATUS,Z
goto msg2
	Call Clear
	movlw mensaje1_len
	movwf len
	movlw mensaje1
	movwf cant
	goto set_val
msg2
movlw .2
bcf STATUS,Z
xorwf msg,0
btfss STATUS,Z
goto msg3
	Call Clear
	movlw mensaje2_len
	movwf len
	movlw mensaje2
	movwf cant	
	goto set_val
msg3
movlw .3
bcf STATUS,Z
xorwf msg,0
btfss STATUS,Z
goto show_msj
	Call Clear
	movlw mensaje3_len
	movwf len
	movlw mensaje3
	movwf cant

set_val
	clrf i0
	clrf i1
	clrf i2
	clrf i3

	movf cant,0
	movwf i0

	bsf flag,2
	
process

bcf PCLATH,1
bsf PCLATH,0

LOAD PORTB,0xE0
movf i0,0
call Tm_1   
call Envia
movf i0,0
call Tm_2 
call Envia
bcf ST
bsf ST
Delay tiempo   

LOAD PORTB,0xD0
movf i1,0
call Tm_1   
call Envia
movf i1,0
call Tm_2 
call Envia
bcf ST
bsf ST
Delay tiempo  

LOAD PORTB,0xB0
movf i2,0
call Tm_1    
call Envia
movf i2,0
call Tm_2
call Envia
bcf ST
bsf ST
Delay tiempo  

LOAD PORTB,0x70
movf i3,0
call Tm_1   
call Envia
movf i3,0
call Tm_2 
call Envia
bcf ST
bsf ST
Delay tiempo  

bcf PCLATH,1
bcf PCLATH,0  

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

movf len,0
bcf STATUS,Z
xorwf i0,0   ; CARACTERES + 1
btfss STATUS,Z
GOTO Loop

movf cant,0
movwf i0

GOTO Loop

show_msj ; #####################show msj static##################33

	msj1
	movlw .1
	bcf STATUS,Z
	xorwf pulse,0
	btfss STATUS,Z
	goto msj2
		movlw .3
		movwf num	
	goto sub_process	
	msj2
	movlw .2
	bcf STATUS,Z
	xorwf pulse,0
	btfss STATUS,Z
	goto msj3
		movlw .4
		movwf num
	goto sub_process	
	msj3
	movlw .3
	bcf STATUS,Z
	xorwf pulse,0
	btfss STATUS,Z
	goto Clear_Display ; else clear display
		movlw .5
		movwf num

	sub_process
	bcf PCLATH,1
	bsf PCLATH,0

	LOAD PORTB,0xE0
	movf num,0
	call M_1   
	call Envia
	movf num,0
	call M_2 
	call Envia
	bcf ST
	bsf ST
	Delay tiempo   
	
	LOAD PORTB,0xD0
	movlw .2
	call M_1      
	call Envia
	movlw .2
	call M_2 
	call Envia
	bcf ST
	bsf ST
	Delay tiempo  
	
	LOAD PORTB,0xB0
	movlw .1
	call M_1   
	call Envia
	movlw .1
	call M_2
	call Envia
	bcf ST
	bsf ST
	Delay tiempo   
	
	LOAD PORTB,0x70  ; varia
	movlw .0
	call M_1   
	call Envia
	movlw .0
	call M_2 
	call Envia
	bcf ST
	bsf ST
	Delay tiempo  

	bcf PCLATH,1
	bcf PCLATH,0
	
	goto sigue

	Clear_Display
	Call Clear

	sigue
	btfss flag,0
	GOTO Loop
	bsf flag,1

GOTO Loop

;####################### subroutines #################
Clear
LOAD PORTB,0x00
movlw 0x00   
call Envia
movlw 0x00
call Envia
bcf ST
bsf ST

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




IRQ
	BCF INTCON, GIE ;dise irqs
	movwf w_temp
	btfss INTCON, INTF
	goto pulsos
		BCF INTCON, INTF
		bcf flag,2
		bsf flag,0
		movf pulse,0
		movwf msg

	pulsos
	btfss INTCON, TMR0IF
	goto exit_irq
		BCF INTCON, TMR0IF
		bcf flag,1
		bcf flag,0

		incf pulse
		movlw 0x04
		bcf STATUS,Z
		xorwf pulse,0
		btfss STATUS,Z
		goto end_pulses	
		movlw 0x01
		movwf pulse
		end_pulses
		LOAD TMR0,0xFF
	exit_irq
    movf w_temp,0
	BSF INTCON, GIE ;en irqs  
retfie

NUlls
retlw 0x00 ;NULL
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 
retlw 0X00 


M_1
addwf PCL,1
retlw 0x01;M
retlw 0x22;E
retlw 0x04;N
retlw 0x00;1
retlw 0x22;2
retlw 0x22;3
M_2
addwf PCL,1
retlw 0x76;M
retlw 0x39;E
retlw 0x76;N
retlw 0x06;1
retlw 0x1B;2
retlw 0x0F;3

Tm_1
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
retlw 0x00 ;NULL 	;U_E_1 
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
retlw 0x00 ;NULL	;ED2_1 
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
retlw 0X00 ;NULL ; fin
retlw 0X00 ;NULL

Tm_2
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
U_E_2
;addwf PCL,1
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
ED2_2
;addwf PCL,1
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
retlw 0X00 ;NULL
retlw 0X00 ;NULL

END

