; 8086 / MASM 5.0: nested LOOP, 2 rows x 13 letters.
.MODEL SMALL
.STACK 100H
.CODE
START:
    MOV BL,'a'
    MOV CX,2               ; Outer counter: two rows.
ROW_BEGIN:
    PUSH CX                ; Save outer CX before using CX inside.
    MOV CX,13              ; Inner counter: thirteen letters.
COL_BEGIN:
    MOV AH,02H
    MOV DL,BL
    INT 21H
    INC BL
    CMP CX,1
    JE NO_SPACE            ; No trailing space after column 13.
    MOV DL,' '
    INT 21H
NO_SPACE:
    LOOP COL_BEGIN         ; CX = CX - 1; repeat while CX != 0.
    MOV DL,0DH
    INT 21H
    MOV DL,0AH
    INT 21H
    POP CX                 ; Restore the outer loop counter.
    LOOP ROW_BEGIN
    MOV AX,4C00H
    INT 21H
END START
