CBLOCK 0x40
C1,
C2,
C3,
Bit,
Dato
ENDC

LOAD MACRO Reg,Val
	movlw Val
	movwf Reg
	ENDM

Toggle MACRO Reg,Bit
	btfss Reg,Bit
	goto $+3
	bcf Reg,Bit
	goto $+2
	bsf Reg,Bit
	ENDM

Shout MACRO PORT1,DS,PORT2,CLK,Valor
	movfw Valor
	movwf Dato
	movlw d'8'      ; Número de bits a transmitir.
	movwf Bit
          ; Comienza a enviar datos.
	btfss Dato,7  ; ¿Es un "1" el bit a transmitir?
	goto $+3
	bsf PORT1,DS    ; Si, Transmite un "1".
	goto $+2
	bcf PORT1,DS    ; No, pues envía un "0".
	bcf PORT2,CLK  ; Clock=0.
    nop
	bsf PORT2,CLK  ; Clock=1.
    rlf Dato,1  ; Rota para envia siguiente bit.-
    decfsz Bit,1    ; Comprueba si es el último bit.
	goto $-0a    ; No es el último bit repite la operación.
	ENDM
	
Delay MACRO val
	LOAD C1,val
	LOAD C2,0xff    ; Iniciamos contador2 
	decfsz C2,1    ; Decrementa Contador2 y si es 0 sale.-     
	goto $-1       ; Si no es 0 repetimos ciclo.- 
	decfsz C1,1    ; Decrementa Contador1.- 
	goto $-4    ; Si no es cero repetimos ciclo.- 
	ENDM

Del MACRO val    ; not in ms
	LOAD C3,val
    LOAD C1,.5    ; Iniciamos contador1.-  
    LOAD C2,.65    ; Iniciamos contador2 
	decfsz C2,1    ; Decrementa Contador2 y si es 0 sale.-     
    goto $-1    ; Si no es 0 repetimos ciclo.- 
    decfsz C1,1    ; Decrementa Contador1.- 
    goto $-4    ; Si no es cero repetimos ciclo.- 
	decfsz C3,1
	goto $-7
	ENDM
	