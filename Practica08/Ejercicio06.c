#include <16f877.h>
#fuses HS, NOPROTECT
#use delay(clock = 20000000)
#org 0x1F00, 0x1FFF void loader16F877(void){}
#use rs232(baud = 9600, xmit = PIN_C6, rcv = PIN_C7)
#define loop while (1)

void main() {
  int last_input;
  int shift;
  int leds_on = 1;
  int i;
  char in;
  loop {
    if (kbhit() == 1) {
      in = getc();
    }

    switch (in) {
    case '0':
      output_b(0x00);
      break;
    case '1':
      output_b(0xFF);
      break;
    case '2':
      shift = 0x80;
      for (i = 0; i < 8; i++) {
        shift >>= 1;
        output_b(shift);
        delay_ms(200);
      }
      break;
    case '3':
      shift = 0x01;
      for (i = 0; i < 8; i++) {
        shift <<= 1;
        output_b(shift);
        delay_ms(200);
      }
      break;
    case '4':
      leds_on = leds_on == 0 ? 0xFF : 0;
      output_b(leds_on);
      delay_ms(500);
      break;
    }
  }
}
