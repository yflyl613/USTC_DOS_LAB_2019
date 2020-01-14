DATA SEGMENT
    ANS DB 20 DUP (0)
    VAL DB 20 DUP (0)
    VAL2 DB 20 DUP (0)
    MAXCHAR DB 3
    DIGITNUM DB ?
    INPUT DB 0,0,0
    TEN DB 10
DATA ENDS
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX
;GETINPUT
    MOV DX,OFFSET MAXCHAR
    MOV AH,0AH
    INT 21H

    XOR BX,BX
    SUB INPUT,30H
    MOV BL,INPUT
    CMP DIGITNUM,2  ;2 DIGIT OR NOT
    JNZ GETINPUTOK
    MOV AL,10
    MUL BL
    MOV BX,AX
    SUB INPUT[1],30H
    ADD BL,INPUT[1] ;INPUT DECIMAL IN BL
GETINPUTOK:
    CALL FACTORIAL    
    
DISPLAY:
    ;换行输出
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H   

    MOV SI,19
SKIPZERO:
    MOV DL,ANS[SI]
    DEC SI
    CMP DL,0
    JZ SKIPZERO
SHOWDIGIT:
    ADD DL,30H
    MOV AH,02H
    INT 21H
    MOV DL,ANS[SI]
    DEC SI
    CMP SI,-1
    JL EXIT
    JMP SHOWDIGIT

EXIT:
    MOV AX,4C00H
    INT 21H

FACTORIAL PROC  ;N IN BX
    CMP BX,1        ;recursion exit: n=1
    JNZ CONTINUE
    MOV ANS,1
    JMP FINISH
CONTINUE:
    PUSH BX         ;save n
    DEC BX
    CALL FACTORIAL  ;recursion
    POP BX          ;get n
    CMP BX,10
    JGE TWODIGIT
    ;one digit situation
    XOR CX,CX       ;CARRY IN CL
    XOR SI,SI
BIGMUL:
    XOR AX,AX
    MOV AL,ANS[SI]
    MUL BX          ;mul digit by digit
    DIV TEN         ;quotient IN AL, remainder IN AH
    ADD AH,CL       ;add carry
    CMP AH,10       ;check carry
    JL NOCARRY
    SUB AH,10
    INC AL
NOCARRY:    
    MOV CL,AL       ;new carry
    MOV VAL[SI],AH  ;save new digit in ans
    INC SI
    CMP SI,20    
    JZ MULFINISH
    JMP BIGMUL 
MULFINISH:
    XOR SI,SI
COPYTOANS:     
    MOV AL,VAL[SI]
    MOV ANS[SI],AL
    INC SI
    CMP SI,20   
    JNZ COPYTOANS
    JMP FINISH
;two digit situation
TWODIGIT:
    MOV VAL2[0],0   ;last digit of val2 is 0
    XOR SI,SI
    SUB BX,10       ;get the units digit of n
SHIFT:
    MOV DI,SI       ;shift ans into val because the tens digits of n is always 1
    INC DI
    MOV AL,ANS[SI]
    MOV VAL2[DI],AL
    INC SI
    CMP SI,20
    JNZ SHIFT
;2 digit become 1 digit situation
    XOR CX,CX       ;CARRY IN CL
    XOR SI,SI
BIGMUL2:
    XOR AX,AX
    MOV AL,ANS[SI]
    MUL BX
    DIV TEN         ;quotient IN AL, remainder IN AH
    ADD AH,CL
    CMP AH,10
    JL NOCARRY2
    SUB AH,10
    INC AL
NOCARRY2:    
    MOV CL,AL
    MOV VAL[SI],AH
    INC SI
    CMP SI,20     
    JZ MULFINISH2
    JMP BIGMUL2
MULFINISH2:
    XOR SI,SI
COPYTOANS2:     
    MOV AL,VAL[SI]
    MOV ANS[SI],AL
    INC SI
    CMP SI,20  
    JNZ COPYTOANS2
    
    XOR SI,SI
    XOR CX,CX       ;CARRY IN CL
SUM:
    MOV AL,ANS[SI]     ;add ans with val2
    ADD AL,VAL2[SI]
    ADD AL,CL
    XOR CL,CL
    CMP AL,10           ;check carry
    JL NOCARRY3
    SUB AL,10
    INC CL
NOCARRY3:
    MOV ANS[SI],AL
    INC SI
    CMP SI,20
    JNZ SUM
FINISH:
    RET
FACTORIAL ENDP

CODE ENDS
END START