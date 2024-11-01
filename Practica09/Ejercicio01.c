#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)


int contador=0;

void escribir_i2c(){
   i2c_start();//Pone el bit uno de start y adem�s espera la respuesta del esclavo
   i2c_write(0x42);//REcordar que el 8vo bit es la orden! Por ejemplo la direccion aqui es 0100 001 0 <-este bit indica que se va  hacer una escritura
   i2c_write(contador);//Despu�s de la direcci�n, se le evia la informacion
   i2c_stop();// Para terminar la comunicaci�n
    }
    
//Para leer usar I2C_READ y asignarle el valor a la variable (lee el dato recibido), poner un cero en el argumento 
//para finalizar la comunicaci�n.

void main()
{
    while(true)
   {
     escribir_i2c();
     delay_ms(500);
     contador++;
   }
}
