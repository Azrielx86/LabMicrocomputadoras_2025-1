    PROCESSOR 16f877a
    INCLUDE <p16f877a.inc>

	ORG 0
	GOTO INICIO
	ORG 5

INICIO:
	CALL    CONFIG_INICIAL
LOOP:
	MOVLW   0x0F
	ANDWF   PORTA,W
	
	ADDWF   PCL,F
	GOTO EDO0
	GOTO EDO1
	GOTO EDO2
	GOTO EDO3
	GOTO EDO4
	GOTO EDO5
	GOTO EDO6
	GOTO EDO7
	GOTO EDO8

EDO0:
    CLRF    PORTC
    CLRF    PORTB
    GOTO LOOP
EDO1:
    MOVLW   0x04    ; Activa ENABLE_M2
    MOVWF   PORTC   ; Activa solo DIR1_M2
    MOVLW   0x08
    MOVWF   PORTB
    GOTO LOOP
EDO2:
    MOVLW   0x04
    MOVWF   PORTC   ; Activa ENABLE_M2
    MOVWF   PORTB   ; Activa solo DIR2_M2 (Usa el mismo bit)
    GOTO LOOP
EDO3:
    MOVLW   0x02
    MOVWF   PORTC   ; Activa ENABLE_M1
    MOVWF   PORTB   ; Activa solo DIR1_M1 (Usa el mismo bit)
    GOTO LOOP
EDO4:
    MOVLW   0x02
    MOVWF   PORTC   ; Activa ENABLE_M1
    MOVLW   0x01
    MOVWF   PORTB   ; Activa DIR2_M1
    GOTO LOOP
EDO5:
    MOVLW   0x06
    MOVWF   PORTC   ; Activa los dos motores
    MOVLW   0X0A
    MOVWF   PORTB   ; Activa DIR1_M1 y DIR1_M2
    GOTO LOOP
EDO6:
    MOVLW   0x06
    MOVWF   PORTC   ; Activa los dos motores
    MOVLW   0x05
    MOVWF   PORTB   ; Activa DIR2_M1 y DIR2_M2
    GOTO LOOP
EDO7:
    MOVLW   0x06
    MOVWF   PORTC   ; Activa los dos motores
    MOVWF   PORTB   ; Activa DIR1_M1 y DIR2_M2 (Usa el mismo bit)
    GOTO LOOP
EDO8:
    MOVLW   0x06
    MOVWF   PORTC   ; Activa los dos motores
    MOVLW   0x09
    MOVWF   PORTB   ; Activa DIR2_M1 y DIR1_M2
    GOTO LOOP

CONFIG_INICIAL:
	;Camio al banco 1
	BCF     STATUS, RP1	;RP1 = 0
	BSF     STATUS, RP0	;RP0 = 1
	
	;configura los pines del puerto B como salidas
	CLRF    TRISB			; TRISB = 0x00
	CLRF    TRISC
	MOVLW   0x06			; TRISA = 0x00
	MOVWF   ADCON1
	MOVLW   0x3F
	MOVWF   TRISA

	;Cambio al banco 0 
	BCF     STATUS, RP0	; RP0 = 0

	;Limpia el puerto B
	CLRF    PORTC
	CLRF    PORTB 		;PORTB = 0x00
	CLRF    PORTA

	RETURN

	END