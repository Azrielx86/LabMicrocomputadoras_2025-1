	PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>
CHR EQU 0x20
	ORG 0
	GOTO INICIO
	ORG 5
INICIO:
    BSF     STATUS,RP0  ; Cambio al banco 1
    BCF     STATUS,RP1
    
    BSF     TXSTA,BRGH  ; 
    MOVLW   0x81        ; Establece el baudrate en 9600 baudios.
    MOVWF   SPBRG
    BCF     TXSTA,SYNC  ; Configura el modo asincrono
    BSF     TXSTA,TXEN  ; Habilita la transmision
    CLRF    TRISB       ; Puerto B como salida.
    BCF     STATUS,RP0
    BSF     RCSTA,SPEN
    BSF     RCSTA,CREN  ; Habilita la recepcion de datos.
    CLRF    PORTB
    
RECIBE:
    BTFSS   PIR1,RCIF   ; Comprueba si ya se recibieron datos
    GOTO    RECIBE
    
    MOVFW   RCREG
    MOVWF   CHR
    
    ; Compara si el dato es 0
    MOVLW   0x30
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 3
    BCF     PORTB,0
    GOTO    RECIBE
    
    ; Compara si el dato es 1
    MOVLW   0x31
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 2
    BSF     PORTB,0
    GOTO    RECIBE
    
    END