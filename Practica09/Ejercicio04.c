#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#include <i2c_LCD.c>

#DEFINE LCD_ADDR 0X4E
#DEFINE KB_ADDR  0X45

#define READ_MASK 0x01

int contador=0;

void escribir_i2c(){
   i2c_start();//Pone el bit uno de start y además espera la respuesta del esclavo
   i2c_write(0x42);//REcordar que el 8vo bit es la orden! Por ejemplo la direccion aqui es 0100 001 0 <-este bit indica que se va  hacer una escritura
   i2c_write(contador);//Después de la dirección, se le evia la informacion
   i2c_stop();// Para terminar la comunicación
    }

void leer_i2c(){
   i2c_start();
   i2c_write(KB_ADDR | READ_MASK);
   contador = i2c_read(0);
   i2c_stop();
}
void main()
{
   lcd_init(LCD_ADDR,16 ,2);
    while(true)
   {
     leer_i2c();
     
     escribir_i2c();
     
     output_d(contador);
     lcd_putc('\f');
     lcd_gotoxy(1,1);
     printf(lcd_putc, "UNAM\n");
     printf(lcd_putc, "Contador: %d", contador);
     delay_ms(500);

     //contador++;
   }
}
