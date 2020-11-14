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
param1 DWORD 1d
param2 DWORD 2d
param3 DWORD 3d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    ; Step 1: before calling the procedure, the caller must push parameters in reverse order
    mov EAX, param3
    push EAX
    mov EAX, param2
    push EAX
    mov EAX, param1
    push EAX

    ; Step 2: call the procedure
    call myProc ; remember: this pushes the address of this to the stack

    ; Step 9: trash the parameters I passed
    pop EAX
    pop EAX
    pop EAX

    mov EAX, 0
    ret
main ENDP

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
    ;               [rubbish]
    ;               [param3]
    ;               [param2]
    ;               [param1]
    ;               [return address]
    ; ESP -> EBP -> [old EBP]
    ; ESP can move around, so I only care about addresses relative to EBP

    ; Step 4: save all register values except for EAX (the return value)
    pushfd
    push EBX

    ; Step 5: (optional) allocate temporary storage (saves on register usage)
    mov EBX, 0 ; don't need to 0-out first
    push EBX
    push EBX
    ; Now the stack looks like this: (using higher addresses at the top)
    ;               [rubbish]
    ;               [param3]
    ;               [param2]
    ;               [param1]
    ;               [return address]
    ;        EBP -> [old EBP]
    ;               [old EFLAGS]
    ;               [old EBX]
    ;               [allocated storage 1](d)
    ;        ESP -> [allocated storage 2](e)

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
