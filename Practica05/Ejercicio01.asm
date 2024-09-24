    PROCESSOR 16f877a
    INCLUDE <p16f877a.inc>

SALIDA 	EQU 0x20
;Constantes con los valores para prender los
;leds de cada estado
EDO1 	EQU 0x41 ;0100 0001 verde1    = on; rojo2     = on 
EDO2 	EQU 0x21 ;0010 0001 amaril1o1 = on; rojo2     = on 
EDO3 	EQU 0x14 ;0001 0100 rojo1     = on; verde2    = on 
EDO4 	EQU 0x12 ;0001 0010 rojo1     = on; amarillo2 = on 

;Registros auxiliares para hacer el parpadeo del led
EDO1_Inv	EQU	0xBF
BLINKS	equ	0x24	;Contador para blinks
MASK	equ	0x25

REG1 equ 0x24
REG2 equ 0x25

	ORG 0
	GOTO INICIO
	ORG 5

INICIO:
	;Subrutina para configurar los puertos de I/O
	CALL CONFIG_INICIAL
	MOVF PARAM1,W
	CALL CONFIG_A
	CLRF REG1
	CLRF BLINKS
LOOP:
	MOVLW 0x07
	ANDWF PORTA,W
	
	ADDWF PCL,F
	GOTO APAGA
	; GOTO ENCIENDE
	; GOTO CORRI_R
	; GOTO CORRI_L
	; GOTO CORRI_LR
	; GOTO BLINK
	; GOTO LOOP
	; GOTO LOOP
	
    

CONFIG_INICIAL:
	;Camio al banco 1
	BCF STATUS, RP1	;RP1 = 0
	BSF STATUS, RP0	;RP0 = 1
	
	;configura los pines del puerto B como salidas
	CLRF TRISB			; TRISB = 0x00
	MOVLW 0x06			; TRISA = 0x00
	MOVWF ADCON1
	MOVLW 0x3F
	MOVWF TRISA
	
	; Configuracion del puerto C
	MOVLW   0x03
	MOVLW   TRISB

	;Cambio al banco 0 
	BCF STATUS, RP0	; RP0 = 0

	;Limpia el puerto B
	CLRF PORTB 		;PORTB = 0x00
	CLRF PORTA
	CLRF PORTC

	RETURN

    INCLUDE <../utils/utils.inc>
	END