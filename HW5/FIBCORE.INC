; BX=n (preserved). Result at FIBVALS+n*10. DI tracks minimum SP.
; AX, DX, SI, FLAGS are scratch. No DOS calls in the recursive path.
FIB PROC NEAR
    CMP SP,DI
    JAE DEPTH_OK
    MOV DI,SP
DEPTH_OK:
    CMP BYTE PTR KNOWN[BX],0
    JNE FIB_DONE
    PUSH BX
    DEC BX
    CALL FIB                ; F(n-1); returns with BX=n-1.
    DEC BX
    CALL FIB                ; F(n-2); returns with BX=n-2.
    POP BX                  ; Restore this frame's n.
    MOV AX,BX
    MOV SI,10
    MUL SI
    MOV SI,AX               ; Byte index of F(n).
    MOV AX,FIBVALS[SI-10]
    ADD AX,FIBVALS[SI-20]
    MOV FIBVALS[SI],AX
    MOV AX,FIBVALS[SI-8]
    ADC AX,FIBVALS[SI-18]
    MOV FIBVALS[SI+2],AX
    MOV AX,FIBVALS[SI-6]
    ADC AX,FIBVALS[SI-16]
    MOV FIBVALS[SI+4],AX
    MOV AX,FIBVALS[SI-4]
    ADC AX,FIBVALS[SI-14]
    MOV FIBVALS[SI+6],AX
    MOV AX,FIBVALS[SI-2]
    ADC AX,FIBVALS[SI-12]
    MOV FIBVALS[SI+8],AX
    MOV BYTE PTR KNOWN[BX],1
FIB_DONE:
    RET
FIB ENDP
