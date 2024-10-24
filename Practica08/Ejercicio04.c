#include <16f877.h>
#fuses HS,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#org 0x1F00, 0x1FFF void loader16F877(void){}

void main()
{
   while (1)
   {
      output_b(0xFF);
      printf("Todos los bits encendidos.\n");
      delay_ms(1000);
      output_b(0x00);
      printf("Todos los bits apagados.\n");
      delay_ms(1000);
   }
}

