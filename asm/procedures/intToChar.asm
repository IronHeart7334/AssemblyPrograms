; general comments
;   Write an assembly program with the following prototype:
;       void unsignedIntegerByteToASCII(unsigned integer, char*);
;   The caller is responsible for providing a BYTE sized integer and a 3 BYTE array.
;   Do this conversion with integer division and a loop with powers of 10
;   As the last step in your procedure replace leading zeros with spaces
;   Be sure to plan out your logic in words.
;   Carefully plan out your register use.
;   Use register indirect addressing as often as you can.

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
intVal    BYTE 12d
byteArray BYTE 0, 0, 0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    ; Step 1: before calling the procedure, the caller must push parameters in reverse order
    lea EBX, byteArray
    push EBX
    ; can't push just a byte, so I need to zero-out the first 24 bits
    mov EBX, 0d
    mov BL, intVal
    push EBX

    ; Step 2: call the procedure
    call unsignedByteTo3Ascii

    ; Step 9: trash the parameters I passed
    pop EBX
    pop EBX

    mov EAX, 0
    ret
main ENDP

; void unsignedByteTo3Ascii(int convertMe, char* toHere);
; Register Dictionary:
;   - EBP is used to locate the stack frame
;   - EAX is used for division
;   - EBX holds a reference to the array parameter
;   - EDX is used for the divisor of division
unsignedByteTo3Ascii PROC
    ; Step 3: set up a stack frame as a fixed point on the stack
    push EBP
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address

    ; Step 4: save all register values. Has no return value, so save EAX
    pushfd
    push EDX
    push EBX
    push EAX

    ; Step 5: allocate temporary storage
    mov EAX, 0
    push EAX ; use this to hold the remainder
    push EAX ; use this to hold powers of 10
    push EAX ; use this to keep track of index
    ; Now the stack looks like this: (using higher addresses at the top)
    ; [rubbish                        ]
    ; [byteArray reference            ]
    ; [intVal                         ]
    ; [return address                 ]
    ; [old EBP                        ] <--- EBP
    ; [old EFLAGS                     ]
    ; [old EDX                        ]
    ; [old EBX                        ]
    ; [old EAX                        ]
    ; [allocated storage 1 (remainder)]
    ; [allocated storage 2 (10 power) ]
    ; [allocated storage 3 (index)    ] <--- ESP

    ; Step 6: now we get to the actual procedure
    mov EAX, DWORD PTR [EBP + 4*2]     ;
    mov DWORD PTR [EBP - 4*5], EAX     ; EBP - 4*5 contains the remainder of the number I'm converting
    mov EBX, DWORD PTR [EBP + 4*3]     ; EBX will keep track of where to write output to
    mov DWORD PTR [EBP - 4*6], 100d    ; current power of 10
    mov DWORD PTR [EBP - 4*7], 0d      ; number of digits processed
                                       ;
    checkIfDoneConverting:             ; loop for 3 digits
        cmp DWORD PTR [EBP - 4*7], 3d  ; WHILE (number of digits processed is less than 3)
        jae doneConverting             ;
                                       ;
        mov EAX, DWORD PTR [EBP - 4*5] ;    dividend is the remainder
        mov EDX, DWORD PTR [EBP - 4*6] ;    divisor is the current power of 10
        div DL                         ;    This "grabs" the highest digit, and puts it in AL
        add AL, 30h                    ;    convert the int in AL to the ASCII character representation
        mov BYTE PTR [EBX], AL         ;    copy the new ASCII character to the output
        inc EBX                        ;    advance to the next byte in output
                                       ;
        mov AL, AH                     ;    move the remainder after division over the dividend
        mov AH, 0d                     ;    high bits of EAX as still 0, so now EAX contains the remainder
        mov DWORD PTR [EBP - 4*5], EAX ;    update remainder
                                       ;
        mov EAX, DWORD PTR [EBP - 4*6] ;    now use EAX to hold the power of 10
        mov DL, 10d                    ;
        div DL                         ;    reduct power of 10 by 1 so I can grab the next digit on the next iteration
        mov AH, 0d                     ;    integer division, so ignore remainder
        mov DWORD PTR [EBP - 4*6], EAX ;    update power of 10
                                       ;
        inc DWORD PTR [EBP - 4*7]      ;    index++
        jmp checkIfDoneConverting      ;
    doneConverting:                    ; END WHILE
        ; done

    ; Replace leading zeros with spaces
    mov DWORD PTR [EBP - 4*7], 0d
    mov EBX, DWORD PTR [EBP + 4*3] ; back to the start of output
    checkIfLeadingZero:               ; WHILE (processed less than 2 digits and EBX points to a 0)
        cmp DWORD PTR [EBP - 4*7], 2d ; don't replace a 0 in the one's place
        jae doneCheckingForLeadingZero
        cmp BYTE PTR [EBX], "0"
        je replaceThatZero
        jmp doneCheckingForLeadingZero
        replaceThatZero:
            mov BYTE PTR [EBX], " "
            inc EBX
            inc DWORD PTR [EBP - 4*7]
            jmp checkIfLeadingZero
    doneCheckingForLeadingZero:      ; END WHILE
        ; done

    ; Step 7: free allocated storage
    pop EAX
    pop EAX
    pop EAX

    ; Step 8: restore everything back to the way it was
    pop EAX
    pop EBX
    pop EDX
    popfd
    pop EBP ; get rid of stack frame

    ret
unsignedByteTo3Ascii ENDP

END
