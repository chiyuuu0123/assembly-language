; 8086 / MASM 5.0: conditional jumps, 2 rows x 13 letters.
.MODEL SMALL
.STACK 100H
.CODE
START:
    MOV BL,'a'
    MOV CX,2
ROW_BEGIN:
    PUSH CX
    MOV CX,13
COL_BEGIN:
    MOV AH,02H
    MOV DL,BL
    INT 21H
    INC BL
    CMP CX,1
    JE NO_SPACE
    MOV DL,' '
    INT 21H
NO_SPACE:
    DEC CX                 ; DEC changes ZF; JNZ tests ZF.
    JNZ COL_BEGIN
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H
    POP CX
    DEC CX
    JNZ ROW_BEGIN
    MOV AX,4C00H
    INT 21H
END START
