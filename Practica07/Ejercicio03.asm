	PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>
	
OFFSET  EQU 0x20
	
	ORG 0
	GOTO INICIO
	ORG 5
	
hello_world:    ; Cadena con el mensaje a transmitir.
    ADDWF   PCL,F
    DT  "HOLA UNAM",'\n',0x00
	
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
    
LOOP:
    CLRF    OFFSET      ; Establece el offset para la cadena en 0
PRINT_STR:
    MOVFW   OFFSET      ; Mueve el offset a W
    CALL    hello_world ; Obtiene el caracter de la tabla con el offset
    IORLW   0x00        ; Comprueba si no es 0 mediante un OR
    BTFSC   STATUS,Z    
    GOTO    $ + 5       ; Si es 0, repite el loop desde el inicio.
    MOVWF   TXREG       ; Mueve el caracter obtenido a TXREG
    CALL    TRANSMITE   ; Transmite el caracter por TX
    INCF    OFFSET      ; Incrementa en 1 el offset
    GOTO    PRINT_STR   ; Sigue imprimiendo la cadena
    GOTO LOOP
    
TRANSMITE:
    BSF     STATUS,RP0  ; Cambio del banco para el registro de transmision
    BTFSS   TXSTA,TRMT  ; Comprueba si ya se transmitio el dato
    GOTO    $ - 1
    BCF     STATUS,RP0  ; Regresa al banco 0
    RETURN
    
    END