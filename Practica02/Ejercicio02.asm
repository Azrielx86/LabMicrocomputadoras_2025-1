	PROCESSOR 16f877A
	INCLUDE <p16f877A.inc> 
AX	EQU 0x40            ; Registro para almacenar el valor menor encontrado
	ORG 0
	GOTO INICIO 
	ORG 5
INICIO:
	BCF		STATUS,7    ; Se limpia el registro IRP
	BCF 	STATUS,RP1  ; Para seleccionar el primer banco
	BCF 	STATUS,RP0  ; Se colocan RP1/0 en 00
	MOVLW 	0X20        ; Se mueve la direccion del primer elemento en W
	MOVWF 	FSR         ; y se coloca en FSR para el
                        ; direccionamiento indirecto
	MOVF 	INDF,W      ; Se obtiene el valor del primer elemento
                        ; del arreglo
	MOVWF	AX          ; Se guarda en AX
	INCF 	FSR         ; Incrementa en uno el apuntador
LOOP:
	MOVF	INDF,W      ; Obtiene el valor del primer elemento y
                        ; lo almacena en W
	SUBWF	AX,W        ; Se compara con AX
	BTFSS	STATUS,0    ; | C = STATUS[0]
	GOTO 	MAYOR       ; Si el valor del carry es 1, significa que 
                        ; el valor del arreglo obtenido es menor
                        ; que el almacenado en AX
	MOVF	INDF,W      ; Se mueve el nuevo valor encontrado en W  
	MOVWF	AX          ; Y posteriormente en AX
MAYOR:
	INCF 	FSR         ; Incrementa en uno el apuntador
	BTFSS 	FSR,6       ; Comprueba si llego al ultimo elemento del
                        ; arreglo en 0x3F
	GOTO 	LOOP        ; Si faltan elementos, continua el loop
	GOTO 	$           ; Final del programa
	END