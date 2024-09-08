processor 16f877
include <p16f877.inc>

SALIDA EQU 0x20

valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
cte1 equ 20h
cte2 equ 50h
cte3 equ 60h
	ORG 0
	GOTO INICIO
	ORG 5

INICIO:

	CALL CONFIG_INICIAL
RST:
	MOVLW 0x01
	MOVWF SALIDA
LOOP:
	BCF	STATUS,C
	
	MOVF SALIDA,W
	MOVWF PORTB
	RLF SALIDA
	CALL RETARDO_500ms
	BTFSC STATUS,Z
	GOTO RST
	GOTO LOOP

CONFIG_INICIAL:
	;Camio al banco 1
	BCF STATUS, RP1
	BSF STATUS, RP0
	
	CLRF TRISB ;configura los pines del puerto B como salida
	CLRF PORTB

	;Cambio al banco 0
	BCF STATUS, RP0
	RETURN

RETARDO_500ms 
	MOVLW .50
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
END: