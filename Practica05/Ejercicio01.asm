    PROCESSOR 16f877a
    INCLUDE <p16f877a.inc>

	ORG 0
	GOTO INICIO
	ORG 5

INICIO:
	CALL    CONFIG_INICIAL
LOOP:
    ;Recupera los 4 bits menos significativos del puerto A y los suma al 
    ;Program counter latch para hacer un salto como un switch case
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
    ;Ambos motores detenidos, envía ceros a través de los puertos
    CLRF    PORTC
    CLRF    PORTB
    GOTO LOOP
EDO1:
    ;Motor 1 detenido, motor 2 gira en sentido horario
    MOVLW   0x04    ; Activa ENABLE_M2 
    MOVWF   PORTC   
    MOVLW   0x08    ; Activa solo DIR1_M2 
    MOVWF   PORTB
    GOTO LOOP
EDO2:
    ;Motor 1 detenido, motor 2 gira en sentido anti-horario
    MOVLW   0x04
    MOVWF   PORTC   ; Activa ENABLE_M2 
    MOVWF   PORTB   ; Activa solo DIR2_M2 
    GOTO LOOP
EDO3:
    ;Motor 1 gira en sentido horario, motor 2 detenido
    MOVLW   0x02
    MOVWF   PORTC   ; Activa ENABLE_M1 
    MOVWF   PORTB   ; Activa solo DIR1_M1 
    GOTO LOOP
EDO4:
    ;Motor 1 gira en sentido anti-horario, motor 2 detenido
    MOVLW   0x02
    MOVWF   PORTC   ; Activa ENABLE_M1
    MOVLW   0x01
    MOVWF   PORTB   ; Activa DIR2_M1
    GOTO LOOP
EDO5:
    ;Ambos motores en sentido horario
    MOVLW   0x06
    MOVWF   PORTC   ; Activa los dos motores
    MOVLW   0X0A   
    MOVWF   PORTB   ; Activa DIR1_M1 y DIR1_M2
    GOTO LOOP
EDO6:
    ;Ambos motores en sentido anti-horario
    MOVLW   0x06
    MOVWF   PORTC   ; Activa los dos motores
    MOVLW   0x05
    MOVWF   PORTB   ; Activa DIR2_M1 y DIR2_M2
    GOTO LOOP
EDO7:
    ;motor 1 en sentido horario, motor 2 en anti-horario
    MOVLW   0x06
    MOVWF   PORTC   ; Activa los dos motores
    MOVWF   PORTB   ; Activa DIR1_M1 y DIR2_M2 (Usa el mismo bit)
    GOTO LOOP
EDO8:
    ;motor 2 en sentido horario, motor 1 en anti-horario
    MOVLW   0x06
    MOVWF   PORTC   ; Activa los dos motores
    MOVLW   0x09
    MOVWF   PORTB   ; Activa DIR2_M1 y DIR1_M2
    GOTO LOOP

CONFIG_INICIAL:
	;Camio al banco 1
	BCF     STATUS, RP1	
	BSF     STATUS, RP0	
	
	;configura los pines del puerto B y C como salidas
	CLRF    TRISB		
	CLRF    TRISC

    ;configura los pines del puerto A como salidas digitales
	MOVLW   0x06			
	MOVWF   ADCON1
	MOVLW   0x3F
	MOVWF   TRISA

	;Cambio al banco 0 
	BCF     STATUS, RP0	

	;Limpia los puertos
	CLRF    PORTC
	CLRF    PORTB 		;PORTB = 0x00
	CLRF    PORTA

	RETURN

	END