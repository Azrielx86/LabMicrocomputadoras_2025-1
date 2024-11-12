#include "proyecto-final.h"

unsigned int operando1;
unsigned int operando2; 
int resultado;
char operador;
int lectura_cad;

//InterrupciÛn del pin RB0
#int_EXT
ext_int()
{
   switch(operador){
      case '+':
         resultado = operando1 + operando2;
      break;
      
      case '-':
         resultado = operando1 - operando2;
      break;
      
      case '*':
         resultado = operando1 * operando2;
      break;
      
      case '/':
         resultado = operando1 / operando2;
      break;
      
      default:
         printf("Error\n\r");
      break;
   }
   
   printf("Operacion: %d %c %d = %d \n\r", operando1, operador, operando2, resultado);
}

//Realiza todas las configuraciones del micro para poder realizar los ejercicios de la pr√°ctica.
void config_inicial(){
   
   //Configuracion CAD
   setup_adc_ports(AN0);     
   setup_adc(ADC_CLOCK_INTERNAL);  
   set_adc_channel(0);  
   
   //InicializaciÛn del lcd i2c
   lcd_init(LCD_ADDR1, 16,2);

   ext_int_edge(L_TO_H);         //Interrupci√≥n externa en flanco de subida
   enable_interrupts(INT_EXT);   //habilita interrupci√≥n externa
   enable_interrupts(GLOBAL);    //Habilita interrupciones globales
   
   operando1 = 0;
   operando2 = 0; 
   resultado = 0;
   lectura_cad = 0;
}


void main() {

   //Configuraciones iniciales
   config_inicial();


   while( TRUE ) {
      
      operando1 = input_d();
      
      operando2 = operando1 & 0x0F;
      operando1 = operando1 & 0xF0;
      operando1 = operando1 / 16;
      
      lectura_cad = read_adc();
      
      if(lectura_cad <= 63){
         resultado = operando1 + operando2;
         operador = '+';
      }else if (lectura_cad <= 127){
         resultado = operando1 - operando2;
         operador = '-';
      }else if (lectura_cad <= 189){
         resultado = operando1 * operando2;
         operador = '*';
      }else{
         operador = '/';
         if(operando2 != 0)
            resultado = operando1 / operando2;
         else 
            resultado = -255;
      }
      
      
      lcd_gotoxy(1,1);
      lcd_putc('\f');
      printf(lcd_putc, "%d %c %d \n", operando1, operador,operando2);
      
      delay_ms(1000);
      
   }//WHILE
   
}//MAIN
