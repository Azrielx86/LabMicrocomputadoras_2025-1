#include <16F877a.h>
#device ADC=8
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

#include <i2c_LCD.c>

#define LCD_ADDR 0X4E

//EJ3 -- El timer da m�ximo 13ms, por lo que para contar los 10 segundos debe 
// "desbordarse" 770 veces (10/0.013)


int contador;
int readFlag;
int16 contadorTimer;
unsigned int lectura;
float voltaje;

#int_rtcc
timer_int()
{
   if(contadorTimer < 763){
      contadorTimer++;
   }else{
      contadorTimer = 0; 
      readFlag=1;
   }
}

#int_EXT
ext_int()
{
   contador++;
   output_d(contador);
}

//Función que convierte el resultado de la lectura del cad a un valor en el rango de [00, 99]
//Realiza la conversión a BCD para después mandarlo a uno de los displas mediante el puerto paralelo.
void imprimeDisplay7Seg(){
   
   //Primero obtener el valor equivalente de la lectura: 99 = 255 ; 00 = 0; x = lect; x = lect*99/255
   //Convertimos a long para evitar desbordamiento
   int16 lecturaLong = (long)lectura;
   
   //Multiplicar valor para obtener un numero en el rango [00,99]
   lecturaLong = lecturaLong*99/255;
   
   //Variables para guardar cada uno de los digitos
   int firstDigit = 0;
   int secondDigit = 0;
   
   firstDigit = lecturaLong/10;  //El primer dígito es el resultado de la división entera entre 10
   secondDigit = lecturaLong%10; //El segundo digito es el residuo de la división entera entre 10
   
   
   //Hacer un Shift a la izquierda del primer digito 4 veces para pasarlo a la parte alta del registo
   firstDigit = firstDigit * 16;    //multiplicar por 16 es igual a hacer el shift 4 veces.
   
   //Se hace una operación OR con el segundo dígito para colocar su valor en la parte baja.
   firstDigit = firstDigit | secondDigit;
   
   //Se envía el dato por el puerto paralelo.
   output_d(firstDigit);
     
}

void config_inicial(){

     //Para el timer
   set_timer0(0);
   setup_counters(RTCC_INTERNAL, RTCC_DIV_256);
   setup_adc_ports(ALL_ANALOG);
   setup_adc(ADC_CLOCK_INTERNAL);
   set_adc_channel(0);
   
   //Habilitar interrupciones
   enable_interrupts(INT_RTCC);
   ext_int_edge(L_TO_H);
   enable_interrupts(INT_EXT);
   enable_interrupts(GLOBAL);
   
 
   
   
   lcd_init(LCD_ADDR, 16, 2);
   output_d(0x00);
   
   lectura        = 0;
   contador       = 0;
   voltaje        = 0;
   contadorTimer  = 0;
   readFlag       = 1; //Para que realice la primer lectura de forma immediata 
}

// 5v = 255 -> lectura*5/255

void main() {
   config_inicial();
   float constante = 5.0f/255.0f; //Cuidado con conversi�n de tipos
  
   while( TRUE ) {
   
   if(readFlag){
      delay_us(20);
      lectura = read_adc();
      voltaje = (constante*(float)lectura);
      
      lcd_gotoxy(1,1);
      lcd_putc('\f');
      printf(lcd_putc, "Voltaje: %0.2f ", voltaje);

      printf("Decimal: %u, Hexadecimal: %x \n\r", lectura, lectura);
      
      //output_d((int)lectura);
      imprimeDisplay7Seg();
      readFlag = 0;
   }
      
   }
}
