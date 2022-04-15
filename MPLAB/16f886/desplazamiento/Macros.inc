CBLOCK 0x40
C5,
C6,
C7,
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

	
Delay MACRO val
	LOAD C1,val
	LOAD C2,0xff    ; Iniciamos contador2 
	decfsz C2,1    ; Decrementa Contador2 y si es 0 sale.-     
	goto $-1       ; Si no es 0 repetimos ciclo.- 
	decfsz C1,1    ; Decrementa Contador1.- 
	goto $-4    ; Si no es cero repetimos ciclo.- 
	ENDM

Del MACRO val    ; not in ms
	LOAD C7,val
    LOAD C5,.5    ; Iniciamos contador1.-  
    LOAD C6,.65    ; Iniciamos contador2 
	decfsz C6,1    ; Decrementa Contador2 y si es 0 sale.-     
    goto $-1    ; Si no es 0 repetimos ciclo.- 
    decfsz C5,1    ; Decrementa Contador1.- 
    goto $-4    ; Si no es cero repetimos ciclo.- 
	decfsz C7,1
	goto $-7
	ENDM
	