#include <Casa.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>

char Aviso_Alerta_Str[]="ALERTA: SIRENA ENCENDIDA!!!";
char Sistema_Inicio_Str[]="Sistema Encendido: Luz Aut. Activado";
unsigned int i;
char char_uart = 0;
char Buffer[88];
Timer Tmr_Uart;
Timer Tmr_Led;
Timer Tmr_Light;
Timer Tmr_Led_1;
//Timer Tmr_Alarma;
GSM_t Gsm;
Home_t Home;

//!#INT_RDA
//!void  RDA_isr(void) 
//!{  
//!      Tmr_Uart.Time = Tmr_Uart.Interval;
//!      Tmr_Uart.En = 1;   
//!      
//!      char_uart = fgetc(SP);  
//!      Buffer[i++] = char_uart;
//!      if(i == sizeof(Buffer)) i=0;
//!}
#INT_TIMER0
void  TIMER0_isr(void) 
{
   
   if(Tmr_Led.Time > 0 && Tmr_Led.En)                          Tmr_Led.Time --;      
             
   if(Tmr_Light.Time > 0 && Tmr_Light.En)                      Tmr_Light.Time --;
   if(Tmr_Led_1.Time > 0 && Tmr_Led_1.En)                      Tmr_Led_1.Time --;
   //if(Tmr_Alarma.Time > 0 && Tmr_Alarma.En)                    Tmr_Alarma.Time --;
   if(Gsm.Tmr_Gsm_At.Time > 0 && Gsm.Tmr_Gsm_At.En)            Gsm.Tmr_Gsm_At.Time --;
   
   if(Tmr_Uart.Time > 0 && Tmr_Uart.En)                        Tmr_Uart.Time --;
   
   TMR0=99;
}

void main()
{
   Config_Hardware();
   
   Config_Variables();
   
   while(true)  
   {
      Loop();
      
      //restart_wdt();
   }
}

void Loop(void)
{     
   Gsm_Events();

   Read_Sensor(); //Sensor activado ?

   Read_ADC_0(); //Es de noche ?
         
   Indicador_Event();

   if(Is_Timer_Elapsed(&Tmr_Uart))
   {
      Gsm_Event_Handler();   //GSM COM 
   }
}

void Casa_Fsm(EVT_e evt)//FSM de Funcion
{
   switch(Home.state)
   {
      case Ejecutando_Alarma_Func:
         Alarma_Func(evt);
      break;
      case Alarma_Encendida:
         Alarma_ON(evt);
      break;
      case Ejecutando_Luz_Func:
         Light_Func(evt);
      break;
      case Luz_Func_Detectando:
         Detectando_Presencia(evt);
      break; 
      case Foco_Encendido_Estado:
         Foco_ON(evt);
      break;
   }
}
void Alarma_ON(EVT_e evt)
{
   switch(evt)
   {
      case Modo_Luz_Seleccionado:
      case Apagar_Alarma:
         output_high(OUT_LIGHT);
         output_high(OUT_ALARM);  
         Home.state = Ejecutando_Luz_Func;
      break;
   }
}
void Foco_ON(EVT_e evt) 
{
   switch(evt)
   {
      case Hay_Alguien:
         Timer_Start(&Tmr_Light);
      break;
      case Tiempo_Encendido_Elapso:  //Que vuelva a decidir el sensor
         Home.state = Luz_Func_Detectando;
         output_high(OUT_LIGHT);
      break;
      case Modo_Alarma_Seleccionado:
         Timer_Stop(&Tmr_Light);
         Home.state = Buzzer_Sonando;
         output_high(OUT_LIGHT);

      break;
   }
}

void Detectando_Presencia(EVT_e evt)
{
   switch(evt)
   {
      case Hay_Alguien:
         Timer_Start(&Tmr_Light);
         Home.state = Foco_Encendido_Estado; 
         output_low(OUT_LIGHT); //encendido foco
      break;
      case No_Hay_Nadie:
         output_high(OUT_LIGHT);
      break;
      case Modo_Luz_Desactivado:
         output_high(OUT_LIGHT);
         Home.state = Ejecutando_Luz_Func;   
      break;
      case Modo_Alarma_Seleccionado:         
         Home.state = Buzzer_Sonando;  
     
      break;
      default: break;
   }
}
void Light_Func(EVT_e evt)
{
   switch(evt)
   { 
      case Modo_Luz_Activado:
         Home.state = Luz_Func_Detectando;
      break;
      case Modo_Alarma_Seleccionado:         
         Home.state = Ejecutando_Alarma_Func;
      
      break;
      default: break;
   }
}

void Alarma_Func(EVT_e evt)
{
   switch(evt)
   {
      case Hay_Alguien:
         output_low(OUT_ALARM);
         output_low(OUT_LIGHT);
         Gsm_Sms_Broadcast(Aviso_Alerta_Str);   //Para avisar por sms;
         Home.state = Alarma_Encendida;
      break;
      case Modo_Luz_Seleccionado:
         Home.state = Ejecutando_Luz_Func;
      break;
      default: break;
   }
}

void Read_Sensor(void) //Sensor de Presencia
{
   if(!input(SENSOR))  Casa_Fsm(Hay_Alguien);
   else                Casa_Fsm(No_Hay_Nadie);
}
void Read_ADC_0(void) //Sensor de Luz
{
   unsigned int16 v = Leer_AD(0);
   if( v > 400 )      Casa_Fsm(Modo_Luz_Activado); 
   else               Casa_Fsm(Modo_Luz_Desactivado);
}
void Indicador_Event(void)
{
   static char toggle;
   
   if(Is_Timer_Elapsed(&Tmr_Led))
   {    
      toggle ^= 1;
     
      if(toggle)      output_high(LED);
      else            output_low(LED);
       
      Timer_Start(&Tmr_Led); 
   }
   else if(Home.state == Luz_Func_Detectando || Home.state == Ejecutando_Alarma_Func || Home.state == Foco_Encendido_Estado )
   {   
      output_high(LED_ON);
   }
   else
   {
      output_low(LED_ON);
   }
   
   if(!input(SENSOR)) output_high(LED_SENSOR);
   else               output_low(LED_SENSOR);
   
   if(Is_Timer_Elapsed(&Tmr_Light))    Casa_Fsm(Tiempo_Encendido_Elapso);   
}
unsigned int16 Leer_AD(char channel)
{
   unsigned int16 value = 0;
   set_adc_channel(channel);
   delay_us(100);
   value =  read_adc();
   return value;
}
void Config_Hardware(void)
{
//!   setup_wdt(WDT_ON);
//!   setup_wdt(WDT_144MS|WDT_TIMES_128);      //~18.4 s reset

   port_B_pullups(0xff);
   TMR0  = 99;
   ANSEL = 0x01;
   TRISB = 0x06;
   PORTB = 0x00;
   TRISA = 0x01;
   PORTA = 0x00;

   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_32|RTCC_8_bit);      //1000 us overflow
   setup_adc_ports(sAN0);
   setup_adc(ADC_CLOCK_INTERNAL);

   enable_interrupts(INT_RDA);
   enable_interrupts(INT_TIMER0);
   enable_interrupts(GLOBAL);
}
void Config_Variables(void)
{
   Home_Init(&Home);
//!   Gsm_Init(&Gsm);
}
void Home_Init(Home_t* home_var)
{
   
   output_high(OUT_LIGHT);
   output_high(OUT_ALARM);
   home_var->state = Ejecutando_Luz_Func;
 
   Timer_Init(&Tmr_Led,200);
   Timer_Init(&Tmr_Light,60000);
   Timer_Init(&Tmr_Uart,1000);
   //Timer_Init(&Tmr_Alarma,60000);
  
   Timer_Start(&Tmr_Led);   
}

/********************************** Gsm *************************************/
void Gsm_Init(GSM_t * gsm_var)
{
   output_high(GSM_RST);
   output_low(LED_GSM_OK); 
   
   Timer_Init(&Tmr_Led_1,1000);
   Timer_Init(&gsm_var->Tmr_Gsm_At,10000);
   Gsm.num_c = 0;
   
   Timer_Start(&gsm_var->Tmr_Gsm_At);
   gsm_var->state = Gsm_Activado;
   
}
void Gsm_Events(void)
{
   if(Is_Timer_Elapsed(&gsm.Tmr_Gsm_At))     AT_Generate(); 

}

void Gsm_Event_Handler(void)
{
   char String[10] = {0};
   char *pbuf;
   int k;
   char mode=0;
   char CMGS_Str[8]= "+CMGS:";
   char CMGR_str[8]= "+CMGR: ";
   char CMTI_str[8]= "+CMTI:";
   char CLIP_str[8]= "+CLIP:";
   char Luz_Str[8]= "Luz";
   char Alarma_Str[8]= "Alarma";
   char symbol[2] = ">";
   char OK[3]="OK";
   
   output_low(LED_GSM_OK);  
     switch(Gsm.state)
     {
      case Funcionando_Gsm:
  
                              if(NULL != strstr(Buffer,CMTI_str))             //Cuando llega un mensaje
                              {
                                       pBuf=strstr(Buffer,CMTI_str);
                              
                                       delay_ms(100);
                                       printf("AT+CMGR=%c,0\r",*(pbuf+12));
                                       Timer_Stop(&Tmr_Uart);
                                       Clear_Buffer(); 
                              }                           
                              else if(NULL != strstr(Buffer,CMGR_str))        //Leemos el mensaje que llego y almacenamos el numero
                              {   
                                    /************Obtenemos el numero**************/
                                      strcpy(String,"+51\0");
                                      pBuf = strstr(Buffer,String);                               
                                      for(k=0; k<9;k++)   String[k]=*(pBuf+3+k);                          
                                      String[k]=0x00;
                                      k=0;
                                    /*********************************************/  
             
                                    /*****Buscamos uno de los modos disponibles****/
                                      if(strstr(Buffer,Luz_Str)!=NULL)
                                      {
                                       Casa_Fsm(Modo_Luz_Seleccionado);
                                       mode = 1;
                                      }
                                      else if(strstr(Buffer,Alarma_Str)!=NULL)
                                      {
                                       Casa_Fsm(Modo_Alarma_Seleccionado);
                                       mode = 2;
                                      }
                                      else
                                      {
                                       mode = 0;
                                      }
                                    /********************************************/  
                                      Clear_Buffer();        
                                      do{        
                                     //  restart_wdt();
                                       printf("at+cmgs=\"%s\"\r",&String[0]);
                                       delay_ms(100);
                                      }while(strstr(Buffer,symbol)==NULL);
                                     
                                      switch(mode)
                                      {
                                       case 0:printf("Comando Incorrecto %c\r",0x1A);break;
                                       case 1:printf("Luz Aut. Activada %c\r",0x1A);break;
                                       case 2:printf("Alarma Aut. Activada %c\r",0x1A);break;
                                      }    
                                      
                                      delay_ms(100);
                                      printf("%c\r",0x1A);
                                      delay_ms(100);                                                                                
                              }             

                              else if(NULL != strstr(Buffer,CLIP_str)) //Cuando llaman
                              {  
                                       pBuf = strstr(Buffer,CLIP_str);
                                       delay_ms(100);
                                       printf("ATH\r");
                                       
                                       for(k=0; k<9;k++)   String[k]=*(pBuf+8+k);                          
                                       String[k]=0x00;
                                       k=0;
                                       
                                       Casa_Fsm(Apagar_Alarma);  
                                       Clear_Buffer();   
                                       do{         
                                       // restart_wdt();
                                        printf("at+cmgs=\"%s\"\r",&String[0]);
                                        delay_ms(1000);
                                       }while(strstr(Buffer,symbol)==NULL);
                                       
                                       delay_ms(100);
                                       printf("SE APAGO LA ALARMA %c\r",0x1A);
                                       delay_ms(500);
                                       printf("%c\r",0x1A);
                                                            
                              }
                              else if(strstr(Buffer,CMGS_Str)!=NULL)
                              {
                                 output_high(LED_GSM_OK);       
                                 Clear_Buffer();
                                 do{
                                   // restart_wdt();
                                    printf("AT+CMGDA=\"DEL ALL\"\r");
                                    delay_ms(500);
                                 }while(strstr(Buffer,OK) == NULL); 
                              }
      
      break;
     }
     Clear_Buffer(); 
     Timer_Stop(&Tmr_Uart);
}
void AT_Generate(void)
{
   char String[8]="+CCALR:";

   char *pBuf = NULL;
   switch(Gsm.state)
   {
      case Gsm_Activado:
      
          Clear_Buffer();
          do{
               printf("AT+CCALR?\r");
               delay_ms(500);
               pBuf = strstr(Buffer,String);                                     
            }while(*(pBuf + 8) !='1');
         
          pBuf=NULL;
         // restart_wdt();
          
          strcpy(String,"+CREG:");
          Clear_Buffer();
          do{     
               printf("AT+CREG?\r");
               delay_ms(1000);
               pBuf = strstr(Buffer,String);                         
          }while(NULL == pBuf); 
          
         strcpy(String,"OK");
         
        // restart_wdt();
         Clear_Buffer();
         do{
               printf("AT+CMGF=1\r");
               delay_ms(500);
         }while(NULL==strstr(Buffer,String));
          
        // restart_wdt(); 
         Clear_Buffer();
         do{
               printf("AT+CMGDA=\"DEL ALL\"\r");
               delay_ms(500); 
         }while(NULL == strstr(Buffer,String));  
          
        // restart_wdt(); 
         Clear_Buffer();
         do{
               printf("AT+CLIP=1\r");
               delay_ms(500);                                                      
         }while(NULL== strstr(Buffer,String));           
         
        // restart_wdt();

         //Gsm_Sms_Broadcast(Sistema_Inicio_Str);
         
         Timer_Stop(&Tmr_Uart);
         output_high(LED_GSM_OK);
         Gsm.state = Funcionando_Gsm;
         
      break;   
   }
}


void Gsm_Sms_Broadcast(char* SMS)
{
   int TimeOut;
   char CMGS_Str[8]="+CMGS:";
   char symbol[2]= ">";
       
   while(Gsm.num_c < 4)
   {
      output_low(LED_GSM_OK);     
      delay_ms(100);
      
      if(Gsm.num_c == 0)  
      {
        do{
         memset(Buffer,0x00,sizeof(Buffer));
         i=0;                         
         printf("AT+CMGS=\"941175534\"\r");
         delay_ms(100);
        }while(strstr(Buffer,symbol)==NULL);
     
      }
      else if(Gsm.num_c == 1)
      {
        do{
         memset(Buffer,0x00,sizeof(Buffer));
         i=0;                         
         printf("AT+CMGS=\"957219770\"\r");
         delay_ms(100);
        }while(strstr(Buffer,symbol)==NULL);
      }
      else if(Gsm.num_c == 2)
      {
       do{
         memset(Buffer,0x00,sizeof(Buffer));
         i=0;                         
         printf("AT+CMGS=\"957219775\"\r");
         delay_ms(100);
        }while(strstr(Buffer,symbol)==NULL);
      }
      else if(Gsm.num_c == 3) 
      {
        do{
         memset(Buffer,0x00,sizeof(Buffer));
         i=0;                         
         printf("AT+CMGS=\"986861105\"\r");
         delay_ms(100);
        }while(strstr(Buffer,symbol)==NULL);
      }
                  
      Gsm.num_c++;         
      delay_ms(100);
      printf("%s\r",SMS);
      delay_ms(500);
      printf("%c\r",0x1A);
  
     // restart_wdt();
      Clear_Buffer();
      
      do
      {
         if(TimeOut++ > 100) break;
         delay_ms(200);
      }while(strstr(Buffer,CMGS_Str)==NULL);
     // restart_wdt();
      
      Clear_Buffer();
      output_high(LED_GSM_OK);
      
      TimeOut=0;     
      delay_ms(1000);
     // restart_wdt();
   }
   Gsm.num_c = 0;
   
   Clear_Buffer();
}


/***********************************Lib Resources****************************/

void Timer_Start(Timer *Tmr)
{
   Tmr->Time = Tmr->Interval;
   Tmr->En = 1;
}
void Timer_Stop(Timer *Tmr)
{
   Tmr->En = 0;
}
void Timer_Set_Interval(Timer *Tmr, unsigned int32 time)
{
   Tmr->Interval = time;
}
void Timer_Init(Timer *Tmr, unsigned int32 time)
{
   Tmr->Interval = time;
   Tmr->En = 0;
}
int Is_Timer_Elapsed(Timer *Tmr)
{
   if(!Tmr->Time && Tmr->En) 
   {
      Tmr->En = 0;
      return 1;
   }
   else return 0;
}

void Clear_Buffer(void)
{ 
   int k = 0;
   for(k=0;i<sizeof(Buffer);k++)
   {
      Buffer[k]=0x00;
   }
   i=0;
}




