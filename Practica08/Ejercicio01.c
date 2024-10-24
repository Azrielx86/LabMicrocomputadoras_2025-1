#include <16f877.h>
#fuses HS,NOPROTECT
#use delay(clock=20000000)
#org 0x1F00, 0x1FFF void loader16F877(void){}

void main()
{
   while (1)
   {
      output_b(0x01);
      delay_ms(1000);
      output_b(0x00);
      delay_ms(1000);
   }
}
