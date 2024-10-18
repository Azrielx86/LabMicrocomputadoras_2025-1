	PROCESSOR 16F877A
	INCLUDE<p16F877a.inc>
CHR EQU 0x20
CONT EQU 0X21
valor1 equ 0x41
valor2 equ 0x42
valor3 equ 0x43
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

	MOVLW 	0x00
	MOVWF	PORTB
    
RECIBE:
    BTFSS   PIR1,RCIF   ; Comprueba si ya se recibieron datos
    GOTO    RECIBE
    
    MOVFW   RCREG
    MOVWF   CHR
	
	BSF		CHR,5 ;CONVIERTE A MINUSCULA

	;Convierte a mayusculas para case insensitive

    
    ; Compara si el dato es 0
	;BCF STATUS,C
CHECK1:
    MOVLW   .100
    XORWF   CHR,W
    BTFSS   STATUS,Z ;
    GOTO    CHECK2
    ;RRF     PORTB
	GOTO 	SHIFT_RIGHT

    GOTO    RECIBE
    
    ; Compara si el dato es 1
CHECK2:
    MOVLW   .105
    XORWF   CHR,W
    BTFSC   STATUS,Z
    ;RLF    PORTB
	GOTO 	SHIFT_LEFT
    GOTO    RECIBE

SHIFT_RIGHT:
	BCF STATUS,C
	MOVLW 0x01
	MOVWF PORTB
	;CLRF PORTB

	MOVLW 0x08
	MOVWF CONT
	
GIRAR:
	CALL	RETARDO_500ms
	RLF		PORTB
	DECFSZ	CONT
	GOTO 	GIRAR
	GOTO 	RECIBE

SHIFT_LEFT:
	BCF STATUS,C
	MOVLW 0x80
	MOVWF PORTB
	;CLRF PORTB

	MOVLW 0x08
	MOVWF CONT
	
GIRAL:
	CALL 	RETARDO_500ms
	RRF		PORTB
	DECFSZ	CONT
	GOTO 	GIRAL
	GOTO 	RECIBE
   
  
RETARDO_500ms 
	MOVLW .50
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