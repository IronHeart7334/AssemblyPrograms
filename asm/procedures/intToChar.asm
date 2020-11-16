; general comments
;   Write an assembly program with the following prototype:
;       void unsignedIntegerByteToASCII(unsigned integer, char*);
;   The calling procedure is responsible for allocating a three element byte array.
;   Do this conversion with integer division and a loop with powers of 10
;   As the last step in your procedure replace leading zeros with spaces
;   Be sure to plan out your logic in words.
;   Carefully plan out your register use.
;   Use register indirect addressing as often as you can

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
    mov EBX, 0d
    mov BL, intVal
    push EBX

    ; Step 2: call the procedure
    call signedByteTo3Ascii ; remember: this pushes the address of this to the stack

    ; Step 9: trash the parameters I passed
    pop EBX
    pop EBX

    mov EAX, 0
    ret
main ENDP

; void signedByteTo3Ascii(int convertMe, char* toHere);
signedByteTo3Ascii PROC
    ; Step 3: set up a stack frame as a fixed point on the stack
    push EBP     ; set up stack frame
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address
    ; Now the stack looks like this: (using higher addresses at the top)
    ;               [rubbish]
    ;               [byteArray address]
    ;               [intVal]
    ;               [return address]
    ; ESP -> EBP -> [old EBP]
    ; ESP can move around, so I only care about addresses relative to EBP

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
    ;               [rubbish]
    ;               [byteArray address]
    ;               [intVal]
    ;               [return address]
    ;        EBP -> [old EBP]
    ;               [old EFLAGS]
    ;               [old EDX]
    ;               [old EBX]
    ;               [old EAX]
    ;               [allocated storage 1 (remainder)]
    ;               [allocated storage 2 (10 power)]
    ;        ESP -> [allocated storage 3 (index)]

    ; Step 6: now we get to the actual procedure
    mov DWORD PTR [EBP - 4*5], DWORD PTR [EBP + 4*2] ; int remainder = convertMe;
    mov EBX, DWORD PTR [EBP + 4*3]                   ; char* destination = toHere;
    mov DWORD PTR [EBP - 4*6], 100d                  ; int tenPow = 100;
    mov DWORD PTR [EBP - 4*7], 0d                    ; int index = 0;

    checkIfDoneConverting:                           ; while(index < 3){
        cmp DWORD PTR [EBP - 4*7], 3d
        jae doneConverting

        inc DWORD PTR [EBP - 4*5]                    ;    index++;
        jmp checkIfDoneConverting
    doneConverting:                                  ; }
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
signedByteTo3Ascii ENDP

END
