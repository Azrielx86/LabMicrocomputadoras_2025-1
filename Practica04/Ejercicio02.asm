    PROCESSOR 16f877A
    INCLUDE <p16f877A.inc>

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
	CLRF BLINKS
LOOP:
	MOVLW 0x07
	ANDWF PORTA,W
	
	; Dependiendo de la opcion seleccionada, se toma la opcion
	; correspondiente.
	ADDWF PCL,F
	GOTO APAGA
	GOTO ENCIENDE
	GOTO CORRI_R
	GOTO CORRI_L
	GOTO CORRI_LR
	GOTO BLINK
	GOTO LOOP
	GOTO LOOP
; La opcion para encender unicamente pone todos los bits del
; puerto b en 1.
ENCIENDE:
	MOVLW 0xFF
	MOVWF PORTB
	GOTO LOOP
; Para la opcion de apagar, todos los bits del puerto b se ponen en 0
APAGA:
	CLRF PORTB
	GOTO LOOP
; La opcion de corrimiento a la derecha primero establece REG1
; en 0x01, para colocarle un bit, el cual se ira recorriendo, y luego
; entra en un loop interno.
CORRI_R:
	MOVLW 0x01
	MOVWF REG1
CORRI_R_LOOP:
	RLF	REG1,F      ; Se realiza el desplazamiento.
	MOVFW REG1
	MOVWF PORTB     ; Se pasa REG1 al puerto B.
	CALL RETARDO_500ms
	MOVLW 0x02      ; Se compara si se sigue en la opción requerida (2)
	XORWF PORTA,W   ; mediante un XOR
	BTFSS STATUS,Z  ; En caso de que el puerto A ya no tenga la opcion
	GOTO LOOP       ; 2, se sale del loop, en caso contrario, se
	GOTO CORRI_R_LOOP  ; sigue ejecutando.
	
; El corrimiento a la izquierda se realiza de la misma manera
; que el corrimiento a la derecha.
CORRI_L:
	MOVLW 0x01
	MOVWF REG1
CORRI_L_LOOP:
	RLF	REG1,F
	MOVFW REG1
	MOVWF PORTB
	CALL RETARDO_500ms
	MOVLW 0x03
	XORWF PORTA,W
	BTFSS STATUS,Z
	GOTO LOOP
	GOTO CORRI_L_LOOP

; De manera similar a los otroc corrimientos, se establece REG1
; en 0x01, para colocarle un bit, el cual se ira recorriendo, y luego
; entra en un loop interno. Se limpia REG2 que servira para definir
; hacia que lado se ira moviendo el bit
CORRI_LR:
	MOVLW 0x01
	MOVWF REG1
	CLRF REG2
CORRI_LR_LOOP:
	CALL RETARDO_500ms
	MOVLW 0x04          ; Se comprueba que siga en la opcion 4 de PORTA
	XORWF PORTA,W       ; mediante un XOR, si es distinto, sale del loop.
	BTFSS STATUS,Z
	GOTO LOOP

	MOVFW REG1          ; Se mueve el contenido de REG1 al puerto B.
	MOVWF PORTB

	MOVFW REG2          ; Se comprueba el estado del registro 2,
	ADDWF PCL, F
	GOTO CORRI_LR_L     ; Si es cero, es corrimiento a la izquierda
	GOTO CORRI_LR_R     ; Si es uno, es corrimiento a la derecha
CORRI_LR_R:
	RRF	REG1,F          ; Se realiza el corrimiento
	MOVLW 0X01          ; Se comprueba si REG1 es 1 (que ya llego al bit
	ANDWF REG1,W        ; final del corrimiento.
	BTFSC STATUS,Z
	GOTO CORRI_LR_LOOP
	CLRF REG2           ; Si llegó al final, se limpia REG2
	GOTO CORRI_LR_LOOP  ; para marcar el corrimiento al otro lado.
CORRI_LR_L:
	RLF	REG1,F          ; Se realiza el corrimiento
	MOVLW 0X80          ; Se comprueba si el bit mas significativo es 1
	ANDWF REG1,W        ; es decir, que ya llego al ultimo bit de este
	BTFSC STATUS,Z      ; corrimiento.
	GOTO CORRI_LR_LOOP
	BCF STATUS,C
	MOVLW 0x01          ; Si llego al ultimo bit, se establece REG1
	MOVWF REG2          ; en 1 para marcar el corrimiento al otro lado.
	GOTO CORRI_LR_LOOP

; Para el parpadeo unicamente se usa REG1 para marcar si se encienden
; o se apagan los leds.
BLINK:
    CALL RETARDO_500ms
    MOVLW 0xFF          ; Se establece W con todos los bits en 1
    ANDWF REG1,W        ; Mediante un AND, se compara con REG1 para
    BTFSC STATUS,Z      ; verificar si hay que encender o apagar.
    GOTO BLINK_ON
    GOTO BLINK_OFF
; Para encender los leds, se establece REG1 en 0xFF y se copia a PORTB.
BLINK_ON:
    MOVLW 0xFF
    MOVWF REG1
    MOVWF PORTB
    GOTO BLINK_STAY ; Pasa a comprobar si se sigue en la opcion BLINK.
; De manera similar, se establece REG1 en 0x00 y se copia a PORTB.
BLINK_OFF:
    MOVLW 0x00
    MOVWF REG1
    MOVWF PORTB

BLINK_STAY:
	MOVLW 0x05      ; Se compara PORTA para ver si se sigue en la opcion
	XORWF PORTA,W   ; BLINK mediante un XOR.
	BTFSS STATUS,Z
	GOTO LOOP       ; Si cambio, sale del loop
	GOTO BLINK      ; En caso contrario, sigue con el BLINK
	
    

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

	END
