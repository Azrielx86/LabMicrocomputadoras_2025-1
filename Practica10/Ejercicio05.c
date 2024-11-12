#include <16F877.h> 
#fuses HS,NOWDT,NOPROTECT 
#use delay(clock=20000000) 
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)

#include <i2c_LCD.c>

#define LCDi2c_ADDR 0x4E

int contador_d = 0; // Contador para el contador del ciclo principal.
int contador_rb0 = 0; // Contador para los eventos en RB0.
int contador_usart = 0; // Contador para los eventos del módulo USART.
int contador_rb = 0; // Contador para los eventos en RB4-RB7.
int contador_t0 = 0; // Contador para las interrupciones del timer0.

int last_rb = 0; // Para comparar la entrada anterior de RB[4:7]

/*
 * Interrupción para la detección de los flancos de subida en RB0,
 * muestra el resultado en el display de 7 segmentos conectado al PC8574.
*/
#INT_EXT
int_ext_rb0()
{
   contador_rb0++; // Incrementa en 1 el contador.
   i2c_start(); // Comienza la comunicación I2C.
   i2c_write(0x42); // Envía la dirección del display de 7 segmentos.
   i2c_write(contador_rb0); // Envía el dato que debe de mostrar.
   i2c_stop(); // Detiene la comunicación I2C.
   return 0;
}

/*
 * Interrupción para la entrada de datos por el módulo USART.
 * Muestra un mensaje enviado a la terminal por USART.
*/
#INT_RDA
int_usart_in()
{
   contador_usart++; // Incrementa en 1 el contador de eventos USART.
   // Muestra el mensaje en la terminal USART.
   printf("Se han recibido %d mensajes\n", contador_usart);
   getch(); // Lee el dato recibido, solo para limpiar la bandera de la
            // interrupción.
   return 0;
}

/*
 * Interrupción para la detección de eventos en RB[4:7].
 * Muestra el cambio respecto el último valor registrado.
*/
#INT_RB
port_rb()
{
   int rb = input_b(); // Redibe la entrada del puerto B.
   contador_rb++; // Incrementa en 1 el contador.
   // Muestra el mensaje en la terminal por USART.
   printf("Cambio en el puerto B: %x. (%d veces)\n", rb & 0xF0 ^ last_rb, contador_rb);
   last_rb = rb; // Registra el nuevo valor de RB[4:7].
   return 0;
}

/*
 * Interrupción para la detección del desbordamiento del TIMER0.
 * Muestra el contador en el display LCD por I2C.
*/
#INT_RTCC
clock_isr()
{
   contador_t0++; // Incrementa en 1 el contador.
   delay_ms(200); // Espera 200ms.
   lcd_gotoxy(1,1); // Posiciona el cursor en (1,1) del display.
   lcd_putc('\f'); // Limpia la pantalla.
   printf(lcd_putc, "Contador: %d", contador_t0); // Muestra el mensaje.
   return 0;
}

void main ()
{
   set_timer0(0); // Habilita el TIMER0.
   setup_counters(RTCC_INTERNAL,RTCC_DIV_256); //Fuente de reloj y pre-divisor.
   enable_interrupts(INT_RTCC); // Habilita interrupción por TIMER0.
   enable_interrupts(INT_EXT); // Habilita las interrupciones de RB0.
   enable_interrupts(INT_RDA); // Habilita las interrupciones del módulo USART.
   enable_interrupts(INT_RB); // Habilita las interrupciones de RB[4:7].
   enable_interrupts(GLOBAL); //Habilita interrupciones generales.
   lcd_init(LCDi2c_ADDR,16 ,2); // Inicializa el LCD I2C.

 
   int asc = 0; // 1 = descendente, 0 = ascendente.
   for (;;)
   {
      if (asc == 0)
      {
         contador_d++; // Incrementa en 1 el contador
         if (contador_d >= 20) // Comprueba si es igual o mayor a 20,
            asc = 1;           // si es verdadero, cambia la cuenta descendente
      }
      else
      {
         contador_d--; // Decrementa en 1 el contador.
         if (contador_d <= 0) // Comprueba si es igual o menor a 0.
            asc = 0;          // si es verdadero, cambia la cuenta a ascendente
      }
   
      output_d(contador_d); // Muestra el contador en el puerto D.
      delay_ms(1000); // Retraso de 1 s.
   }
}
