CBLOCK 0x40
C5,
C6,
C7,
ENDC

LOAD MACRO Reg,Val
	movlw Val
	movwf Reg
	ENDM

	
Delay MACRO val
	LOAD C1,val
	LOAD C2,0xff    ; Iniciamos contador2 
	decfsz C2,1    ; Decrementa Contador2 y si es 0 sale.-     
	goto $-1       ; Si no es 0 repetimos ciclo.- 
	decfsz C1,1    ; Decrementa Contador1.- 
	goto $-4    ; Si no es cero repetimos ciclo.- 
	ENDM

Print MACRO i
	movlw 0xF0
	andwf PORTB
	movf i,0
	call msg  
	movwf temp ; actual
	movlw 0x0F
	andwf temp,0
	iorwf PORTB,1
	
	movf i,0
	call msg
	movwf temp
	movlw 0x70
	andwf temp,1
	rrf temp
	rrf temp
	rrf temp
	rrf temp
	movlw 0xF8
	andwf PORTA
	movf temp,0
	iorwf PORTA,1

ENDM