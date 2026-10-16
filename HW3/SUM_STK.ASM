; Result held in a stack local variable: SS:[BP-2].
.MODEL SMALL
.STACK 100H
.CODE
START:
    PUSH BP
    MOV BP,SP
    SUB SP,2
    MOV WORD PTR [BP-2],0  ; BP-based addressing uses SS by default.
    MOV AX,1
    MOV CX,100
SUM_LOOP:
    ADD WORD PTR [BP-2],AX
    INC AX
    LOOP SUM_LOOP
    MOV AX,[BP-2]
    CALL PRINT_U16
    CALL NEWLINE
    MOV SP,BP
    POP BP
    MOV AX,4C00H
    INT 21H
INCLUDE PRINT.INC
END START
