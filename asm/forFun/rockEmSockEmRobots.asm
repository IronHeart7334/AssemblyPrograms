; general comments
;   Rock-Em-Sock-Em-Robots

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
randomSeed       DWORD 0F1A3C5E7h        ; These first two are used as a psuedo-random number generator
randomRotate     BYTE         35d        ; plus, this gives me practice with bitwise operations
robot1HP         BYTE         20d        ; Each robot starts with 20 HP
robot2HP         BYTE         20d        ; don't need some of this named memory, but it makes things clearer for me.
winnerRobot      BYTE         "_"        ;
msg              BYTE "Robot _ wins!", 0 ; I'm trying out character insertion

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    ; First, set up the "random" number in EDX
    mov EDX, randomSeed
    mov CL, randomRotate
    ror EDX, CL ; EDX contains the new "random" number

    ; Before calling the procedure, the caller must push parameters in reverse order
    push EDX ; push random number
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
    cmp AH, 0            ; IF(robot1HP == 0)
    je robot2Wins        ; robot 2 has KOed robot 1
    mov winnerRobot, "1" ; else robot 1 wins
    jmp fillInMessage
    robot2Wins:
        mov winnerRobot, "2"
    fillInMessage:
        lea EBX, msg
        mov AL, winnerRobot
        mov BYTE PTR [EBX + 1*6], AL ; set the 6th character of the message

    mov EAX, 0
    ret
main ENDP

; int robotFight(int robotHps, int randomNumber)
robotFight PROC
    ; Set up stack frame
    push EBP
    mov EBP, ESP

    ; Save registers
    pushfd
    push EDX

    ; Allocate stack space
    push DWORD PTR [EBP + 4*3] ; copy random number parameter to local random number

    ; Now the stack looks like this: (using higher addresses at the top)
    ; [rubbish        ]
    ; [random number  ]
    ; [robot HPs      ]
    ; [return address ]
    ; [old EBP        ] <- EBP
    ; [old EFLAGS     ]
    ; [local random   ] <- ESP

    ; Now the robots take turns hitting each other
    mov EDX, DWORD PTR [EBP + 4*2] ; EDX now holds local robot HPs
    checkForKo: ; check if either robot is knocked out
        cmp DH, 0
        je koOccurred
        cmp DL, 0
        je koOccurred
    robot1PunchRobot2:
        ; push random number to get damage
        push DWORD PTR [EBP - 4*2]
        call getDamage ; AL contains the damage
        pop DWORD PTR [EBP - 4*2]
        ror DWORD PTR [EBP - 4*2], 1d ; next "random" number
        cmp DL, AL
        jb robot2DamageOverflow
        jmp robot2TakeDamage
        robot2DamageOverflow:
            mov AL, DL ; cap damage at robot HP to prevent overflow
        robot2TakeDamage:
            sub DL, AL ; POW!
        ; check if robot 2 can punch back
        cmp DL, 0
        je koOccurred ; nope! He's down for the count!
    robot2PunchRobot1:
        ; push random number to get damage
        push DWORD PTR [EBP - 4*2]
        call getDamage ; EAX contains the damage
        pop DWORD PTR [EBP - 4*2]
        ror DWORD PTR [EBP - 4*2], 1d ; next "random" number
        cmp DH, AL
        jb robot1DamageOverflow
        jmp robot1TakeDamage
        robot1DamageOverflow:
            mov AL, DH ; cap damage at robot HP to prevent overflow
        robot1TakeDamage:
            sub DH, AL ; POW!
        jmp checkForKo
    koOccurred:
        ; one robot knocked the other's block off

    ; Set return value to local robot HPs
    mov EAX, EDX

    ; Free stack space
    pop EDX

    ; restore registers
    pop EDX
    popfd

    ; restore EBP
    pop EBP

    ret
robotFight ENDP

; int getDamage(int randomNumber)
getDamage PROC
    ; Set up stack frame
    push EBP
    mov EBP, ESP

    ; Save registers
    pushfd

    ; Now the stack looks like this: (using higher addresses at the top)
    ; [rubbish        ]
    ; [random number  ]
    ; [return address ]
    ; [old EBP        ] <- EBP
    ; [old EFLAGS     ]
    ; [old EDX        ] <- ESP

    ; Instruction                  | minimum AL | maximum AL
    mov EAX, DWORD PTR [EBP + 4*1] ; 0            2^8 - 1
    shr AL, 6d                     ; 0            2^2 - 1
    inc AL                         ; 1            2^2
    shl EAX, 24d
    shr EAX, 24d ; clear all bits of A register except for AL

    ; Restore registers
    popfd

    ; Take down stack frame
    pop EBP

    ret
getDamage ENDP

END
