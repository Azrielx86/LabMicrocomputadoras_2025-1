#include <16F877.h>
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7) 

int contador;

#int_EXT // Interrupción de detección del flanco en RB0.
ext_int()
{
   contador++; // Incrementa en 1 el contador.
   output_d(contador); // Muestra la salida en el display de 7 segmentos.
}

void main()
{
   ext_int_edge(L_TO_H); // Establece que se detecte el flanco de subida en RB0
   enable_interrupts(INT_EXT); // Habilita la interrupción de RB0.
   enable_interrupts(GLOBAL); // Habilita las interrupciones globales.
   output_d(0x00); // Muestra en 0 el display de 7 segmentos.
   while( TRUE ) {} // Ciclo principal.
}
