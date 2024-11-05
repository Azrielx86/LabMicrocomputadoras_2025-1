#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#include <i2c_LCD.c>

#DEFINE LCD_ADDR 0X4E

int contador=0;

//Función para escribir en uno de los displays haciendo uso del protocolo I2C
void escribir_i2c(){
  i2c_start();         //Inicia la comunicación, Pone el bit uno de start 
  i2c_write(0x42);     //Escribe la dirección del esclavo en el bus y espera la respuesta (ACK) 
  i2c_write(contador); //Después de la dirección, se le envia el dato al esclavo
  i2c_stop();          //Termina la comunicación
}
void main()
{
   //Función de la biblioteca i2c_LCD.c que sirve para inicializar el LCD 
   //Se envían como argumentos la dirección del dispositivo, el número de columnas (16) y de líneas(2) del display
   lcd_init(LCD_ADDR,16 ,2);   
    while(true)
   {
      //Modificación del ejercicio02. Envía los datos necesarios al LCD para imprimir una cadena  junto con el valor del contador que 
      //varía con cada iteración 
      escribir_i2c();     
      output_d(contador);       //Manda el valor de contador a través del puerto D
      lcd_putc('\f');           //Para limpiar el LCD
      lcd_gotoxy(1,1);          //Poner el cursor en la columna 1 de la fila 1.
      printf(lcd_putc, "UNAM\n");    //Imprime "UNAM" en la primera línea del LCD, \n coloca el cursor automáticamente en la segunda línea.
      printf(lcd_putc, "Contador: %d", contador);   //Imprime "contador:" en la segunda línea del LCD y luego el valor de contador
      delay_ms(500);

     contador++;
   }
}
