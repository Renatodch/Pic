LIST	P=16F88
#include "p16f88.inc"
#include "Macros.inc"

 __CONFIG _CONFIG1, _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BODEN_OFF & _LVP_OFF
 __CONFIG _CONFIG2, _IESO_OFF  & _FCMEN_OFF & _CCP1_RB0 

in1a equ .0
in1b equ .1
in2a equ .2
in2b equ .3

Motor_Port  equ PORTA
Sensor_Port equ PORTB

;s4 s3 s2 s1
;0  0  0  1   func normal
;1  0  x  1
;0  1  x  1
;0  0  0  1
;0  0  1  1
;0  1  1  1
;0  1  1  0
;0  0  1  0
;0  1  0  0
;1  1  1  0
;1  1  0  0
;1  0  0  0
;1  1  1  1  todos activados

s1_s2_s3_s4 equ 0xF0
debounce	equ 0x00

s1 	  		equ 0x10
s2 			equ 0x20
s3 			equ 0x40
s4 	  		equ 0x80

s1_s3_s4	equ 0xD0

s1_s3 		equ 0x50
s1_s4 		equ 0x90

;last case

lento equ 0x15
s1_s4_0 equ 0x02
s1_s3_0 equ 0x04

CBLOCK 0x20
    C1,C2,CUENTA,tim,temp,Duty_Cycle,led,mask,last_case
ENDC

ORG  0X00
GOTO  INICIO 
ORG  0X05   
    
INICIO

BANKSEL ANSEL
	CLRF ANSEL

BANKSEL T2CON
	LOAD T2CON,0x07 ; pre =16, tmr2 on 
	LOAD CCP1CON,0x3F ; <4:5> 2 bits dc , <3:0> pwm mode
	LOAD CCPR1L,0x00
BANKSEL PR2
	LOAD PR2,0x3E  		; 4Mhz

BANKSEL TRISA
	LOAD TRISA,0x00 
	LOAD TRISB,0xF0 

BANKSEL PORTA
	CLRF Sensor_Port
	CLRF Motor_Port 

Call InitLineFollower
Call EnableTimer1
  
Loop
movf Sensor_Port,0 
andlw 0xF0
movwf temp

;########## Led #########
movf temp,0
movwf led

movlw 0xEF
andwf PORTA
movf led,0
andlw 0x10
iorwf PORTA

rrf led
rrf led
rrf led
rrf led

movlw 0x0E
andwf led
movlw 0xF1
andwf PORTB
movf led,0
iorwf PORTB

;#######################

S1_Event
movlw s1
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO S2_Event  
	LOAD CCPR1L,lento
	LOAD PR2,0x3E
	Call Forward
	GOTO Loop

S2_Event		
movlw s2
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO S3_Event
	LOAD CCPR1L,lento
	LOAD PR2,0x3E	
	Call Left
	GOTO Loop

S3_Event		
movlw s3
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO S4_Event  
	LOAD CCPR1L,lento
	LOAD PR2,0x3E	
	Call Left
	GOTO Loop

S4_Event		
movlw s4
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO S1_S3_S4_Event  
	LOAD CCPR1L,lento
	LOAD PR2,0x3E
	Call Left
	GOTO Loop

S1_S3_S4_Event ; no sabe que hacer entonces  que vaya defrente
movlw s1_s3_s4
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO S1_S3_Event  
	LOAD CCPR1L,lento
	LOAD PR2,0x3E
	Call Forward
	GOTO Loop

S1_S3_Event ;dont care s2
bcf STATUS,Z
movf temp,0
movwf mask
movlw 0xDF
andwf mask
movlw s1_s3
xorwf mask,0
btfss STATUS,Z
GOTO S1_S4_Event  
	
	LOAD CCPR1L,lento
	LOAD PR2,0x3E
	LOAD last_case,s1_s3_0
	Call Left
	GOTO Loop

S1_S4_Event ;dont care s2
bcf STATUS,Z
movf temp,0
movwf mask
movlw 0xDF
andwf mask
movlw s1_s4
xorwf mask,0
btfss STATUS,Z
GOTO S1_S2_S3_S4_Event
	
	LOAD CCPR1L,lento
	LOAD PR2,0x3E
	LOAD last_case,s1_s4_0
	Call Right
	GOTO Loop

S1_S2_S3_S4_Event
movlw s1_s2_s3_s4
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO D_Event
	
	Call Stop 
	GOTO Loop

D_Event
movlw debounce
bcf STATUS,Z
xorwf temp,0
btfss STATUS,Z
GOTO Loop

	;Call Stop
	movlw s1_s4_0	
	bcf STATUS,Z
	xorwf last_case,0
	btfss STATUS,Z
	GOTO Left_D
		LOAD CCPR1L,0x3E
		LOAD PR2,0x3E
		Call Right
		GOto End_D
	Left_D
	movlw s1_s3_0	
	bcf STATUS,Z
	xorwf last_case,0
	btfss STATUS,Z
	GOTO Loop
		LOAD CCPR1L,0x3E
		LOAD PR2,0x3E
		Call Left
	
	End_D
	LOAD last_case,0x00
GOTO Loop
 
;$$$$$$$$$$$$$$$$$SUbRoutineS$$$$$$$$$$$$$$$$$$$$$
InitLineFollower
	LOAD CCPR1L,0x15
	LOAD PR2,0x3E
	movlw 0xF0	
	andwf Motor_Port 
return

Left ;  1110
	
	bcf Motor_Port ,in1a	
	bsf Motor_Port ,in1b
	bsf Motor_Port ,in2a
	bsf Motor_Port ,in2b
return

Right;  1011

	bsf Motor_Port ,in1a	
	bsf Motor_Port ,in1b
	bcf Motor_Port ,in2a
	bsf Motor_Port ,in2b
return

Forward;  1010

	bcf Motor_Port ,in1a	
	bsf Motor_Port ,in1b
	bcf Motor_Port ,in2a
	bsf Motor_Port ,in2b
return

Stop;  1111

	movlw 0x0F
	iorwf Motor_Port 
return

EnableTimer1
	movlw 0x01
	iorwf T1CON
return


END


