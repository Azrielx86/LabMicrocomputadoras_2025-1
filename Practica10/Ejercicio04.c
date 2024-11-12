#include <16F877a.h>
#device ADC=8
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

#include <i2c_LCD.c>

#define LCD_ADDR1 0X4E
#define NUM_ALUMNOS 4



int contador;   //Contador para ejemplo con interrupciones
unsigned int lectura;   //VAriable no signada para guardar la lectura del CAD
float voltaje;  //Para guardar el dato del CAD pero ahora convertido a su equivalente en volts
int readFlag;  //Bandera para controlar la lectura de los datos
int nameFlag;  //Bandera para controlar la impresion de los datos del equipo
//contador para llevar el registro de veces que el timer0 se ha desbordado para el tiempo de 10 segundos
int16 contadorTimer1; 
 //contador para llevar el registro de veces que el timer0 se ha desbordado para el tiempo de 25 segundos
int16 contadorTimer2;

//Interrupción del timer0
#int_rtcc
timer_int()
{

   //El timer da máximo 13ms, por lo que para contar los 10 segundos debe 
   // "desbordarse" 770 veces (10/0.013)
   //Incrementa el contador si todavia no han pasado los 10 segundos, resetea el timer y prende la bandera  de lectura
   if(contadorTimer1 < 763){
      contadorTimer1++;
   }else{
      contadorTimer1 = 0; 
      readFlag=1;
   }
   //El timer da máximo 13ms, por lo que para contar los 10 segundos debe 
   // "desbordarse" aprox 1930 veces (25/0.013)
   //Incrementa el contador si todavia no han pasado los 25 segundos
   //resetea el contador y prende la bandera  de nombres
   if(contadorTimer2 < 1850){
      contadorTimer2++;
   }else{
      contadorTimer2 = 0;
      nameFlag = 1;
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

//Para imprimir los datos de los alumnos en terminal.
void printNames(char * nombre, char * numCuenta, int gpoTeo){
   printf("Nombre: \t\t%s  \n\r", nombre);
   printf("Num. Cuenta: \t\t%s   \n\r", numCuenta);
   printf("Grupo Teoria: \t\t %d \n\r", gpoTeo);
   printf("Grupo Lab: \t\t 8 \n\r", );
}

//Realiza todas las configuraciones del micro para poder realizar los ejercicios de la práctica.
void config_inicial(){

   //Configuración del CAD
   setup_adc_ports(ALL_ANALOG);     //Todas los pines analógicos
   setup_adc(ADC_CLOCK_INTERNAL);   //utilizar el reloj interno
   set_adc_channel(0);  

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
   contadorTimer1 = 0;
   contadorTimer2 = 0;
   readFlag       = 1; //Para que realice la primer lectura de forma immediata 
   nameFlag       = 1;//Para que realice la primera impresión de datos de forma immediata 
}


void main() {

   //Configuraciones iniciales
   config_inicial();

   // PAra convertir la lectura a volts: 5v = 255; x = lectura -> x = lectura*5/255
   float constante = 5.0f/255.0f; //Factor de conversion para una resolución de 8 bits

   //Arreglos con los datos de los alumnos 
   char * nombres[NUM_ALUMNOS] = {"Edgar Chalico" , "Rodrigo Tapia", "Daniel Flores", "Adrian Cruz"};
   char * cuentas[NUM_ALUMNOS] = {"318192950", "313044270", "318187952", "318103273"};
   int  gruposTeo[NUM_ALUMNOS] = {1,2,1,4};

   int i; //Contador para ciclos
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
         printf("\nLectura ADC\n\r");
         printf("Decimal: %u, Hexadecimal: %x \n\n\r", lectura, lectura);
         
         //Llama a la función para imprimir el resultado en el display de 7 segmentos
         imprimeDisplay7Seg();
         
         //Manda el valor de la lectura en binario a través de puerto B
         output_b(lectura);

         //Apaga la bandera de lectura.
         readFlag = 0;
      }//IF
      
      if(nameFlag){
         //Apaga la bandera de nombres.
         nameFlag = 0; 
         printf("==========================================\n\r");
         //imprime los datos del equipo mediante una función.
         for(i=0; i<NUM_ALUMNOS; i++){
            printNames(nombres[i], cuentas[i], gruposTeo[i]);
         }
         printf("==========================================\n\r");
      }
      
   }//WHILE
   
}//MAIN
