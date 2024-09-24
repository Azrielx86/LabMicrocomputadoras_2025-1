;Definicion de Variables y constantes para
;La rutina de retardo
;Variables, representan direcciones de memoria
valor1 equ h'21'
valor2 equ h'22'
valor3 equ h'23'
;Constantes se utilizan como literales
cte1 equ 20h
cte2 equ 50h
cte3 equ 60h

PARAM1 EQU 0x70


CONFIG_PORTA:
    BCF STATUS,RP1
    BSF STATUS,RP2

CPORTA:

CPORTB:

    RETURN

;Subrutina para retardo de 2seg
RETARDO_2000ms 
	MOVLW .200
	MOVWF valor1
tres:
	MOVLW .200
	MOVWF valor2
dos: 
	MOVLW .82
	MOVWF valor3
uno: 
	DECFSZ 	valor3
	GOTO 	uno
	DECFSZ 	valor2
	GOTO 	dos
	DECFSZ 	valor1
	GOTO 	tres
	RETURN
;Subrutina para retardo de 0.5seg
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