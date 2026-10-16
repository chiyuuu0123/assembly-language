; DOS buffered keyboard input. Accepts 1..100, up to three digits.
.MODEL SMALL
.STACK 100H
.DATA
PROMPT DB 'Enter n (1-100): $'
BADMSG DB 'Invalid input. Enter an integer from 1 to 100.',0DH,0AH,'$'
RESULT DB 'Result: $'
INBUF DB 8,0,8 DUP(0)      ; Max length includes final CR space.
.CODE
START:
    MOV AX,@DATA
    MOV DS,AX
READ_AGAIN:
    LEA DX,PROMPT
    MOV AH,09H
    INT 21H
    MOV BYTE PTR [INBUF+1],0
    LEA DX,INBUF
    MOV AH,0AH             ; DS:DX -> DOS line input buffer.
    INT 21H
    CALL NEWLINE
    XOR CX,CX
    MOV CL,[INBUF+1]       ; Actual length excludes CR.
    JCXZ BAD_INPUT
    CMP CX,3
    JA BAD_INPUT
    LEA SI,INBUF+2
    XOR AX,AX
    MOV BX,10
PARSE_DIGIT:
    MOV DL,[SI]
    CMP DL,'0'
    JB BAD_INPUT
    CMP DL,'9'
    JA BAD_INPUT
    SUB DL,'0'
    XOR DH,DH
    PUSH DX
    MUL BX                 ; AX = old value * 10 (at most 990).
    POP DX
    ADD AX,DX
    INC SI
    LOOP PARSE_DIGIT
    CMP AX,1
    JB BAD_INPUT
    CMP AX,100
    JA BAD_INPUT
    MOV CX,AX
    LEA DX,RESULT
    MOV AH,09H
    INT 21H
    XOR AX,AX
    MOV BX,1
SUM_LOOP:
    ADD AX,BX
    INC BX
    LOOP SUM_LOOP
    CALL PRINT_U16
    CALL NEWLINE
    MOV AX,4C00H
    INT 21H
BAD_INPUT:
    LEA DX,BADMSG
    MOV AH,09H
    INT 21H
    JMP READ_AGAIN
INCLUDE PRINT.INC
END START
