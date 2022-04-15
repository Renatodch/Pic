Device 16F876A
Xtal 20
On_Hardware_Interrupt GoTo Inter
Declare Hserial_Baud = 9600 ' Set baud rate to 9600
Declare Hserial_RCSTA = %10010000 ' Enable continuous receive
Declare Hserial_TXSTA = %00100000 ' Enable transmit and asynchronous mode
Declare Hserial_Clear = On
Declare Adin_Res = 10 ' 10-bit result required
Declare Adin_Tad = FRC ' RC OSC chosen
Declare Adin_Stime = 50 ' Allow 50us sample timeDim x As Byte
Declare LCD_Type 0
Declare LCD_Interface 4  
Declare LCD_DTPin PORTD.4
Declare LCD_ENPin PORTD.3
Declare LCD_RSPin PORTD.2                                                        
Declare LCD_Lines 2



Symbol T0F=INTCON.2
Symbol GIE=INTCON.7             
Symbol TXIF = PIR1.4     'FLAG DE INTERRUPCION
Symbol RCIF = PIR1.5     'FLAG DE INTERRUPCION
Symbol RCIE = PIE1.5     'HABILITACION DE INTERRUPCION RECEPCION                           
Symbol TXIE = PIE1.4     'HABILITACION DE INTERRUPCION TRANSMISION 

'ANSEL=0x00
ADCON1=%10000000 ' Set analogue input on PortA.0
ADCON0=%11000001 '
TRISA=$FF
TRISC.6=0
TRISC.7=1
TRISD.1=1
PORTD.1=1
PORTA=0
GIE=0
TXIE=0               
RCIE=1
'INTCON=$A0 ' Global Interrupt Enable
'INTCON=%11000000
'GIE=1
'TMR0=61
'OPTION_REG=6
TRISB=$00
PORTB=$02

Dim v As Word
Dim led As Word
Dim Dis As Float

Dim gar As Byte
Dim i As Word
Dim pos As Word
Dim valor As Word
Dim x[2] As Word
Dim w[2] As Word
Dim A0 As Float
Dim A1 As Float
Dim aux As Float
Dim y[4] As Word
Dim B[4] As Byte
Dim P As Float

x[0]=0
A0=0
aux=0
v=0
led=0
pos=500


Cls
For i=1 To 50 Step 1
Servo PORTB.2,pos
DelayMS 20
Next i

Print At 1,1, "Duty Cycle:"
Print At 2,1, Dec pos
 
inicio:

If PORTD.1=0 Then
DelayMS 50
If PORTD.1=0 Then
While  PORTD.1=0
Wend
If PORTD.1=1 Then
DelayMS 50
If PORTD.1=1 Then


pos=pos+10
Print At 2,1, Dec pos
'HSEROUt["5","6",13]

For i=1 To 50 Step 1
Servo PORTB.2,pos
DelayMS 20
Next i

EndIf
EndIf
EndIf
EndIf



If v=1 Then
pos=2500  
For i=1 To 80 Step 1
Servo PORTB.2,pos
DelayMS 20
Next i 
pos=500
For i=1 To 100 Step 1
Servo PORTB.2,pos
DelayMS 20
Next i
EndIf
    

If v=2 Then
pos=500
For i=1 To 50 Step 1
Servo PORTB.2,pos
DelayMS 20
Next i
For i=500 To 2500 Step 10
Servo PORTB.2,i
DelayMS 20
Next i
EndIf


'HSerIn [Dec v]  
GoTo inicio
End


'INT:
'Context Save
   ' GIE=0
   ' TMR0= 61      '61    '(256-x)256/5=tiempo de muestreo en Us    10ms

  '  Servo PORTB.1,500

 '   T0F=0                                                
 '   GIE=1
'Context Restore 

Inter:
Context Save
    GIE=0 
    HSerIn [Dec v]
    led=1
    Print Dec v
    Toggle PORTB.1 
    DelayMS 100
    Toggle PORTB.1 
    GIE=1  
Context Restore
