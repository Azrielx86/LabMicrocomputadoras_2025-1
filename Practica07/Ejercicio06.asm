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
    
    ; Compara si el dato es S
    MOVLW   0x53
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 5
    ; Apaga los motores
    CLRF    PORTD
    CLRF    PORTB
    BCF     PORTB,0
    GOTO    RECIBE


    ; Para todos los demás casos, enciende los motores.
    MOVLW   0x06
    MOVWF   PORTD
    
    ; Compara si el dato es A
    MOVLW   0x41
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 4
    MOVLW   0x05
    MOVWF   PORTB
    GOTO    RECIBE
    
    ; Compara si el dato es T
    MOVLW   0x54
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 4
    MOVLW   0x0A
    MOVWF   PORTB
    GOTO    RECIBE
    
    ; Compara si el dato es D
    MOVLW   0x44
    XORWF   CHR,W
    BTFSS   STATUS,Z
    GOTO    $ + 4
    MOVLW   0x09
    MOVWF   PORTB
    GOTO    RECIBE
    
    ; Compara si el dato es I
    MOVLW   0x69
    XORWF   CHR,W
    BTFSC   STATUS,Z
    GOTO    $ + 3
    MOVLW   0x06
    MOVWF   PORTB
    GOTO    RECIBE
    
    END