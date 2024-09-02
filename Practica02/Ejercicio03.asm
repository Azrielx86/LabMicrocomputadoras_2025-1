	PROCESSOR 16f877A
	INCLUDE <p16f877A.inc> 
AX	EQU 0x40 ; Valor Menor actual
BX	EQU	0x41 ; Direccion del siguiente indice
CX	EQU	0x42 ; Direccion del ultimo valor menor encontrado
DX	EQU	0x43 ; Arreglo[BX]
	ORG 0
	GOTO INICIO 
	ORG 5
INICIO:
	BCF		STATUS,7    ; Se limpia el registro IRP
	BCF 	STATUS,RP1  ; Se limpian los registros para el acceso indirecto
	BCF 	STATUS,RP0
	MOVLW 	0x20        ; Se inicializa el puntero FSR en el primer elemento
	MOVWF 	FSR         ; de la lista, ubicado en 0x20 del banco 0
	MOVWF	BX          ; y se copia la direccion tambien en BX
	MOVF 	INDF,W      ; Se guarda en W el valor de la direccion a la que apunta FSR
	MOVWF	AX          ; Crea una copia del valor almacenado en FSR tambien en AX
	INCF 	FSR         ; Incrementa en uno el apuntador FSR
LOOP:                   ; ==
	MOVF	INDF,W      ; Guarda el valor en el que apunta FSR en W
	SUBWF	AX,W        ; y lo compara con el valor guardado en AX
	BTFSS	STATUS,0    ; Revisa si W < AX mediante el bit de carry
	GOTO 	MAYOR       ; Si es menor, continua la ejecucion,
                        ; en caso contrario pasa a la etiqueta MAYOR.
	MOVF	INDF,W      ; Guarda una copia del valor en el registro W
	MOVWF	AX          ; Guarda tambien una copia en AX
	MOVF	FSR,W       ; Obtiene la direccion de memoria donde se encontro ese valor
	MOVWF	CX          ; Guarda la direccion de memoria en CX
MAYOR:                  ; == 
	INCF 	FSR         ; Si es mayor, incrementa el puntero de FSR
	BTFSS 	FSR,6       ; Revisa si ya recorrio los elementos hasta 0x3F
	GOTO 	LOOP        ; Si faltan elementos por ordenar, repite el loop
	MOVF	BX,W        ; == Swap: Se recupera la direccion del siguiente valor que se va a ordenar
	MOVWF	FSR         ; y se mueve a FSR
	MOVF	INDF,W      ; Se guarda una copia del elemento a ordenar en W
	MOVWF	DX          ; Se guarda en el registro temporal DX
	MOVF	AX,W        ; Se mueve el ultimo valor menor encontrado a W
	MOVWF	INDF        ; Se guarda el valor en su indice correspondiente
	MOVF 	CX,W        ; Se obtiene la direccion del valor que se intercambio
	MOVWF	FSR         ; Se copia la direccion a FSR
	MOVF	DX,W        ; Se coloca el valor intercambiado en donde se encontraba el ultimo valor menor
	MOVWF	INDF        ; Incrementa en uno el puntero
	INCF	BX          ; Incrementar BX para no volver a pasar por los valores ya ordenados
	MOVF	BX,W        ; Se copia el valor de BX al
	MOVWF	FSR         ; puntero FSR
	MOVF	INDF,W      ; Obtiene el valor del primer elemento del array
	MOVWF	AX          ; Se guarda el valor en AX
	INCF	FSR         ; Se incrementa en uno el puntero
	BTFSS 	FSR,6       ; Comprueba si ya era el ultimo elemento del array (en 0x3F)
	GOTO	LOOP        ; Si faltan elementos, regresa a Loop
	GOTO 	$           ; Cuando se ordena toda la lista, se queda la ejecucion en esta instruccion
	END