#include <16F877.h> 
#fuses HS,NOWDT,NOPROTECT 
#use delay(clock=20000000) 
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)

#include <i2c_LCD.c>

#define LCDi2c_ADDR 0x4E

int contador_d = 0;
int contador_rb0 = 0;
int contador_usart = 0;
int contador_rb = 0;
int contador_t0 = 0;

int last_rb = 0;

#INT_EXT
int_ext_rb0()
{
   contador_rb0++;
   i2c_start();
   i2c_write(0x42);
   i2c_write(contador_rb0);
   i2c_stop();
   return 0;
}

#INT_RDA
int_usart_in()
{
   contador_usart++;
   printf("Se han recibido %d mensajes\n", contador_usart);
   getch();
   return 0;
}

#INT_RB
port_rb()
{
   int rb = input_b();
   contador_rb++;
   printf("Cambio en el puerto B: %x. (%d veces)\n", rb & 0xF0, contador_rb);
   last_rb = rb;
   return 0;
}

#INT_RTCC
clock_isr()
{
   contador_t0++;
   delay_ms(200);
   lcd_gotoxy(1,1);
   lcd_putc('\f');
   printf(lcd_putc, "Contador: %d", contador_t0);
   return 0;
}

void main ()
{
   set_timer0(0);
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256); //Fuente de reloj y pre-divisor 
   enable_interrupts(INT_RTCC); //Habilita interrupción por TIMER0 
   enable_interrupts(INT_EXT);
   enable_interrupts(INT_RDA);
   enable_interrupts(INT_RB);
   enable_interrupts(GLOBAL); //Habilita interrupciones generales
   lcd_init(LCDi2c_ADDR,16 ,2);

 
   int asc = 0;
   for (;;)
   {
      if (asc == 0)
      {
         contador_d++;
         if (contador_d >= 20)
            asc = 1;
      }
      else
      {
         contador_d--;
         if (contador_d <= 0)
            asc = 0;
      }
   
      output_d(contador_d);
      delay_ms(1000);
   }
}
