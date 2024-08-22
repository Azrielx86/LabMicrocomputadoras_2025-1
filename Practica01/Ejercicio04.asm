	PROCESSOR 16F877A
	INCLUDE <P16F877A.inc>
	
AX EQU 0x26
	
	ORG 0
	GOTO INICIO
	
	ORG 5
INICIO:
	MOVLW	0x1		; W = 1;
	MOVWF	AX		; AX = W;
					; Codigo equivalente
LOOP:				; while(0) {
	BTFSS 	AX,7	; 	if (AX == 0x80)
	GOTO 	SHIFT	; 	{
	MOVLW	0x1		; 		W = 1;
	MOVWF	AX		; 		AX = W;
	GOTO 	LOOP	; 		continue;
SHIFT:				; 	}
	RLF		AX		; 	AX << 1;
	GOTO	LOOP	; }
	END