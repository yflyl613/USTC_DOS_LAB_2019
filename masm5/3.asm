DATA SEGMENT
    FILENAME DB 'INPUT3.TXT',0
    READBUFFER DB 600 DUP(?)
    DATABUFFER DW 100 DUP(?)
    NEGFLAG DB 0
    TEN DB 10
    LENMONE DW ?
    DISPLAYBUFFER DB 5 DUP(?)
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX

    MOV DX,OFFSET FILENAME
    MOV AL,00H
    MOV AH,3DH
    INT 21H
    JNC OPENFILEOK 
    JMP EXIT
OPENFILEOK:
    MOV BX,AX   ;file handler in BX
    MOV DX,OFFSET READBUFFER    ;READ DATA
    MOV CX,600
    MOV AH,3FH
    INT 21H
    MOV CX,AX
    
    XOR DX,DX  ;NUMBER OF DATA IN DX
    XOR DI,DI  ;READ BYTE INDEX IN DI
    XOR BX,BX  ;ONE BYTE IN BX
    XOR SI,SI  ;DATA INDEX IN SI
    XOR AX,AX  ;ONE DATA IN AX
GETDATA:
    MOV BL,READBUFFER[DI]
    CMP BL,0AH      ;\n
    JZ NEWDATAGET
    JMP NOTEND
NEWDATAGET:
    INC DX
    CMP NEGFLAG,1   ;negative or not
    JNZ MOVDATA 
    NEG AX
MOVDATA:
    MOV DATABUFFER[SI],AX      ;store number
    ADD SI,2
    XOR AX,AX   ;CLEAR DATA IN AX
    MOV BYTE PTR NEGFLAG,0
    JMP NEXTDIGIT
NOTEND:
    CMP BL,2DH      ;-
    JZ ISNEG 
    JMP ISNUM
ISNEG:
    MOV BYTE PTR NEGFLAG,1
    JMP NEXTDIGIT
ISNUM:
    MUL BYTE PTR TEN
    SUB BX,30H
    ADD AX,BX
    
NEXTDIGIT:
    INC DI
    LOOP GETDATA
    
;BUBBLESORT
    MOV LENMONE,DX
    DEC LENMONE ;N-1 IN LENMONE
    XOR CX,CX   ;I=0..N-1 IN CX
OUTERLOOP:
    CMP CX,LENMONE
    JGE SORTFINISH
    XOR SI,SI   ;J=0,N-1-I IN SI
INNERLOOP:
    MOV DI,LENMONE
    SUB DI,CX   ;N-1-I IN DI
    CMP SI,DI
    JGE INNERLOOPFINISH

    MOV DI,SI
    SHL DI,1 
    MOV AX,DATABUFFER[DI]
    CMP AX,DATABUFFER[DI+2]    ;bigger then exchange
    JLE ONELOOPFINISH
    MOV BX,AX
    MOV AX,DATABUFFER[DI+2]
    MOV DATABUFFER[DI+2],BX
    MOV DATABUFFER[DI],AX
 
ONELOOPFINISH:
    INC SI
    JMP INNERLOOP

INNERLOOPFINISH:
    INC CX
    JMP OUTERLOOP

SORTFINISH:
    XOR SI,SI
    MOV CX,DX
    XOR BX,BX
DISPLAYDATA:
    MOV AX,DATABUFFER[SI]
    MOV BYTE PTR DISPLAYBUFFER,0           ;synbol byte
    MOV BYTE PTR DISPLAYBUFFER[1],30H      ;data byte
    MOV BYTE PTR DISPLAYBUFFER[2],30H
    MOV BYTE PTR DISPLAYBUFFER[3],30H
    MOV BYTE PTR DISPLAYBUFFER[4],30H
    ADD SI,2
    CMP AX,0
    JGE POSITIVE
    MOV BYTE PTR DISPLAYBUFFER,2DH
    NEG AX
POSITIVE:
    MOV DI,4
NEXT:
    CMP AX,9                                
    JLE FINISH
    DIV BYTE PTR TEN                        ;change to deciaml ascii
    ADD BYTE PTR DISPLAYBUFFER[DI],AH
    MOV AH,00H
    DEC DI
    JMP NEXT
FINISH:
    ADD BYTE PTR DISPLAYBUFFER[DI],AL
    MOV DL,BYTE PTR DISPLAYBUFFER
    CMP DL,0              ;check symbol byte
    JZ NOTNEG
    MOV AH,02H
    INT 21H
NOTNEG:                   ;check whether is zero before
    MOV DL,BYTE PTR DISPLAYBUFFER[1]
    CMP DL,30H
    JZ FOURISZERO
    MOV AH,02H
    INT 21H
    MOV DL,BYTE PTR DISPLAYBUFFER[2]
    MOV AH,02H
    INT 21H
    MOV DL,BYTE PTR DISPLAYBUFFER[3]
    MOV AH,02H
    INT 21H
    MOV DL,BYTE PTR DISPLAYBUFFER[4]
    MOV AH,02H
    INT 21H
    JMP NEXTLINE
FOURISZERO:
    MOV DL,BYTE PTR DISPLAYBUFFER[2]
    CMP DL,30H
    JZ THREEISZERO
    MOV AH,02H
    INT 21H
    MOV DL,BYTE PTR DISPLAYBUFFER[3]
    MOV AH,02H
    INT 21H
    MOV DL,BYTE PTR DISPLAYBUFFER[4]
    MOV AH,02H
    INT 21H
    JMP NEXTLINE
THREEISZERO:
    MOV DL,BYTE PTR DISPLAYBUFFER[3]
    CMP DL,30H
    JZ TWOISZERO
    MOV AH,02H
    INT 21H
    MOV DL,BYTE PTR DISPLAYBUFFER[4]
    MOV AH,02H
    INT 21H
    JMP NEXTLINE
TWOISZERO:
    MOV DL,BYTE PTR DISPLAYBUFFER[4]
    MOV AH,02H
    INT 21H
NEXTLINE:
    ;换行输出
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    MOV AH,02H
    INT 21H   
   
    DEC CX
    JZ EXIT
    JMP DISPLAYDATA
EXIT:
    MOV AX,4C00H
    INT 21H
CODE ENDS
END START