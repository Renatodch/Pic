    list p=16f88
    #include <p16f88.inc>
    #include <Macros.inc>

    __config _CONFIG1, _XT_OSC & _WDT_OFF & _PWRTE_OFF
    
    cblock 0x20  
    var
    var1
    a0,a1,a2,a3,a4,a5
    var3
    endc
    
    org 0x00
    goto start
    org 0x04
    goto Interr
    org 0x05
    
start
    
    banksel ANSEL
    clrf ANSEL

    banksel TRISA
    clrf TRISA
    clrf TRISB
    
    ; Configurando UART
    clrw
    iorlw 1<<2
    movwf TRISB
    
    banksel SPBRG
    LOAD SPBRG,0x19
    banksel TXSTA
    LOAD TXSTA,0xA4
    banksel RCSTA
    LOAD RCSTA,0x90

    
    ;***************
    
    banksel PORTA
    clrf PORTA
    clrf PORTB
    clrf var
    
    bsf PORTA,0
    bsf PORTB,0
    
    bcf STATUS,C
    movlw 0x05
    movwf var3
    movlw 0x06
    subwf var3,1
    
loop
    
    movlw 0x22
    movwf FSR
   
    movlw 0xAA
    movwf INDF
    incf FSR
    btfss FSR,3
    goto $-4
    
    movlw 0x22
    movwf FSR
    
    movf var,0
    call InterminableStr
    movwf TXREG
    
    banksel TXSTA
    btfss TXSTA,TRMT 
    goto $-1

    banksel PORTB
    movlw 0x0e
    xorwf var,0
    btfss STATUS,Z
    goto $+3
    clrf var
    goto $+2
    incf var,1
    
    movlw .1
    xorwf PORTB,1
    xorwf PORTA,1
    Delay_100s
    
    goto loop
  
InterminableStr
    addwf PCL,1
    DT "Interminable\r\n"
    
    
    
Interr
    
    retfie
    
    
    end
    




    
    
    