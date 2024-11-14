#include <16F877a.h>
#device ADC=8
#fuses HS,NOWDT,NOPROTECT
#use delay(clock=20000000)
#use i2c(MASTER, SDA=PIN_C4, SCL=PIN_C3,SLOW, NOFORCE_SW)
#use rs232(baud=9600, xmit=PIN_C6, rcv=PIN_C7)

#include <i2c_LCD.c>

#define LCD_ADDR1 0X4E
#define SWITCH_ADDR 0X40
