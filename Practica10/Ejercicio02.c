#include <16F877a.h>
#device ADC=8
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

#include <i2c_LCD.c>

#define LCD_ADDR 0X4E


int contador;
unsigned int lectura;
float voltaje;
#int_EXT
ext_int()
{
   contador++;
   output_d(contador);
}

void imprimeDisplay7Seg(){
   
   //Primero obtener el valor equivalente de la lectura: 99 = 255 ; 00 = 0; x = lect; x = lect*99/255
   //Convertir a long para evitar desbordamiento
   int16 lecturaLong = (long)lectura;
   
   //Multiplicar valor para obtener un numero en el rango [00,99]
   
   lecturaLong = lecturaLong*99/255;
   
   //VAriables para guardar cada uno de los digitos
   int firstDigit = 0;
   int secondDigit = 0;
   
   firstDigit = lecturaLong/10;
   secondDigit = lecturaLong%10;
   
   
//!   int output;
//!   
//!   output = 0;
//!   
//!   output = output | secondDigit;
   
   //hacer un shift del primer digito para pasarlo a la parte alta del registo
   
   firstDigit = firstDigit * 16;
   
   firstDigit = firstDigit | secondDigit;
   
//!   output = output | firstDigit;
   
   output_d(firstDigit);
   
    
}

void config_inicial(){

   setup_adc_ports(ALL_ANALOG);
   setup_adc(ADC_CLOCK_INTERNAL);
   set_adc_channel(0);
   ext_int_edge(L_TO_H);
   enable_interrupts(INT_EXT);
   enable_interrupts(GLOBAL);
   
   lcd_init(LCD_ADDR, 16, 2);
   output_d(0x00);
   
   lectura = 0;
   contador = 0;
   voltaje = 0;
}

// 5v = 255 -> lectura*5/255

void main() {
   config_inicial();
   float constante = 5.0f/255.0f; //Cuidado con conversión de tipos
  
   while( TRUE ) {
   
      delay_us(20);
      lectura = read_adc();
      voltaje = (constante*(float)lectura);
      
      lcd_gotoxy(1,1);
      lcd_putc('\f');
      printf(lcd_putc, "Voltaje: %0.2f ", voltaje);
      
      delay_ms(500);
      
      printf("Decimal: %u, Hexadecimal: %x \n\r", lectura, lectura);
      
      //output_d((int)lectura);
      imprimeDisplay7Seg();
   }
}
