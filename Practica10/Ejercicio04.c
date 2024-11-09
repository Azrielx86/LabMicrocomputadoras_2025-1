#include <16F877a.h>
#device ADC=8
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

#include <i2c_LCD.c>

#define LCD_ADDR1 0X4E
#define NUM_ALUMNOS 4

//EJ3 -- El timer da máximo 13ms, por lo que para contar los 10 segundos debe 
// "desbordarse" 770 veces (10/0.013)


int contador;
int readFlag;
int nameFlag;
int16 contadorTimer1;
int16 contadorTimer2;
unsigned int lectura;
float voltaje;

#int_rtcc
timer_int()
{
   if(contadorTimer1 < 763){
      contadorTimer1++;
   }else{
      contadorTimer1 = 0; 
      readFlag=1;
   }
   
   if(contadorTimer2 < 1850){
      contadorTimer2++;
   }else{
      contadorTimer2 = 0;
      nameFlag = 1;
   }
}

#int_EXT
ext_int()
{
   contador++;
   output_d(contador);
}


void imprimeDisplay7Seg(){
   
   //Primero obtener el valor equivalente de la lectura: 99 = 255 ; 00 = 0; x = lect; x = lect*99/255
   //Convertir a long para evitar desbordamiento
   int16 lecturaLong = (long)lectura;
   
   //Multiplicar valor para obtener un numero en el rango [00,99]
   
   lecturaLong = lecturaLong*99/255;
   
   //VAriables para guardar cada uno de los digitos
   int firstDigit = 0;
   int secondDigit = 0;
   
   firstDigit = lecturaLong/10;
   secondDigit = lecturaLong%10;
   
   
   //hacer un shift del primer digito para pasarlo a la parte alta del registo
   
   firstDigit = firstDigit * 16;
   
   //Or con el segundo dígito para colocar su valor en la parte baja.
   firstDigit = firstDigit | secondDigit;
   
   
   output_d(firstDigit);
   
    
}

void printNames(char * nombre, char * numCuenta, int gpoTeo){
   printf("Nombre: \t\t%s  \n\r", nombre);
   printf("Num. Cuenta: \t\t%s   \n\r", numCuenta);
   printf("Grupo Teoria: \t\t %d \n\r", gpoTeo);
   printf("Grupo Lab: \t\t 2 \n\r", );
}

void config_inicial(){

     //Para el timer
   set_timer0(0);
   setup_counters(RTCC_INTERNAL, RTCC_DIV_256);
   setup_adc_ports(ALL_ANALOG);
   setup_adc(ADC_CLOCK_INTERNAL);
   set_adc_channel(0);
   
   //Habilitar interrupciones
   enable_interrupts(INT_RTCC);
   ext_int_edge(L_TO_H);
   enable_interrupts(INT_EXT);
   enable_interrupts(GLOBAL);
   
 
   
   
   lcd_init(LCD_ADDR1, 16, 2);
   output_d(0x00);
   
   lectura        = 0;
   contador       = 0;
   voltaje        = 0;
   contadorTimer1 = 0;
   contadorTimer2 = 0;
   readFlag       = 1; //Para que realice la primer lectura de forma immediata 
   nameFlag       = 1;
}

// 5v = 255 -> lectura*5/255

void main() {
   config_inicial();
   float constante = 5.0f/255.0f; //Cuidado con conversión de tipos
   char * nombres[NUM_ALUMNOS] = {"Edgar Chalico" , "Rodrigo Tapia", "Daniel San", "El otro wey"};
   char * cuentas[NUM_ALUMNOS] = {"6969696969", "4204204200", "0123456789", "1234567890"};
   int  gruposTeo[NUM_ALUMNOS] = {1,2,1,4};
   int i;
   while( TRUE ) {
   
      if(readFlag){
         delay_us(20);
         lectura = read_adc();
         voltaje = (constante*(float)lectura);
         
         lcd_gotoxy(1,1);
         lcd_putc('\f');
         printf(lcd_putc, "Voltaje: %0.2f ", voltaje);
         
         printf("\nLectura ADC\n\r");
         printf("Decimal: %u, Hexadecimal: %x \n\n\r", lectura, lectura);
         
         //output_d((int)lectura);
         imprimeDisplay7Seg();
         readFlag = 0;
         
         output_b(lectura);
      }//IF
      
      if(nameFlag){
         nameFlag = 0; 
         printf("==========================================\n\r");
         for(i=0; i<NUM_ALUMNOS; i++){
            printNames(nombres[i], cuentas[i], gruposTeo[i]);
         }
         printf("==========================================\n\r");
      }
      
   }//WHILE
   
}//MAIN
