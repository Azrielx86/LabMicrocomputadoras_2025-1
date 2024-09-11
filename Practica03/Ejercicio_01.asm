processor 16f877
include <p16f877.inc>

SALIDA EQU 0x20

;Definicion de Variables y constantes para
;La rutina de retardo
;Variables, representan direcciones de memoria
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
;Constantes se utilizan como literales
cte1 equ 80h
cte2 equ 50h
cte3 equ 60h
	ORG 0
	GOTO INICIO
	ORG 5

INICIO:
	;Subrutina para configurar los puertos de I/O
	CALL CONFIG_INICIAL

LOOP:
	;Prende todos los leds
	MOVLW 0XFF 	; carga 0xFF a W
	MOvWF PORTB	; carga el contenido de W a PORTB

	CALL RETARDO_500ms ;llama a la subrutina de retardo

	;apaga el led
	CLRF PORTB	; PORTB = 0x00
	CALL RETARDO_500ms	
	GOTO LOOP

CONFIG_INICIAL:
	
	;Camio al banco 1
	BCF STATUS, RP1	;RP1 = 0
	BSF STATUS, RP0	;RP0 = 1
	
	;configura los pines del puerto B como salidas
	CLRF TRISB 		; TRISB = 0x00

	;Cambio al banco 0 
	BCF STATUS, RP0	; RP0 = 0

	;Limpia el puerto B
	CLRF PORTB 		;PORTB = 0x00

	RETURN

;Se implementa el retardo mediante una serie de ciclos anidados
;cuya unica finalidad es gastar el tiempo de procesamiento
RETARDO_500ms 
	;MOVLW .50
	MOVLW cte1 		;Carga el valor de cte1 al registro W
	MOVWF valor1	;Carga el valor de W al registro valor1
tres:
	;MOVLW .200
	MOVLW cte2		;Carga el valor de cte2 al registro W
	MOVWF valor2	;Carga el valor de W al registro valor2
dos: 
	;MOVLW .82
	MOVLW cte3		;Carga el valor de cte1 al registro W
	MOVWF valor3	;Carga el valor de W al registro valor3
uno: 
	DECFSZ 	valor3	;Decrementa el valor del registro valor3
	GOTO 	uno		;Salta a la etiqueta uno se omite cuando 
					;valor3 = 0

	DECFSZ 	valor2 	;Decrementa el valor del registro valor2
	GOTO 	dos		;Salta a la etiqueta uno se omite cuando 
					;valor2 = 0

	DECFSZ 	valor1	;Decrementa el valor del registro valor1
	GOTO 	tres	;Salta a la etiqueta uno se omite cuando 
					;valor1 = 0
	RETURN
END: