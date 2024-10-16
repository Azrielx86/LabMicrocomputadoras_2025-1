    PROCESSOR 16f877a
    INCLUDE <p16f877a.inc>

ACH0    EQU     0x20
ACH1    EQU     0x21
ACH2    EQU     0x22


valor1 equ 0x41
valor2 equ 0x42
valor3 equ 0x43
    
    ORG 0
    GOTO INICIO
    ORG 5

INICIO:
    CALL    CONFIG_INICIAL
    MOVLW   0xE9
    MOVWF   ADCON0
    CALL    RET_200us
LOOP:
    ; Cambia al canal 5
    MOVLW   0xED
    MOVWF   ADCON0
    CALL    RET_200us

    BTFSC   ADCON0,2    ; Se revisa GO/DONE
    GOTO    $ - 1   ; Espera a la lectura
    MOVFW   ADRESH
    MOVWF   ACH0
    
    ; Cambia al canal 6
    MOVLW   0xF5
    MOVWF   ADCON0
    CALL    RET_200us

    BTFSC   ADCON0,2    ; Se revisa GO/DONE
    GOTO    $ - 1   ; Espera a la lectura
    MOVFW   ADRESH
    MOVWF   ACH1
    
    ; Cambia al canal 7
    MOVLW   0xFD
    MOVWF   ADCON0
    CALL    RET_200us
    
    BTFSC   ADCON0,2    ; Se revisa GO/DONE
    GOTO    $ - 1   ; Espera a la lectura
    MOVFW   ADRESH
    MOVWF   ACH2
    
    ; Comparacion
CASE1:
    ; ACH0 > ACH1 AND ACH2
    MOVFW   ACH1
    SUBWF   ACH0,W
    BTFSS   STATUS,C
    GOTO CASE2
    
    MOVFW   ACH2
    SUBWF   ACH0,W
    BTFSS   STATUS,C
    GOTO CASE2
    
    MOVLW   0x01
    MOVWF   PORTD
    GOTO LOOP
    
    
CASE2:
    ; ACH1 > ACH0 AND ACH2
    MOVFW   ACH0
    SUBWF   ACH1,W
    BTFSS   STATUS,C
    GOTO CASE3
    
    MOVFW   ACH2
    SUBWF   ACH1,W
    BTFSS   STATUS,C
    GOTO CASE3
    
    MOVLW   0x02
    MOVWF   PORTD
    GOTO LOOP

CASE3:
    ; ACH2 > ACH0 AND ACH1, se asume que ACH2 es mayor
    MOVLW   0x03
    MOVWF   PORTD
    GOTO LOOP
    
    
CONFIG_INICIAL:
    CLRF PORTA
	BCF     STATUS,RP1
	BSF     STATUS,RP0
	CLRF    TRISD
    CLRF    ADCON1
	BCF     STATUS,RP0
    ; Configura los pines del puerto A como entradas analogicas.
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