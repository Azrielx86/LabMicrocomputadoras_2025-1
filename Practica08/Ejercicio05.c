#include <16f877.h>
#fuses HS,NOPROTECT
#use delay(clock=20000000)
#include<lcd.c>

void main()
{
   while (TRUE)
   {
      lcd_gotoxy(1, 1);
      printf(lcd_putc, "UNAM\n");
      lcd_gotoxy(1, 2);
      printf(lcd_putc, "FI\n");
      delay_ms(300);
   }
}

