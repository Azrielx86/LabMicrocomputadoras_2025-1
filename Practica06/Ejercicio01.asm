    PROCESSOR 16f877a
    INCLUDE <p16f877a.inc>

valor1 equ 0x41
valor2 equ 0x42
valor3 equ 0x43
    
    ORG 0
    GOTO INICIO
    ORG 5

INICIO:
    CALL    CONFIG_INICIAL
    MOVLW   0xE9        ; Selecciona el canal 5
    ANDWF   ADCON0,F

    MOVLW   0x05
    IORWF   ADCON0,F    ; Enciende ADON y la bandera GO/DONE
    CALL    RET_200us
READ_PORT:
    BTFSC   ADCON0,2    ; Se revisa GO/DONE
    GOTO    READ_PORT   ; Espera a la lectura
    
    MOVFW   ADRESH
    MOVWF   PORTD
    BSF     ADCON0,2
    GOTO    READ_PORT
    
    
    
CONFIG_INICIAL:
    CLRF PORTA
	BCF     STATUS,RP1
	BSF     STATUS,RP0
	CLRF    TRISD
    CLRF    ADCON1
	BCF     STATUS,RP0
    ; Configura los pines del puerto A como entradas anal�gicas.
    MOVLW   0xC0    ; Establece la frecuencia de muestreo
    MOVWF   ADCON0  ; como la interna del pic

	;Limpia los puertos
	CLRF    PORTD

	RETURN
	
RET_200us:
	MOVLW   0x01
	MOVWF   valor1
	MOVLW   0x20
	MOVWF   valor2
	DECFSZ 	valor2
	GOTO 	$ - 1
	DECFSZ 	valor1
	GOTO 	$ - 5
	RETURN

    END