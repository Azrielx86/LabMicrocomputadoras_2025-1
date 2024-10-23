	PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>
REGA     EQU     0x20
TEMPERATURE    EQU     0x21
TMP     EQU     0x22

valor1 equ 0x41
valor2 equ 0x42
valor3 equ 0x43

	ORG 0
	GOTO INICIO
	ORG 5
INICIO:
    CALL    CONFIG_INICIAL
LOOP:
    BSF     ADCON0,2
    CALL    RET_200us
    ; Obtener temperatura
    BTFSC   ADCON0,2
    GOTO    $ - 1
    
    CLRF    TMP
    CLRF    TEMPERATURE
    CLRF    REGA
    
    MOVLW   0x00
    IORWF   ADRESH,W
    BTFSS   STATUS,Z
    GOTO    $ + 3
    BSF     ADCON0,2
    GOTO    LOOP
    
    MOVFW   ADRESH
    MOVWF   TEMPERATURE
    RLF     TEMPERATURE ; TODO : Ver por que esto funciona xd

    ; Transmitir dato
    ; Basado en "divisiones" (con restas), se obtienen las centenas,
    ; decenas y unidades. conforme se van obteniendo, se imprimen
    ; en pantalla.
    MOVLW   0x64
    SUBWF   TEMPERATURE,W
    BTFSS   STATUS,C
    GOTO    $ + 4
    MOVWF   TEMPERATURE
    INCF    REGA
    GOTO    $ - 6
    MOVFW   REGA
    ADDLW   0x30        ; Se suma 0x30 al digito obtenido
    CALL    TRANSMITE    ; y se imprime.

    CLRF    REGA
    MOVLW   0x0A
    SUBWF   TEMPERATURE,W
    BTFSS   STATUS,C
    GOTO    $ + 4
    MOVWF   TEMPERATURE
    INCF    REGA
    GOTO    $ - 6
    MOVFW   REGA
    ADDLW   0x30
    CALL    TRANSMITE
    
    CLRF    REGA
    MOVLW   0x01
    SUBWF   TEMPERATURE,W
    BTFSS   STATUS,C
    GOTO    $ + 4
    MOVWF   TEMPERATURE
    INCF    REGA
    GOTO    $ - 6
    MOVFW   REGA
    ADDLW   0x30
    CALL    TRANSMITE

    MOVLW   A'\n'
    CALL    TRANSMITE

    GOTO    LOOP

CONFIG_INICIAL:
    BSF     STATUS,RP0  ; Cambio al banco 1
    BCF     STATUS,RP1
    CLRF    ADCON1      ; Configura el puerto A como analogico.
    BSF     TXSTA,BRGH  ; 
    MOVLW   0x81        ; Establece el baudrate en 9600 baudios.
    MOVWF   SPBRG
    BCF     TXSTA,SYNC  ; Configura el modo asincrono
    BSF     TXSTA,TXEN  ; Habilita la transmision
    
    BCF     STATUS,RP0
    BSF     RCSTA,SPEN
    BSF     RCSTA,CREN  ; Habilita la recepcion de datos.

    MOVLW   0xE9
    MOVWF   ADCON0
    
    RETURN
    
TRANSMITE:
    MOVWF   TXREG
    BSF     STATUS,RP0  ; Cambio del banco para el registro de transmision
    BTFSS   TXSTA,TRMT  ; Comprueba si ya se transmitio el dato
    GOTO    $ - 1
    BCF     STATUS,RP0  ; Regresa al banco 0
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