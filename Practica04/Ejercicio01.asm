processor 16f877
include <p16f877.inc>

;Definicion de Variables y constantes para
;La rutina de retardo
;Variables, representan direcciones de memoria
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'

	ORG 0
	GOTO INICIO
	ORG 5

INICIO:
	;Subrutina para configurar los puertos de I/O
	CALL CONFIG_INICIAL
LOOP:
	MOVLW 0x01
	ANDWF PORTA,W
	
	;Switch case, suma el valor de W al program counter latch para brincar
	; a alguna de las etiquetas de salto
	ADDWF PCL,F
	GOTO APAGA
	GOTO ENCIENDE
ENCIENDE:
	MOVLW 0xFF
	MOVWF PORTB
	GOTO LOOP
APAGA:
	CLRF PORTB
	GOTO LOOP
	

CONFIG_INICIAL:
	;Cambio al banco 1
	BCF STATUS, RP1	;RP1 = 0
	BSF STATUS, RP0	;RP0 = 1
	
	;configura los pines del puerto B como salidas
	CLRF TRISB			; TRISB = 0x00
	MOVLW 0x06			; TRISA = 0x00
	MOVWF ADCON1
	MOVLW 0x3F
	MOVWF TRISA

	;Cambio al banco 0 
	BCF STATUS, RP0	; RP0 = 0

	;Limpia el puerto B
	CLRF PORTB 		;PORTB = 0x00
	CLRF PORTA

	RETURN

END: