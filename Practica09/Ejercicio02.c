#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)


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
    while(true)
   {
    
    //Modificación del ejercicio 1. Manda el dato del contador también a través del puerto D
    escribir_i2c();
    output_d(contador); //Manda el valor de contador a través del puerto D
    delay_ms(500);

     contador++;
   }
}
