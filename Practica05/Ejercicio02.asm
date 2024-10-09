    PROCESSOR 16f877a
    INCLUDE <p16f877a.inc>

;Constantes con los valores necesarios para los pasos del motor
EDO1 	EQU 	0XC0 ;1100 0000
EDO2	EQU 	0X60 ;0110 0000 
EDO3 	EQU		0X30 ;0011 0000
EDO4 	EQU		0X90 ;1001 0000

;Contadores para llevar el registro del número de vueltas del motor
CONTADOR1 EQU 	0X22	
CONTADOR2 EQU 	0X23	

;constantes para los valores de retardo
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
	;Carga de valores a los contadores para los casos en que se necesita que el motor
	;gire un numero específico de vueltas
	MOVLW 	0XFF
	MOVWF 	CONTADOR1 ;carga 255 al contador 1, indica el número de pasos	
	
	;El contador 2 se ocupa para registrar la cantidad de medias vueltas que ha dado el motor
	CLRF	CONTADOR2 

	;Recupera los 3 bits menos significativos del puerto A y los suma al 
    ;Program counter latch para hacer un salto como un switch case
	MOVLW 	0x07
	ANDWF 	PORTA,W
	
	ADDWF 	PCL,F
	GOTO 	PARO
	GOTO 	HORARIO
	GOTO 	ANTIHORARIO
	GOTO 	CINCO_VUELTAS
	GOTO 	DIEZ_VUELTAS
	GOTO 	LOOP			;Este caso no se ocupa

GOTO LOOP

	
PARO:
	;Motor detenido, se envían ceros a los pines del puerto B
	CLRF 	PORTB
	CALL 	RETARDO_18ms
	GOTO 	LOOP

HORARIO:
	;Se utiliza la secuencia del manual para hacer que el motor gire en sentido horario.
	;Se enciende un par de bobinas a la vez enviando la señal correspondiente a través de
	;los pines del puerto B (pines 4-7) 

	;enciende bobinas A y B
	MOVLW 	EDO1
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	;enciende bobinas B y C
	MOVLW 	EDO2
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	;enciende bobinas C y D
	MOVLW 	EDO3
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	;enciende bobinas A y D
	MOVLW 	EDO4
	MOVWF 	PORTB
	CALL 	RETARDO_05ms
	
	;Revisa el contenido del puerto A para verificar si se seleccionó otra opción
	;si el valor es diferente de 01 vuelve al loop principal
	MOVLW  	0X01
	XORWF	PORTA,W	
	BTFSS 	STATUS,Z
	GOTO 	LOOP	
	GOTO 	HORARIO

ANTIHORARIO:
	;Se utiliza la secuencia del manual para hacer que el motor gire pero se invierte el orden
	;en el que se encienden las bobinas. Se enciende un par de bobinas a la vez enviando la señal 
	;correspondiente a través de los pines del puerto B (pines 4-7) 

	;enciende bobinas A y D
	MOVLW 	EDO4
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	;enciende bobinas C y D
	MOVLW 	EDO3
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	;enciende bobinas B y C
	MOVLW 	EDO2
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	;enciende bobinas A y B
	MOVLW 	EDO1
	MOVWF 	PORTB
	CALL 	RETARDO_05ms
	
	;Revisa el contenido del puerto A para verificar si se seleccionó otra opción
	;si el valor es diferente de 02 vuelve al loop principal
	MOVLW  	0X02
	XORWF	PORTA,W	
	BTFSS 	STATUS,Z
	GOTO 	LOOP	
	GOTO 	ANTIHORARIO

CINCO_VUELTAS
	;Utiliza el mismo metodo para hacer girar el motor que la opcion HORARIO
	;Para el control de vueltas se hace uso de dos contadores, el contador uno indica 
	;el número de pasos completos que se dan, se usa 255 (valor máximo para un registro de 8 bits)
	;Con este valor se da media vuelta. El contador 2 lleva el registro de medias vueltas que ha
	;dado el motor.

	;Revisa si el motor ya dio la cantidad de vueltas necesarias
	MOVLW 	0X0A	; 10 medias vueltas - > 5 vueltas
	XORWF	CONTADOR2,W
	BTFSC 	STATUS, Z	
	GOTO 	STOP

	;Revisa si el contador ya dio el máximo de pasos y, si es el caso, lo manda a resetear 
	MOVLW 	0X00
	XORWF	CONTADOR1,W
	BTFSC 	STATUS, Z	
	GOTO 	RES_CONT

GIRA:
	;Instrucciones para que el motor gire en sentido horario, revisar comentarios de la 
	;etiqueta HORARIO para explicación detallada.
	
	DECF	CONTADOR1
	
	MOVLW 	EDO1
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	MOVLW 	EDO2
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	MOVLW 	EDO3
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	MOVLW 	EDO4
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	GOTO CINCO_VUELTAS

STOP:
	;Se llega aquí una vez que se dio el numero de vueltas necesarias. En esta seleccionó
	;se apaga el motor y se revisa el contenido del puerto A para detectar si se selecciona
	;Otra opcion.

	CLRF 	PORTB ;Limpia el puerto B para detener el motor

	MOVLW  	0X03
	XORWF	PORTA,W	
	BTFSS 	STATUS,Z
	GOTO 	LOOP	
	GOTO 	STOP

RES_CONT	
	;Resetea el contador 1 e incremeta el contador 2
	MOVLW 	0XFF
	MOVWF 	CONTADOR1
	INCF	CONTADOR2
	GOTO 	CINCO_VUELTAS

DIEZ_VUELTAS
	;Utiliza el mismo metodo para hacer girar el motor que la opcion ANTIHORARIO 
	;Para el control de vueltas se hace uso de dos contadores, el contador uno indica 
	;el número de pasos completos que se dan, se usa 255 (valor máximo para un registro de 8 bits)
	;Con este valor se da media vuelta. El contador 2 lleva el registro de medias vueltas que ha
	;dado el motor.

	;Revisa si el motor ya dio la cantidad de vueltas necesarias
	MOVLW 	0X14	;20 medias vueltas -> 10 vueltas
	XORWF	CONTADOR2,W
	BTFSC 	STATUS, Z	
	GOTO 	STOP_1

	;Revisa si el contador ya dio el máximo de pasos y, si es el caso, lo manda a resetear 
	MOVLW 	0X00
	XORWF	CONTADOR1,W
	BTFSC 	STATUS, Z	
	GOTO 	RES_CONT_1
GIRA_1:
	;Instrucciones para que el motor gire en sentido horario, revisar comentarios de la 
	;etiqueta ANTIHORARIO para explicación detallada.

	DECF	CONTADOR1

	MOVLW 	EDO4
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	MOVLW 	EDO3
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	MOVLW 	EDO2
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	MOVLW 	EDO1
	MOVWF 	PORTB
	CALL 	RETARDO_05ms

	GOTO DIEZ_VUELTAS

STOP_1:
	;Se llega aquí una vez que se dio el numero de vueltas necesarias. En esta seleccionó
	;se apaga el motor y se revisa el contenido del puerto A para detectar si se selecciona
	;Otra opcion.

	CLRF PORTB

	MOVLW  	0X04
	XORWF	PORTA,W	
	BTFSS 	STATUS,Z
	GOTO 	LOOP	
	GOTO 	DIEZ_VUELTAS

RES_CONT_1	
	;Resetea el contador 1 e incremeta el contador 2
	MOVLW 	0XFF
	MOVWF 	CONTADOR1
	INCF	CONTADOR2
	GOTO 	DIEZ_VUELTAS

CONFIG_INICIAL:
	;Camio al banco 1
	BCF STATUS, RP1	;RP1 = 0
	BSF STATUS, RP0	;RP0 = 1
	
	;configura los pines del puerto B y C como salidas
	CLRF    TRISB       
	CLRF    TRISC       
	
	; Configura los pines del puerto A como entradas digitales
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

RETARDO_05ms 
	MOVLW 	.82
	MOVWF 	valor1
dos_05: 
	MOVLW 	.10
	MOVWF 	valor2
uno_05: 
	DECFSZ 	valor2
	GOTO 	uno_05
	DECFSZ 	valor1
	GOTO 	dos_05
	RETURN

RETARDO_18ms 
	MOVLW 	.255
	MOVWF 	valor1
dos_18: 
	MOVLW 	.118 ; 118
	MOVWF 	valor2
uno_18: 
	DECFSZ 	valor2
	GOTO 	uno_18
	DECFSZ 	valor1
	GOTO 	dos_18
	RETURN

END
