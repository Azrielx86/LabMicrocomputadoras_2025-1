PROCESSOR 16f877A
 INCLUDE  <p16f877A.inc>    
 
    ORG 0 
    GOTO INICIO     ; > Inicio del programa
    ORG 5 
INICIO:
    BCF STATUS,RP1  ; Establece el registro RP1 en 0
    BSF STATUS,RP0  ; Establece el registro RP0 en 1
                    ; Como se selecciona el banco en [1][0]
                    ; se utilizará el banco de memoria 2
    MOVLW 0X20      ; Mueve 0x20 en W
    MOVWF FSR       ; y lo carga en FSR
LOOP:
    MOVLW 0X5F      ; Almacena 0x5F
    MOVWF INDF      ; Y lo guarda en la direccion 0x20 del banco 2
    INCF FSR        ; Incrementa el puntero FSR
    BTFSS FSR,6     ; Comprueba si llego al final de la lista
    GOTO LOOP       ; Y repite el código
    GOTO $          ; > Final del programa
    END