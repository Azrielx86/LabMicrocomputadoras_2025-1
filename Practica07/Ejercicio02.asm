	PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>
	
	ORG 0
	GOTO INICIO
	ORG 5

INICIO:

    CALL    CONFIG_INICIAL

;Espera a recibir un dato a través del puerto serie
RECIBE:
    BTFSS   PIR1,RCIF   ; Comprueba si ya se recibieron datos
    GOTO    RECIBE
    
    MOVFW   RCREG       ; Almacena el dato leido en W
    MOVWF   TXREG       ; Mueve el dato obtenido a W
    MOVWF	PORTB

    BSF     STATUS,RP0  ; Cambio del banco para el registro de transmision

TRANSMITE:
    BTFSS   TXSTA,TRMT  ; Comprueba si ya se transmitio el dato
    GOTO    TRANSMITE
    BCF     STATUS,RP0  ; Regresa al banco 0
    GOTO    RECIBE

CONFIG_INICIAL:
    ;Cambia al banco 1
    BSF     STATUS,RP0
    BCF     STATUS,RP1

	CLRF 	TRISB		;Puerto B como salida
    
    BSF     TXSTA,BRGH  ; Configura la bandera BRGH para alta velocidad

    ;Establece el baudrate en 9600 baudios.
    MOVLW   0x81        
    MOVWF   SPBRG

    BCF     TXSTA,SYNC  ; Configura el modo asincrono
    BSF     TXSTA,TXEN  ; Habilita la transmision
    
    ;Cambia al banco 0
    BCF     STATUS,RP0
    
    BSF     RCSTA,SPEN  ; Habilita el puerto serie
    BSF     RCSTA,CREN  ; Habilita la recepcion de datos.

	CLRF PORTB
    
    RETURN

    END