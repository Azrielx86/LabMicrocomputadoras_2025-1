// Author:        Edgar Moreno Chalico
// Descripci�n:   BLINK!!!!!!!!!!
// No se requiere configurar puertos.
// El ejecutable resultante es m�s grande
#include <16F877.h>
#fuses HS, NOWDT, NOPROTECT, NOLVP
#use delay(clock = 20000000)
#org 0x1F00, 0x1FFF void loader16F877(void){}
// #define use_portb_lcd //4 bits de datos
#include <lcd.c>
void main()
{
  lcd_init(); // Se inicializa el lcd.

  int cont = 0;

  while (TRUE)
  {
    if (input(PIN_A0) == 1) // Si recibe una entrada al pin A0
      cont++;               // se incrementa el contador

    lcd_gotoxy(5, 1); // Va a la columna 5, fila 1.
    printf(lcd_putc, " %d \n ", cont); // Imprime el contador en decimal.
    lcd_gotoxy(5, 2); // Va a la columna 5, línea 2.
    printf(lcd_putc, " %02x \n ", cont); // Imprime el contador en hex.
    delay_ms(1500); // Espera 1500ms.
  }
}
