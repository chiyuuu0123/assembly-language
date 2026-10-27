; MASM 5.0 / 8086: descending triangular multiplication table.
.MODEL SMALL
.STACK 100H
.DATA
TITLEMSG DB 'The 9mul9 table:',0DH,0AH,'$'
.CODE
START:
    MOV AX,@DATA
    MOV DS,AX
    LEA DX,TITLEMSG
    MOV AH,09H
    INT 21H
    MOV BX,9               ; BX = row, from 9 down to 1.
    MOV CX,9               ; Outer LOOP uses CX.
ROW_BEGIN:
    PUSH CX                ; Preserve outer counter for inner LOOP.
    MOV CX,BX              ; This row has BX cells.
    MOV SI,1               ; SI = column, from 1 up to row.
COL_BEGIN:
    CALL PRINT_CELL        ; Must preserve the active inner CX.
    INC SI
    LOOP COL_BEGIN
    CALL NEWLINE
    POP CX
    DEC BX
    LOOP ROW_BEGIN
    MOV AX,4C00H
    INT 21H
INCLUDE CELL.INC
INCLUDE PRINT.INC
END START
