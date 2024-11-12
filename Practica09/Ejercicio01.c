#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)


int contador=0;

//Función para escribir en uno de los displays haciendo uso del protocolo I2C
void escribir_i2c(){
  i2c_start();         //Inicia la comunicación, Pone el bit uno de start 
  //Escribe la dirección del esclavo en el bus y espera la respuesta (ACK)
  //Recordar que el 8vo bit es la orden! Por ejemplo la direccion aqui es 0100 001 0 <-este bit indica que se va  hacer una escritura
  i2c_write(0x42);     
  i2c_write(contador); //Después de la dirección, se le envia el dato al esclavo
  i2c_stop();          //Termina la comunicación
}

void main()
{
    while(true)
   {
    //Llama a la función escribir_i2c para mandar los datos al esclavo, que en este caso controla un display,
    //y manda los datos de la variable contador.
     escribir_i2c();
     delay_ms(500);
     contador++;
   }
}
