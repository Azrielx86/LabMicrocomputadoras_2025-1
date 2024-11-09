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

void escribir_i2c(){
   
}



void config_inicial(){

   setup_adc_ports(ALL_ANALOG);
   setup_adc(ADC_CLOCK_INTERNAL);
   set_adc_channel(0);
   ext_int_edge(L_TO_H);
   enable_interrupts(INT_EXT);
   enable_interrupts(GLOBAL);
   
   // lcd_init(LCD_ADDR, 16, 2);
   output_d(0x00);
}

// 5v = 255 -> lectura*5/255

void main() {
   config_inicial();
   float constante = 5/255;
  
   lectura = 0;
   while( TRUE ) {
   
      delay_us(20);
      lectura = read_adc();
      voltaje = (constante*lectura);
      
      delay_ms(500);
      
      // lcd_gotoxy(1,1);
      // lcd_putc('\f');
      // printf(lcd_putc, "Volatje: %0.1f ", voltaje);
      
      printf("Decimal: %u, Hexadecimal: %x\n", lectura, lectura);
      
      output_d((int)lectura);
   
   }
}
