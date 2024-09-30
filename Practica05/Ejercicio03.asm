    PROCESSOR 16f877a
    INCLUDE <p16f877a.inc>

REG0    EQU     0x20
REG1    EQU     0x21

valor1 equ h'41'
valor2 equ h'42'
valor3 equ h'43'

	ORG 0
	GOTO INICIO
	ORG 5

loop_stay MACRO valuein,compare_with,ret_loop,inner_loop
    MOVLW   valuein
    XORWF   compare_with,W
    BTFSS   STATUS,Z
    GOTO    ret_loop
    GOTO    inner_loop
ENDM

INICIO:
	;Subrutina para configurar los puertos de I/O
	CALL CONFIG_INICIAL
LOOP:
	MOVLW 0x07
	ANDWF PORTA,W
	
	ADDWF PCL,F
	GOTO LOOP
	GOTO SERV_DER
	GOTO SERV_CEN
	GOTO LOOP
	GOTO SERV_IZQ
	GOTO LOOP
	GOTO LOOP
	GOTO LOOP
	GOTO LOOP

SERV_DER:
    MOVLW   0xFF
    MOVWF   PORTC
    CALL RETARDO_2ms
	CALL RETARDO_05ms
    CLRF    PORTC
    CALL RETARDO_18ms
    GOTO LOOP
    
SERV_CEN:
    MOVLW   0xFF
    MOVWF   PORTC
    CALL RETARDO_1ms
    CALL RETARDO_05ms
    CLRF    PORTC
    CALL RETARDO_05ms
    CALL RETARDO_18ms
    GOTO LOOP

SERV_IZQ:
    MOVLW   0xFF
    MOVWF   PORTC
    CALL RETARDO_05ms
    CLRF    PORTC
    CALL RETARDO_1ms
	CALL RETARDO_05ms
    CALL RETARDO_18ms
    GOTO LOOP

CONFIG_INICIAL:
	;Camio al banco 1
	BCF STATUS, RP1	;RP1 = 0
	BSF STATUS, RP0	;RP0 = 1
	
	;configura los pines del puerto B y C como salidas
	CLRF    TRISB       ; TRISB = 0x00
	CLRF    TRISC       ; TRISC = 0x00
	MOVLW   0x06        ; Configura el puerto A
	MOVWF   ADCON1      ;   como entradas digitales
	MOVLW   0x3F
	MOVWF   TRISA

	;Cambio al banco 0 
	BCF STATUS, RP0	; RP0 = 0

	;Limpia los puertos
	CLRF PORTB
	CLRF PORTA
	CLRF PORTC

	RETURN
	
RETARDO_18ms 
	MOVLW .255
	MOVWF valor1
dos_18: 
	MOVLW .118 ; 118
	MOVWF valor2
uno_18: 
	DECFSZ 	valor2
	GOTO 	uno_18
	DECFSZ 	valor1
	GOTO 	dos_18
	RETURN

RETARDO_1ms 
	MOVLW .150
	MOVWF valor1
dos_1: 
	MOVLW .11
	MOVWF valor2
uno_1: 
	DECFSZ 	valor2
	GOTO 	uno_1
	DECFSZ 	valor1
	GOTO 	dos_1
	RETURN

RETARDO_2ms 
	MOVLW .255
	MOVWF valor1
dos_2: 
	MOVLW .12
	MOVWF valor2
uno_2: 
	DECFSZ 	valor2
	GOTO 	uno_2
	DECFSZ 	valor1
	GOTO 	dos_2
	RETURN

RETARDO_05ms 
	MOVLW .82
	MOVWF valor1
dos_05: 
	MOVLW .10
	MOVWF valor2
uno_05: 
	DECFSZ 	valor2
	GOTO 	uno_05
	DECFSZ 	valor1
	GOTO 	dos_05
	RETURN

	END