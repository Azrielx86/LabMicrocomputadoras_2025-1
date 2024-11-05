#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#include <i2c_LCD.c>

#DEFINE LCD_ADDR 0X4E
#DEFINE KB_ADDR  0X45

#define READ_MASK 0x01

int contador=0;

//Función para escribir en uno de los displays haciendo uso del protocolo I2C
void escribir_i2c(){
  i2c_start();         //Inicia la comunicación, Pone el bit uno de start 
  i2c_write(0x42);     //Escribe la dirección del esclavo en el bus y espera la respuesta (ACK) 
  i2c_write(contador); //Después de la dirección, se le envia el dato al esclavo
  i2c_stop();          //Termina la comunicación
}

//Función para leer datos de un switch haciendo uso de I2C
void leer_i2c(){
   i2c_start();   //Inicia la comunicación, Pone el bit uno de start 
   //Escribe la dirección del esclavo en el bus y espera la respuesta (ACK) 
   //Se hace un OR con READ_MASK para encender el bit 0 de KB_ADDR ya que se hará una lectura
   i2c_write(KB_ADDR | READ_MASK);
   //Realiza la lectura y manda un NACK al esclavo para indicar que se terminó de leer. Guarda el dato en contador
   contador = i2c_read(0);
   i2c_stop();    //Termina la comunicación
}
void main()
{
   lcd_init(LCD_ADDR,16 ,2);  //Inicializa el LCD
    while(true)
   {
     leer_i2c();           //Lee el dato del teclado  
     escribir_i2c();       //Escribe el dato leido en un display
     
     //Escribe en el LCD y manda el dato a través del puerto D
     output_d(contador);   
     lcd_putc('\f');
     lcd_gotoxy(1,1);
     printf(lcd_putc, "UNAM\n");
     printf(lcd_putc, "Contador: %d", contador);

     delay_ms(500);

   }
}
