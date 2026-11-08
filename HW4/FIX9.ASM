; Scan all 81 bytes in row-major order; report errors without editing TABLE.
.MODEL SMALL
.STACK 100H
.DATA
TABLE DB 7,2,3,4,5,6,7,8,9
      DB 2,4,7,8,10,12,14,16,18
      DB 3,6,9,12,15,18,21,24,27
      DB 4,8,12,16,7,24,28,32,36
      DB 5,10,15,20,25,30,35,40,45
      DB 6,12,18,24,30,7,42,48,54
      DB 7,14,21,28,35,42,49,56,63
      DB 8,16,24,32,40,48,56,7,72
      DB 9,18,27,36,45,54,63,72,81
HEADER DB 'x y',0DH,0AH,'$'
ERRMSG DB 'error',0DH,0AH,'$'
FINISH DB 0DH,0AH,'accomplish!',0DH,0AH,'$'
.CODE
START:
    MOV AX,@DATA
    MOV DS,AX
    LEA DX,HEADER
    MOV AH,09H
    INT 21H
    MOV BX,1               ; 1-based row; BL is the row factor.
    XOR SI,SI              ; Zero-based byte index into TABLE.
    MOV CX,9
SCAN_ROW:
    PUSH CX                ; Outer count survives the inner LOOP.
    MOV CX,9
    MOV DI,1               ; 1-based column.
SCAN_COL:
    MOV AX,DI              ; AL = column.
    MUL BL                 ; AX = column * row, at most 81.
    CMP AL,TABLE[SI]       ; DS:[OFFSET TABLE + SI].
    JE NEXT_COL
    CALL REPORT_ERROR      ; Uses CX for spacing but restores it.
NEXT_COL:
    INC SI
    INC DI
    LOOP SCAN_COL
    POP CX
    INC BX
    LOOP SCAN_ROW
    LEA DX,FINISH
    MOV AH,09H
    INT 21H
    MOV AX,4C00H
    INT 21H

; Input BX=row, DI=column. Preserves AX, CX, DX; BX, DI, SI unchanged.
REPORT_ERROR PROC NEAR
    PUSH AX
    PUSH CX
    PUSH DX
    MOV DL,BL
    ADD DL,'0'
    MOV AH,02H
    INT 21H
    MOV DL,' '
    INT 21H
    MOV DX,DI
    ADD DL,'0'
    MOV AH,02H
    INT 21H
    MOV CX,2
REPORT_PAD:
    MOV DL,' '
    INT 21H
    LOOP REPORT_PAD
    LEA DX,ERRMSG
    MOV AH,09H
    INT 21H
    POP DX
    POP CX
    POP AX
    RET
REPORT_ERROR ENDP
END START
