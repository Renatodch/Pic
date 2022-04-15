	list p=16F88 
	#include P16F88.inc 
	__CONFIG _CONFIG1,(_XT_OSC & _WDT_OFF & _PWRTE_OFF & _BODEN_OFF & _MCLR_ON & _CCP1_RB0  & _CP_OFF & _CPD_OFF & _DEBUG_OFF & _LVP_OFF & _WRT_PROTECT_OFF) 
    __CONFIG _CONFIG2,(_FCMEN_OFF & _IESO_OFF)
;**** Definicion de variables **** 
	
	cblock 0x20
		Tecla, Aux, W_Temp, STATUS_Temp, dato,bit,count,var1,var2,var3,var4,u,c1,c2,x,y,c3,c4,ded	
	endc
	
;**** Inicio  del Micro **** 
	org  0x00    ; Aqui comienza el micro.- 
	goto  Inicio   ; Salto a inicio de mi programa.- 
	org 0x04
	goto INT_RB        
	org  0x05  


tabla1
ADDWF PCL,1
DT 0X3F, 0X06, 0X5B,0X4F,0X66,0X6D,0X7d ,0X07,0X7F,0X67,0X00 

tabla2
ADDWF PCL,1
DT 0X01,0X02,0X04,0X08
  
;**** Programa principal **** 
;**** Configuración de puertos **** 
Inicio
	bsf STATUS,RP0   ;Pasamos de Banco 0 a Banco 1
	movlw 0xf0
	movwf TRISB
	clrf TRISA
	clrf ANSEL    ;Pines digitales. 
	bcf OPTION_REG,7
;**** Configuración de Interrupcion **** 
	bcf STATUS,RP0


	bcf INTCON,RBIF
	bsf INTCON,GIE
	bsf INTCON,RBIE
  

	
Bucle
    clrf Aux

    clrf count
    clrf ded
    movlw 0x0F
	movwf PORTA

    movlw .10
    movwf var1
    movwf var2
    movwf var3
    movwf var4

	goto Preg1

Bucle1
    movfw Tecla
    movwf var1
   
Preg1 
    clrf u
    clrf Aux   
    
    movfw var1
    call FILA
    bcf PORTA,0
   	       
    movfw var2
    call FILA
    bcf PORTA,1
 
    movfw var3
    call FILA
    bcf PORTA,2

    movfw var4
    call FILA
    bcf PORTA,3

    movlw .1           
	xorwf Aux,0     
	btfss STATUS,Z 
	goto Preg1
    
    movlw .1         
	xorwf ded,0       
	btfsc STATUS,Z
    goto Bucle
    
movlw .0
xorwf count,0
btfss STATUS,Z
goto $+3  
    incf count,1
    GOTO Bucle1
        
movlw .1
xorwf count,0
btfss STATUS,Z
goto $+5  
    movfw var1
    movwf var2
    incf count,1
    GOTO Bucle1

movlw .2
xorwf count,0
btfss STATUS,Z
goto $+7 
    movfw var2
    movwf var3 
    movfw var1
    movwf var2
    incf count,1
	GOTO Bucle1

movlw .3
xorwf count,0
btfss STATUS,Z
goto Preg1 
    movfw var3
    movwf var4
    movfw var2
    movwf var3 
    movfw var1
    movwf var2
    incf count,1
	GOTO Bucle1

FILA
call tabla1
call Envia
movfw u
call tabla2
aDDwf PORTA,1  
incf u,1
call delay
return

;**** Interrupcion *****
INT_RB
	movwf W_Temp  ; Copiamos W a un registro Temporario.
    swapf STATUS,0  ;Invertimos los nibles del registro STATUS.
    movwf STATUS_Temp  ; Guardamos STATUS en un registro 
	 
   	btfss INTCON,RBIF
	goto SALIR_INT

	bsf PORTB,0
	bsf PORTB,1
	bcf PORTB,2    ;PORTB=11110011
	movlw .1
	movwf Tecla    ;Tecla=1
	call Detecta
	movlw .1
	xorwf Aux,0
	btfsc STATUS,Z 
	goto Carga

	bsf PORTB,0
	bcf PORTB,1
	bsf PORTB,2 	
	movlw .2
	movwf Tecla
	call Detecta
	movlw .1
	xorwf Aux,0
	btfsc STATUS,Z
	goto Carga

	bcf PORTB,0
	bsf PORTB,1
	bsf PORTB,2
	movlw .3
	movwf Tecla
	call Detecta
    

Carga	
	bcf PORTB,0
	bcf PORTB,1
	bcf PORTB,2
	bcf INTCON,RBIF
SALIR_INT
	swapf STATUS_Temp,0 ; Invertimos lo nibles de STATUS_Temp.    
	movwf STATUS
	swapf W_Temp,1  ; Invertimos los nibles y lo guardamos en el mismo registro.
    swapf W_Temp,0 
 
	retfie

Detecta

	btfsc PORTB,4
	goto l1
    call retardo
    btfsc PORTB,4
    goto l1
    btfss PORTB,4
    goto $-1
    call retardo
    btfss PORTB,4
    goto $-1

	movlw .1
	movwf Aux
	return
l1
	movlw .3
	addwf Tecla,1
	btfsc PORTB,5
    goto l2
    call retardo
    btfsc PORTB,5
    goto l2
    btfss PORTB,5
    goto $-1
    call retardo
    btfss PORTB,5
    goto $-1

	movlw .1
	movwf Aux
	return
l2
	movlw .3
	addwf Tecla,1
	btfsc PORTB,6
	goto l3
    call retardo
    btfsc PORTB,6
    goto l3
    btfss PORTB,6
    goto $-1
    call retardo
    btfss PORTB,6
    goto $-1
	movlw .1
	movwf Aux
	return
l3
	movlw .3
	addwf Tecla,1  
	btfsc PORTB,7
    goto l4
    call retardo
    btfsc PORTB,7
    goto l4
    btfss PORTB,7
    goto $-1
    call retardo
    btfss PORTB,7
    goto $-4
    goto $+2
     
l4
	return

	btfsc PORTB,1
	goto $+5
 	clrf Tecla
	movlw .1
	movwf Aux
    return

    btfsc PORTB,0
    goto $+5
   	movlw .1
	movwf ded
    movwf Aux
	return

    btfsc PORTB,2
    goto $+4
   	movlw .1
	movwf ded
    movwf Aux
	return

Envia
	movwf dato
	movlw d'8'      ; Número de bits a transmitir.
	movwf bit
EnviaBit              ; Comienza a enviar datos.
	btfss dato,7  ; ¿Es un "1" el bit a transmitir?
	goto $+3
	bCf PORTB,3    ; Si, Transmite un "1".
	goto $+2
	bSf PORTB,3    ; No, pues envía un "0".
	bcf PORTA,4  ; Clock=0.
	bsf PORTA,4  ; Clock=1.
    rlf dato,1  ; Rota para envia siguiente bit.-
    decfsz bit,1    ; Comprueba si es el último bit. 7,6,5,4,3,2,1,0
	goto EnviaBit    ; No es el último bit repite la operación.    
    return     

delay
movlw .10	
movwf c1
REPEAT1
movlw .20
movwf c2
REPEAT2
decfsz c2,1
goto REPEAT2

decfsz c1,1
goto REPEAT1
return     

retardo
movlw .200
movwf c3
REPEAT4
movlw .50
movwf c4
REPEAT3
decfsz c4,1
goto REPEAT3

decfsz c3,1
goto REPEAT4
return
   

    end
