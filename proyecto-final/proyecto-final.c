#include "proyecto-final.h"

unsigned int operando1;
unsigned int operando2; 
int16 resultado;
char operador;
int lectura_cad_operador;
int lectura_cad_base;
int pwm_duty;
int duty_flag;

//InterrupciÛn del pin RB0
#int_EXT
ext_int()
{
   switch(operador){
      case '+':
         resultado = (long)operando1 + (long)operando2;
      break;
      
      case '-':
         resultado = operando1 - operando2;
      break;
      
      case '*':
         resultado = (long)operando1 * (long)operando2;
      break;
      
      case '/':
         if(operando2 != 0)
            resultado = operando1 / operando2;
         else{
            printf("No se puede dividir entre cero! \n\r");
            return;
         }
      break;
      
      default:
         printf("Error\n\r");
      break;
   }
   
   if(lectura_cad_base > 127){
      printf("Operacion: %LX %c %LX = %4LX \n\r", operando1, operador, operando2, resultado);
      return;
   }
   
   printf("Operacion: %u %c %u = %lu \n\r", operando1, operador, operando2, resultado);
}

#int_rtcc
timer_int()
{
   
   if(duty_flag){
      pwm_duty = pwm_duty + 5;
   }else{
      pwm_duty = pwm_duty - 5;
   }
   
   if(pwm_duty == 255)
      duty_flag = 0;
   else if(pwm_duty == 0)
      duty_flag = 1;
   
   set_pwm1_duty(pwm_duty);
}


//Realiza todas las configuraciones del micro para poder realizar los ejercicios de la pr√°ctica.
void config_inicial(){

   operando1            = 0;
   operando2            = 0; 
   resultado            = 0;
   lectura_cad_operador = 0;
   lectura_cad_base     = 0;
   pwm_duty             = 0;
   duty_flag            = 1;
   
   //Configuracion CAD
   setup_adc_ports(ALL_ANALOG);     
   setup_adc(ADC_CLOCK_INTERNAL);  
   set_adc_channel(0);  
   
   //InicializaciÛn del lcd i2c
   lcd_init(LCD_ADDR1, 16,2);

   set_timer0(0); //Inicializado en 0
   setup_counters(RTCC_INTERNAL, RTCC_DIV_256); //Utiliza el reloj interno con un preescalado de 256

   enable_interrupts(INT_RTCC);
   ext_int_edge(L_TO_H);         //Interrupci√≥n externa en flanco de subida
   enable_interrupts(INT_EXT);   //habilita interrupci√≥n externa
   enable_interrupts(GLOBAL);    //Habilita interrupciones globales
     
   setup_ccp1(CCP_PWM);
   setup_timer_2(T2_DIV_BY_16,255,1);
   set_pwm1_duty(pwm_duty);
   
}

void leeri2c(){
   i2c_start();
   i2c_write(SWITCH_ADDR | 0x01);
   operando2 = i2c_read(0);
   i2c_stop();
}

void main() {

   //Configuraciones iniciales
   config_inicial();

   while( TRUE ) {
      
      operando1 = input_d();
      
      
      leeri2c();
      
      set_adc_channel(0); 
      delay_us(50);
      lectura_cad_operador = read_adc();
         
      set_adc_channel(1);  
      delay_us(50);
      lectura_cad_base = read_adc();
      
      
      if(lectura_cad_operador <= 63){
         operador = '+';
      }else if (lectura_cad_operador <= 127){
         operador = '-';
      }else if (lectura_cad_operador <= 189){
         operador = '*';
      }else{
         operador = '/';
      }
      
      
      lcd_gotoxy(1,1);
      lcd_putc('\f');
      
      if(lectura_cad_base <= 127){
         printf(lcd_putc, "[DEC]Operacion: \n");
         lcd_gotoxy(4,2);
         printf(lcd_putc, "%u %c %u ", operando1, operador,operando2);
      }else{
         printf(lcd_putc, "[HEX]Operacion: \n");
         lcd_gotoxy(4,2);
         printf(lcd_putc, "%X %c %X ", operando1, operador,operando2);
      }
      
      delay_ms(1000);
      
   }//WHILE
   
}//MAIN
