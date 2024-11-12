#include <16F877a.h>
#device ADC=8
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

#include <i2c_LCD.c>

#define LCD_ADDR 0X4E


int contador;   //Contador para ejemplo con interrupciones
unsigned int lectura;   //VAriable no signada para guardar la lectura del CAD
float voltaje;  //Para guardar el dato del CAD pero ahora convertido a su equivalente en volts
int readFlag;  //Bandera para controlar la lectura de los datos
int16 contadorTimer; //contador para llevar el registro de veces que el timer0 se ha desbordado

//Interrupción del timer0
//NOTA: EJ3 -- El timer da máximo 13ms, por lo que para contar los 10 segundos debe 
// "desbordarse" 770 veces (10/0.013)
#int_rtcc
timer_int()
{
   //Incrementa el contador si todavia no han pasado los 10 segundos, resetea el contador y prende la bandera  de lectura
   if(contadorTimer < 763){
      contadorTimer++;
   }else{
      contadorTimer = 0; 
      readFlag=1;
   }
}

//Interrupción del pin RB0
#int_EXT
ext_int()
{
   contador++;
   output_d(contador);
}

//Función que convierte el resultado de la lectura del cad a un valor en el rango de [00, 99]
//Realiza la conversión a BCD para después mandarlo a uno de los displas mediante el puerto paralelo.
void imprimeDisplay7Seg(){
   
   //Primero obtener el valor equivalente de la lectura: 99 = 255 ; 00 = 0; x = lect; x = lect*99/255
   //Convertimos a long para evitar desbordamiento
   int16 lecturaLong = (long)lectura;
   
   //Multiplicar valor para obtener un numero en el rango [00,99]
   lecturaLong = lecturaLong*99/255;
   
   //Variables para guardar cada uno de los digitos
   int firstDigit = 0;
   int secondDigit = 0;
   
   firstDigit = lecturaLong/10;  //El primer dígito es el resultado de la división entera entre 10
   secondDigit = lecturaLong%10; //El segundo digito es el residuo de la división entera entre 10
   
   
   //Hacer un Shift a la izquierda del primer digito 4 veces para pasarlo a la parte alta del registo
   firstDigit = firstDigit * 16;    //multiplicar por 16 es igual a hacer el shift 4 veces.
   
   //Se hace una operación OR con el segundo dígito para colocar su valor en la parte baja.
   firstDigit = firstDigit | secondDigit;
   
   //Se envía el dato por el puerto paralelo.
   output_d(firstDigit);
     
}

//Realiza todas las configuraciones del micro para poder realizar los ejercicios de la práctica.
void config_inicial(){

   //Configuración del CAD
   setup_adc_ports(ALL_ANALOG);     //Todas los pines analógicos
   setup_adc(ADC_CLOCK_INTERNAL);   //utilizar el reloj interno
   set_adc_channel(0);              //Utilizar el canal 0

   //Configuración el timer
   set_timer0(0); //Inicializado en 0
   setup_counters(RTCC_INTERNAL, RTCC_DIV_256); //Utiliza el reloj interno con un preescalado de 256

   
   //Configuración de interrupciones
   enable_interrupts(INT_RTCC);  //Habilita la interrupción del timer0
   ext_int_edge(L_TO_H);         //Interrupción externa en flanco de subida
   enable_interrupts(INT_EXT);   //habilita interrupción externa
   enable_interrupts(GLOBAL);    //Habilita interrupciones globales
    
   //Inicializa el LCD con la dirección del dispositivo, No. de columnas y No. de filas
   lcd_init(LCD_ADDR1, 16, 2);      
   output_d(0x00);   //Inicializa en 0 el puerto D
   
   //Inicializa todas las variables utilizadas.
   lectura        = 0;
   contador       = 0;
   voltaje        = 0;
   contadorTimer  = 0;
   readFlag       = 1; //1 Para que realice la primer lectura de forma immediata 
}


void main() {
   
   //Configuraciones iniciales
   config_inicial();
   
   // PAra convertir la lectura a volts: 5v = 255; x = lectura -> x = lectura*5/255
   float constante = 5.0f/255.0f; //Factor de conversion para una resolución de 8 bits
  
   while( TRUE ) {
   
      //Revisa la bandera de lectura para saber si se debe realizar la lectura del CAD o no.
      if(readFlag){

         delay_us(20);

         //Lectura de los datos del CAD
         lectura = read_adc();
         voltaje = (constante*(float)lectura);
         
         //Imprime el dato del voltaje en el LCD
         lcd_gotoxy(1,1);
         lcd_putc('\f');
         printf(lcd_putc, "Voltaje: %0.2f ", voltaje);

         //Imprime el resultado de la lectura en la terminal
         printf("Decimal: %u, Hexadecimal: %x \n\r", lectura, lectura);
         
         
         //Llama a la función para imprimir el resultado en el display de 7 segmentos
         imprimeDisplay7Seg();

         //Apaga la bandera de lectura.
         readFlag = 0;
      }
         
   }
}
