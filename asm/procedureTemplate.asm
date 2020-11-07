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

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    ; Step 1: before calling the procedure, the caller must push parameters in reverse order
    mov EAX, param2
    push EAX
    mov EAX, param1
    push EAX

    ; Step 2: call the procedure
    call myProc ; remember: this pushes the address of this to the stack

    ; Step 7: trash the parameters I passed
    pop EAX
    pop EAX

    mov EAX, 0
    ret
main ENDP

; cdecl says that a procedure must leave all registers (except for EAX) and the stack as it found them
; it returns its value in EAX
; and is not allowed to access named memory locations
; this example in c would be
;   int myProc(int a, int b){
;       return a - b;
;   }
myProc PROC
    ; Step 3: set up a stack frame as a fixed point on the stack
    push EBP     ; set up stack frame
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address
    ; Now the stack looks like this: (using higher addresses at the top)
    ;               [rubbish]
    ;               [param2]
    ;               [param1]
    ;               [return address]
    ; ESP -> EBP -> [old EBP]
    ; ESP can move around, so I only care about addresses relative to EBP

    ; Step 4: save all register values except for EAX (the return value)
    pushfd
    push EBX

    ; Step 5: now we get to the actual procedure
    mov EAX, DWORD PTR [EBP + 4*2] ; first parameter is two frames above EBP, as the return address is one above
    mov EBX, DWORD PTR [EBP + 4*3]
    sub EAX, EBX

    ; Step 6: restore everything (except EAX) back to the way it was
    pop EBX
    popfd
    pop EBP ; get rid of stack frame

    ret
myProc ENDP

END
