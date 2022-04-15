    CBLOCK 0x40
    C1,C2,C3
    ENDC

LOAD MACRO Reg,Val
	movlw Val
	movwf Reg
	ENDM

	
Delay MACRO val
	LOAD C1,val
	decfsz C1,1    ; Decrementa Contador1.- 
	goto $-4    ; Si no es cero repetimos ciclo.- 
	ENDM

Delay_1s macro ;T= (3*C1*C2*C3 + 4*C3*C2 + 4*C3 + 1)Tci
    movlw .70
    movwf C3
    movlw .93
    movwf C2
    movlw .50
    movwf C1
    decfsz C1,1
    goto $-1
    decfsz C2,1
    goto $-5
    decfsz C3,1
    goto $-9
    endm
    
Delay_100ms macro
    movlw .253
    movwf C3
    movlw .131
    movwf C2
    decfsz C2,1
    goto $-1
    decfsz C3,1
    goto $-4
    endm    
	
	
	