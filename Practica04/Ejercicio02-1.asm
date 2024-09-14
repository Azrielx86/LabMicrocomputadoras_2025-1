processor 16f877
include <p16f877.inc>

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

;Definicion de Variables y constantes para
;La rutina de retardo
;Variables, representan direcciones de memoria
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
;Constantes se utilizan como literales
cte1 equ 20h
cte2 equ 50h
cte3 equ 60h

REG1 equ 0x24
REG2 equ 0x25

	ORG 0
	GOTO INICIO
	ORG 5

INICIO:
	;Subrutina para configurar los puertos de I/O
	CALL CONFIG_INICIAL
	CLRF REG1
LOOP:
	MOVLW 0x07
	ANDWF PORTA,W
	
	ADDWF PCL,F
	GOTO APAGA
	GOTO ENCIENDE
	GOTO CORRI_R
	GOTO CORRI_L
	GOTO CORRI_LR
	;GOTO BLINK
	;GOTO LOOP
	;GOTO LOOP
ENCIENDE:
	MOVLW 0xFF
	MOVWF PORTB
	GOTO LOOP
APAGA:
	CLRF PORTB
	GOTO LOOP
CORRI_R:
	MOVLW 0x01
	MOVWF REG1
CORRI_R_LOOP:
	RLF	REG1,F
	MOVFW REG1
	MOVWF PORTB
	CALL RETARDO_500ms
	MOVLW 0x02
	XORWF PORTA,W
	BTFSS STATUS,Z
	GOTO LOOP
	GOTO CORRI_R_LOOP

CORRI_L:
	MOVLW 0x01
	MOVWF REG1
CORRI_L_LOOP:
	RRF	REG1,F
	MOVFW REG1
	MOVWF PORTB
	CALL RETARDO_500ms
	MOVLW 0x03
	XORWF PORTA,W
	BTFSS STATUS,Z
	GOTO LOOP
	GOTO CORRI_L_LOOP

CORRI_LR:
	MOVLW 0x01
	MOVWF REG1
	clrf REG2
CORRI_LR_LOOP:
	; CALL RETARDO_500ms
	MOVLW 0x04
	XORWF PORTA,W
	BTFSS STATUS,Z
	GOTO LOOP

	MOVFW REG1
	MOVWF PORTB

	MOVFW REG2
	ADDWF PCL, F		
	GOTO CORRI_LR_L
	GOTO CORRI_LR_R
CORRI_LR_R:
	RRF	REG1,F
	MOVLW 0X01
	XORWF REG1
	BTFSS STATUS,Z
	CLRF REG2
	GOTO CORRI_LR_LOOP
CORRI_LR_L:
	RLF	REG1,F
	MOVLW 0X80
	XORWF REG1,W
	BTFSC STATUS,Z
	GOTO CORRI_LR_LOOP
		;CLRF REG2
	MOVLW 0x01
	MOVWF REG2
	GOTO CORRI_LR_LOOP
	



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

	;Cambio al banco 0 
	BCF STATUS, RP0	; RP0 = 0

	;Limpia el puerto B
	CLRF PORTB 		;PORTB = 0x00
	CLRF PORTA

	RETURN

;Subrutina para retardo de 2seg
RETARDO_2000ms 
	MOVLW .200
	MOVWF valor1
tres:
	MOVLW .200
	MOVWF valor2
dos: 
	MOVLW .82
	MOVWF valor3
uno: 
	DECFSZ 	valor3
	GOTO 	uno
	DECFSZ 	valor2
	GOTO 	dos
	DECFSZ 	valor1
	GOTO 	tres
	RETURN
;Subrutina para retardo de 0.5seg
RETARDO_500ms 
	MOVLW .60
	MOVWF valor1
tres_500:
	MOVLW .200
	MOVWF valor2
dos_500: 
	MOVLW .82
	MOVWF valor3
uno_500: 
	DECFSZ 	valor3
	GOTO 	uno_500
	DECFSZ 	valor2
	GOTO 	dos_500
	DECFSZ 	valor1
	GOTO 	tres_500
	RETURN
END: