processor 16f877
include <p16f877.inc>

SALIDA EQU 0x20

valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 80h
cte2 equ 50h
cte3 equ 60h
	ORG 0
	GOTO INICIO
	ORG 5

INICIO:

	CALL CONFIG_INICIAL

LOOP:
	;Prende el led
	;MOVLW 0x01
	;MOVWF PORTB
	;BSF PORTB, 0
	MOVLW 0XFF
	MOvWF PORTB
	CALL RETARDO_500ms
	;apaga el led
	;BCF PORTB, 0
	CLRF PORTB
	CALL RETARDO_500ms
	GOTO LOOP

CONFIG_INICIAL:
	;Camio al banco 1
	BCF STATUS, RP1
	BSF STATUS, RP0
	
	CLRF TRISB ;configura los pines del puerto B como salida

	;Cambio al banco 0
	BCF STATUS, RP0
	CLRF PORTB
	RETURN

RETARDO_500ms 
	;MOVLW .50
	MOVLW cte1
	MOVWF valor1
tres:
	;MOVLW .200
	MOVLW cte2
	MOVWF valor2
dos: 
	;MOVLW .82
	MOVLW cte3
	MOVWF valor3
uno: 
	DECFSZ 	valor3
	GOTO 	uno
	DECFSZ 	valor2
	GOTO 	dos
	DECFSZ 	valor1
	GOTO 	tres
	RETURN
END: