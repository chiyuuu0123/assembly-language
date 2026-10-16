; Unsigned 16-bit AX -> decimal text. Preserves AX, BX, CX, DX.
PRINT_U16 PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX,CX
    MOV BX,10
PU_DIV:
    XOR DX,DX              ; DIV consumes DX:AX, not just AX.
    DIV BX                 ; AX = quotient, DX = remainder.
    PUSH DX                ; Save digits in reverse order.
    INC CX
    OR AX,AX
    JNZ PU_DIV
PU_OUT:
    POP DX
    ADD DL,'0'
    MOV AH,02H
    INT 21H
    LOOP PU_OUT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_U16 ENDP

NEWLINE PROC NEAR
    PUSH AX
    PUSH DX
    MOV AH,02H
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H
    POP DX
    POP AX
    RET
NEWLINE ENDP
