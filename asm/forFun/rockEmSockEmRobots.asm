; general comments
;   This is a template for how to do procedures following the cdelc style

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
randomSeed       DWORD 0F1A3C5E7h
randomRotate     BYTE         35d
robot1HP         BYTE         20d
robot2HP         BYTE         20d
winnerRobot      BYTE         "_"
msg              BYTE "Robot _ wins!", 0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    ; First, set up the "random" number in EDX
    mov EDX, randomSeed
    mov CL, randomRotate
    ror EDX, CL ; EDX contains the new "random" number

    ; Before calling the procedure, the caller must push parameters in reverse order
    push EDX
    mov EDX, 0
    mov DH, robot1HP
    mov DL, robot2HP
    push EDX ; encode and push both robots' HP at once to save space

    call robotFight

    ; After calling the procedure, the caller must pop the parameters it passed
    pop EDX
    pop EDX

    ; Retrieve robot HPs after the fight from EAX
    mov robot1HP, AH
    mov robot2HP, AL

    ; Check who the winner is
    cmp AH, 0 ; IF(robot1HP == 0)
    je robot2Wins ; robot 2 has KOed robot 1
    mov winnerRobot, "1" ; else robot 1 wins
    jmp fillInMessage
    robot2Wins:
        mov winnerRobot, "2"
    fillInMessage:
        lea EBX, msg
        mov BYTE PTR [EBX + 1*6], winnerRobot ; set the 6th character of the message

    mov EAX, 0
    ret
main ENDP

robotFight PROC
    ret
robotFight ENDP




; cdecl says that a procedure must leave all registers (except for EAX) and the stack as it found them
; it returns its value in EAX
; and is not allowed to access named memory locations
; this example in c would be
;   int myProc(int a, int b, int c){
;        int d = a - b;
;        int e = a + c;
;        return d + e;
;   }
myProc PROC
    ; Step 3: set up a stack frame as a fixed point on the stack
    push EBP     ; set up stack frame
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address
    ; Now the stack looks like this: (using higher addresses at the top)
    ; [rubbish       ]
    ; [param3        ]
    ; [param2        ]
    ; [param1        ]
    ; [return address]
    ; [old EBP       ] <- EBP <- ESP
    ; ESP can move around, so I only care about addresses relative to EBP

    ; Step 4: save all register values except for EAX (the return value)
    pushfd
    push EBX

    ; Step 5: (optional) allocate temporary storage (saves on register usage)
    mov EBX, 0 ; don't need to 0-out first
    push EBX
    push EBX
    ; Now the stack looks like this: (using higher addresses at the top)
    ; [rubbish            ]
    ; [param3             ]
    ; [param2             ]
    ; [param1             ]
    ; [return address     ]
    ; [old EBP            ] <- EBP
    ; [old EFLAGS         ]
    ; [old EBX            ]
    ; [allocated storage 1](d)
    ; [allocated storage 2](e) <- ESP

    ; Step 6: now we get to the actual procedure
    mov EAX, DWORD PTR [EBP + 4*2] ; first parameter is two frames above EBP, as the return address is one above
    sub EAX, DWORD PTR [EBP + 4*3] ; EAX is now a - b
    mov DWORD PTR [EBP - 4*3], EAX ; store a - b in d
    mov EAX, DWORD PTR [EBP + 4*2] ; EAX is param a again
    add EAX, DWORD PTR [EBP + 4*4] ; EAX is a + c
    mov DWORD PTR [EBP - 4*4], EAX ; store a + c in d (don't need to do, but this is an example)
    mov EAX, DWORD PTR [EBP - 4*3] ; EAX is a - b
    add EAX, DWORD PTR [EBP - 4*4] ; EAX = d + e = a - b + a + c = 2a - b + c

    ; Step 7: free allocated storage
    pop EBX
    pop EBX

    ; Step 8: restore everything (except EAX) back to the way it was
    pop EBX
    popfd
    pop EBP ; get rid of stack frame

    ret
myProc ENDP

END
