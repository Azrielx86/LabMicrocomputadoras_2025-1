	PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>
	
	ORG 0
	GOTO INICIO
	ORG 5
INICIO:
    BSF     STATUS,RP0
    BCF     STATUS,RP1
    
    BSF     TXSTA,BRGH  ; 
    MOVLW   0x81        ; Establece el baudrate en 9600 baudios.
    MOVWF   SPBRG
    BCF     TXSTA,SYNC  ; Configura el modo asincrono
    BSF     TXSTA,TXEN  ; Habilita la transmision
    
    BCF     STATUS,RP0
    
    BSF     RCSTA,SPEN  ; Habilita el puerto serie
    BSF     RCSTA,CREN  ; Habilita la recepcion de datos.
    
RECIBE:
    BTFSS   PIR1,RCIF   ; Comprueba si ya se recibieron datos
    GOTO    RECIBE
    
    MOVFW   RCREG       ; Almacena el dato leido en W
    MOVWF   TXREG       ; Mueve el dato obtenido a W
    
    BSF     STATUS,RP0  ; Cambio del banco para el registro de transmision
TRANSMITE:
    BTFSS   TXSTA,TRMT  ; Comprueba si ya se transmitio el dato
    GOTO    TRANSMITE
    BCF     STATUS,RP0  ; Regresa al banco 0
    GOTO    RECIBE
    
    END