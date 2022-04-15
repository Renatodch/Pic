#include <16F88.h>
#device ADC=10

#FUSES NOWDT                      //Watch Dog Timer
#FUSES NOBROWNOUT //No brownout reset
#FUSES NOLVP     //No low voltage prgming, B3(PIC16) or B5(PIC18) used for I/O
#FUSES HS
#use delay(crystal=20000000)
#use rs232(baud=115200,parity=N,xmit=PIN_B5,rcv=PIN_B2,bits=8,stream=SP)

#define LED          PIN_A2
#define LED_SENSOR   PIN_A3
#define LED_ON       PIN_A4

#define BUZZER        PIN_B0
#define SENSOR        PIN_B1
#define LED_GSM_OK    PIN_B3
#define GSM_RST       PIN_B4
#define OUT_AlARM     PIN_B6
#define OUT_LIGHT     PIN_B7


#byte ANSEL = 0x9B
#byte TRISA = 0x85
#byte PORTA = 0x05
#byte TRISB = 0x86
#byte PORTB = 0x06
#byte TMR0 = 0x01

/****************************** Lib Resources ***************************/


typedef struct
{
   unsigned int32 Time;
   unsigned int32 Interval;
   char           En;
}Timer;


void Led_On_Timer_Start(int led_in);
void Timer_Start(Timer *Tmr);
void Timer_Stop(Timer *Tmr);
void Timer_Set_Interval(Timer *Tmr,unsigned int32 time);
void Timer_Init(Timer *Tmr,unsigned int32 time);
int Is_Timer_Elapsed(Timer *Tmr);
void Read_ADC_0(void);

/******************************* Home **********************************/
typedef enum
{
   Buzzer_Sonando,
   Ejecutando_Alarma_Func,
   Ejecutando_Luz_Func,
   Luz_Func_Detectando,
   Luz_Func_Esperando,
   Alarma_Encendida,
   Foco_Encendido_Estado,
}State_e;

typedef enum
{
   Modo_Luz_Seleccionado,
   Modo_Alarma_Seleccionado,
   Sigue_Sonando,
   Buzzer_End,
   Modo_Luz_Activado,
   Modo_Luz_Desactivado,
   Hay_Alguien,
   No_Hay_Nadie,
   Tiempo_Encendido_Elapso,
   Apagar_Alarma,
}EVT_e;

typedef struct
{
   State_e state;   
}Home_t;


void Read_Sensor(void);
void Indicador_Event(void);
void Buzzer_Func(EVT_e evt);
unsigned int16 Leer_AD(char channel);

void Casa_Fsm(EVT_e evt);
void Alarma_Func(EVT_e evt);
void Light_Func(EVT_e evt);
void Esperando_Oscuridad(EVT_e evt);
void Detectando_Presencia(EVT_e evt);
void Alerta_Va_a_Sonar(EVT_e evt);
void Foco_ON(EVT_e evt);
void Alarma_ON(EVT_e evt);

void Config_Hardware(void);
void Config_Variables(void);
void Loop(void); 

void Home_Init(Home_t* hom);
/******************************* GSM ***************************************/
typedef enum
{
   Gsm_Desactivado,
   Gsm_Activado,
   Configurando_Gsm,
   Funcionando_Gsm,

}Gsm_State_e;

typedef struct
{  
   char num_c;
   Gsm_state_e State;
   Timer Tmr_Gsm_At;
   Timer Tmr_Gsm;

}GSM_t;


void AT_Generate(void);
void Gsm_Events(void);
void Gsm_Init(GSM_t * gsm);
void Gsm_Sms_Broadcast( char *SMS);
void Gsm_Event_Handler(void);
void Serial_Event(GSM_t * gsm_handler);
void Clear_Buffer(void);




