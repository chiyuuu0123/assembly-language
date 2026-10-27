; Input: BX = row (1..9), SI = column (1..row).
; Output: row*column=product; pad non-final cells to 9 characters.
; Preserves AX, BX, CX, DX, SI. BP and DI are not modified.
; FLAGS are not preserved. CALL/RET and pushes/pops keep SP balanced.
PRINT_CELL PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX                ; CX belongs to the caller's inner LOOP.
    PUSH DX
    PUSH SI
    MOV DL,BL
    ADD DL,'0'
    MOV AH,02H
    INT 21H
    MOV DL,'*'
    INT 21H
    MOV AX,SI
    MOV DL,AL
    ADD DL,'0'
    MOV AH,02H
    INT 21H
    MOV DL,'='
    INT 21H
    MOV AX,SI              ; AL = column, BL = row.
    MUL BL                 ; Unsigned byte multiply: AX = AL * BL.
    CALL PRINT_U16         ; Decimal conversion preserves the product AX.
    CMP SI,BX
    JE PC_DONE             ; No trailing spaces after the last cell.
    MOV CX,3               ; Six characters + 3 spaces for two digits.
    CMP AX,10
    JAE PC_PAD
    INC CX                 ; Five characters + 4 spaces for one digit.
PC_PAD:
    MOV AH,02H
    MOV DL,' '
    INT 21H
    LOOP PC_PAD
PC_DONE:
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_CELL ENDP
