    PROCESSOR 16f877a
    INCLUDE <p16f877a.inc>

valor1 equ h'41'
valor2 equ h'42'
valor3 equ h'43'

	ORG 0
	GOTO INICIO
	ORG 5


INICIO:
	;Subrutina para configurar los puertos de I/O
	CALL CONFIG_INICIAL
LOOP:
	;Recupera los 3 bits menos significativos del puerto A y los suma al 
    ;Program counter latch para hacer un salto como un switch case
	;Casos que llevan a loop son opciones invalidas

	MOVLW 0x07
	ANDWF PORTA,W
	
	
	ADDWF PCL,F
	GOTO LOOP
	GOTO SERV_DER
	GOTO SERV_CEN
	GOTO LOOP
	GOTO SERV_IZQ
	GOTO LOOP
	GOTO LOOP
	GOTO LOOP
	GOTO LOOP

SERV_DER:
	;Se genera una señal PWM mediante el uso de retardos. Para este caso se debe
	; de mantener encendido durante 2.5 ms y apagado durante 18ms

	;Enciende todos los pines del puerto C
    MOVLW   0xFF
    MOVWF   PORTC

	;Retardo de 2.5ms
    CALL RETARDO_2ms
	CALL RETARDO_05ms

	;Apaga todos los pines del puerto C
    CLRF    PORTC

	;Retardo de 18ms
    CALL RETARDO_18ms

    GOTO LOOP
    
SERV_CEN:
	;Se genera una señal PWM mediante el uso de retardos. Para este caso se debe
	; de mantener encendido durante 1.5 ms y apagado durante 18.5ms
	
	;Enciende todos los pines del puerto C
    MOVLW   0xFF
    MOVWF   PORTC

	;retardo de 1.5ms
    CALL RETARDO_1ms
    CALL RETARDO_05ms

	;Apaga todos los pines del puerto C
    CLRF    PORTC

	;retardo de 18.5ms
    CALL RETARDO_05ms
    CALL RETARDO_18ms

    GOTO LOOP

SERV_IZQ:
	;Se genera una señal PWM mediante el uso de retardos. Para este caso se debe
	; de mantener encendido durante 0.5 ms y apagado durante 19.5ms

	;Enciende todos los pines del puerto C
    MOVLW   0xFF
    MOVWF   PORTC
	
	;Retardo de 0.5ms
    CALL RETARDO_05ms

	;Apaga todos los pines del puerto C
    CLRF    PORTC

	;retardo de 19.5ms
    CALL RETARDO_1ms
	CALL RETARDO_05ms
    CALL RETARDO_18ms

    GOTO LOOP

CONFIG_INICIAL:
	;Camio al banco 1
	BCF STATUS, RP1	
	BSF STATUS, RP0	
	
	;configura los pines del puerto B y C como salidas
	CLRF    TRISB       
	CLRF    TRISC       

	;Configura los pines del puerto A como salidas digitales
	MOVLW   0x06        
	MOVWF   ADCON1      
	MOVLW   0x3F
	MOVWF   TRISA

	;Cambio al banco 0 
	BCF STATUS, RP0

	;Limpia los puertos
	CLRF PORTB
	CLRF PORTA
	CLRF PORTC

	RETURN
	
RETARDO_18ms 
	MOVLW .255
	MOVWF valor1
dos_18: 
	MOVLW .118 ; 118
	MOVWF valor2
uno_18: 
	DECFSZ 	valor2
	GOTO 	uno_18
	DECFSZ 	valor1
	GOTO 	dos_18
	RETURN

RETARDO_1ms 
	MOVLW .150
	MOVWF valor1
dos_1: 
	MOVLW .11
	MOVWF valor2
uno_1: 
	DECFSZ 	valor2
	GOTO 	uno_1
	DECFSZ 	valor1
	GOTO 	dos_1
	RETURN

RETARDO_2ms 
	MOVLW .255
	MOVWF valor1
dos_2: 
	MOVLW .12
	MOVWF valor2
uno_2: 
	DECFSZ 	valor2
	GOTO 	uno_2
	DECFSZ 	valor1
	GOTO 	dos_2
	RETURN

RETARDO_05ms 
	MOVLW .82
	MOVWF valor1
dos_05: 
	MOVLW .10
	MOVWF valor2
uno_05: 
	DECFSZ 	valor2
	GOTO 	uno_05
	DECFSZ 	valor1
	GOTO 	dos_05
	RETURN

	END

loop_stay MACRO valuein,compare_with,ret_loop,inner_loop
    MOVLW   valuein
    XORWF   compare_with,W
    BTFSS   STATUS,Z
    GOTO    ret_loop
    GOTO    inner_loop
;ENDM