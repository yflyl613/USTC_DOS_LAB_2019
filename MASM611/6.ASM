.386
DATA SEGMENT
    INTER DB 50 DUP (30H)
    ANS REAL8 0.0
    WHOLE DD 0
    FRACT REAL8 0.0
    TEMP DW 0
    TEN DW 10
    PROMPT1 DB "x = $"
    PROMPT2 DB "a1 = $"
    PROMPT3 DB "a2 = $"
    PROMPT4 DB "a3 = $"
    PROMPT5 DB "Error: x<0!$"
    SIGNFLAG DB 0
    X REAL8 0.0
    A1 REAL8 0.0
    A2 REAL8 0.0
    A3 REAL8 0.0
    MAXCHAR DB 20
    COUNT DB 0
    INPUTBUFFER DB 20 DUP (?)
    MED REAL8 0.0
    DOT REAL8 0.1
    BUF DW 0
DATA ENDS
STACK SEGMENT STACK
    DW 10 DUP (?)
STACK ENDS
CODE SEGMENT USE16
    ASSUME CS:CODE,DS:DATA,SS:STACK
START:
    MOV AX,DATA
    MOV DS,AX
    ;GET X
    MOV DX,OFFSET PROMPT1
    MOV AH,09H
    INT 21H
    CALL GETINPUT
    FLD MED             ;legal or not
    FTST
    FSTSW AX            ;GET STATUS WORD
    AND AX,4500H        ;GET C0,C2,C3
    CMP AX,100H
    JNZ LEGAL
    ;\N
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
    ;ERROR
    MOV DX,OFFSET PROMPT5
    MOV AH,09H
    INT 21H
    ;\N
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
    JMP START

LEGAL:
    FSTP X      ;store x
    ;\N
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
    ;GET A1
    MOV DX,OFFSET PROMPT2
    MOV AH,09H
    INT 21H
    CALL GETINPUT
    FLD MED
    FSTP A1         ;store a1
    ;\N
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
    ;GET A2
    MOV DX,OFFSET PROMPT3
    MOV AH,09H
    INT 21H
    CALL GETINPUT
    FLD MED
    FSTP A2         ;store a2
    ;\N
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
    ;GET A3
    MOV DX,OFFSET PROMPT4
    MOV AH,09H
    INT 21H
    CALL GETINPUT
    FLD MED
    FSTP A3         ;store a3
    ;\N
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H
;INPUTREADY
    FLD X
    FSQRT   
    FLD A1
    FMUL        ;a1 * sqrt(x)
    FLD A2
    FLD X
    FYL2X       ;a2 * log2(x)
    FLD X
    FSIN
    FLD A3
    FMUL        ;a3 * sin(x)
    FADD
    FADD
    FSTP ANS    ;store answer
    CALL FTOA   ;display
    JMP EXIT

GETINPUT PROC NEAR
    FLDZ            ;init float stack
    MOV BYTE PTR SIGNFLAG,0
    MOV DX,OFFSET MAXCHAR
    MOV AH,0AH      ;input number string
    INT 21H
    XOR ESI,ESI
    XOR EBX,EBX
    XOR ECX,ECX
GETNEXTCHAR: 
    XOR EAX,EAX
    MOV AL,COUNT
    CMP SI,AX
    JZ INPUTFIN
    MOV BL,INPUTBUFFER[SI]
    CMP BL,'-'      ;neg or not
    JNZ POS
    MOV BYTE PTR SIGNFLAG,1
    INC SI
    JMP GETNEXTCHAR
POS:
    ;INT IN CX
    CMP BL,'.'      
    JZ GETFRACT
    SUB EBX,30H     ;interger part
    MOV AX,10
    MUL CX
    MOV CX,AX
    ADD CX,BX
    INC ESI
    JMP GETNEXTCHAR
GETFRACT:
    XOR EAX,EAX
    MOV AL,COUNT    ;from last to first
    MOV EDI,EAX  ;LAST DIGIT
    DEC EDI
COUNTFRACT:
    XOR EBX,EBX
    MOV BL,INPUTBUFFER[EDI]
    SUB BX,30H      
    MOV BUF,BX
    FMUL DOT
    FIADD BUF
    DEC EDI
    CMP EDI,ESI
    JNZ COUNTFRACT
INPUTFIN:
    FMUL DOT
    MOV BUF,CX
    FIADD BUF
    CMP BYTE PTR SIGNFLAG,0
    JZ POSITIVE
    FCHS            ;change to neg
    MOV BYTE PTR SIGNFLAG,0
POSITIVE:
    FSTP MED
    RET
GETINPUT ENDP


FTOA PROC NEAR USES EBX ECX EDX
    MOV ECX,0       ;STRING INDEX
    FSTCW TEMP      ;SAVE CONTROL WORD
    MOV AX,TEMP
    OR AX,0C00H     ;change to cut
    MOV TEMP,AX
    FLDCW TEMP
    FLD ANS
    FTST
    FSTSW AX            ;GET STATUS WORD
    AND AX,4500H        ;GET C0,C2,C3
    .IF AX == 100H      ;is negative
        MOV DL,'-'      ;output '-'
        MOV AH,02H
        INT 21H
        FABS            ;chagne to positive
    .ENDIF
    FRNDINT             ;MAKE STACK TOP TO BE INT
    FIST WHOLE          ;STORE INT
    FLD ANS
    FABS
    FSUBR
    FSTP FRACT          ;STORE FRACTION
    MOV EAX,WHOLE
    MOV EBX,10
    .REPEAT             ;CHANGE interger part INTO ASCII
        MOV EDX,0
        DIV EBX         ;quotient in eax, remain in edx
        ADD INTER[ECX],DL
        INC ECX
    .UNTIL EAX == 0

    MOV EDI,ECX
    DEC EDI
DISPLAYINT:
    MOV DL,INTER[EDI]
    MOV AH,02H
    INT 21H
    DEC EDI
    CMP EDI,0
    JGE DISPLAYINT
    MOV DL,'.'          
    MOV AH,02H
    INT 21H

    FLD FRACT
DISPLAYFRAC:
    FTST
    FSTSW AX            ;GET STATUS WORD
    AND AX,4500H        ;GET C0,C2,C3
    CMP AX,0            ;fraction part is zero
    JNZ OK
    FIMUL TEN       
    FIST TEMP           ;mul 10 and get the integer part
    MOV AX,TEMP
    MOV DL,AL
    ADD DL,30H
    MOV AH,02H
    INT 21H
    FISUB TEMP
    JMP DISPLAYFRAC

OK:
    FCOMP
    RET
FTOA ENDP

EXIT:
    MOV AX,4C00H
    INT 21H
CODE ENDS
END START