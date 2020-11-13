; general comments
;   Write a procedure given by the following C prototype:
;       int min(int a, int b)
;   where a and b are signed doubleword integers,
;   and min returns the smaller of them
;
;   Write another procedure with this prototype:
;       int min4Signed(int a, int b, int c, int d);
;   which invokes min2

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
_a DWORD -32d
_b DWORD 0FFFFFFFFh
_c DWORD  16d
_d DWORD 9999d
; should yield FF FF FF E0 h in EAX

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    mov EAX, _d
    push EAX

    mov EAX, _c
    push EAX

    mov EAX, _b
    push EAX

    mov EAX, _a
    push EAX

    call min4Signed
    ; so before min2 exits, the stack will look like this:
    ;        [rubbish]
    ;        [d]
    ;        [c]
    ;        [b]
    ;        [a]
    ; ESP -> [return address]

    pop EAX ; trash the parameters I passed
    pop EAX
    pop EAX
    pop EAX

	mov EAX, 0
	ret
main	ENDP

; Returns the smaller value contained in the 2 stack locations above EBP
; the smaller is returned in EAX
min2 PROC
    push EBP     ; set up stack frame
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address
    ; Now the stack looks like this:
    ;               [rubbish]
    ;               [b]
    ;               [a]
    ;               [return address]
    ; ESP -> EBP -> [old EBP]
    ; ESP can move around, so I only care about addresses relative to EBP

    ; cdecl says to save all register values except for EAX (the return value)
    pushfd
    push EBX
    push EDX

    ; now we get to the actual procedure
    mov EBX, DWORD PTR [EBP + 4*2] ; _a is two frames above EBP, as the return address is one above
    mov EDX, DWORD PTR [EBP + 4*3]
    cmp EBX, EDX
    jl EBXIsSmaller ; IF EBX > EDX go to EBXIsSmaller
    mov EAX, EDX ; if EBX is not smaller, either they are the same, or EDX is smaller
    jmp cleanup
    EBXIsSmaller:
        mov EAX, EBX
        ; fall through to cleanup
    cleanup: ; cdecl says to restore everything (except EAX) back to the way it was
        pop EDX
        pop EBX
        popfd
        pop EBP ; get rid of stack frame
    ret
min2 ENDP


min4Signed PROC
    push EBP
    mov EBP, ESP
    ; STACK
    ; [...]
    ; [d]
    ; [c]
    ; [b]
    ; [a]
    ; [return address]
    ; [old EBP] <-- EBP <-- ESP

    pushfd
    push EDX


    mov EDX, 0
    push EDX
    push EDX ; allocate two DWORDs on the stack

    ; STACK
    ; [...]
    ; [d]
    ; [c]
    ; [b]
    ; [a]
    ; [return address]
    ; [old EBP] <-- EBP
    ; [old EFLAGS]
    ; [old EDX]
    ; [allocated 1]
    ; [allocated 2]

    ; Evaluate as a tree:
    ; a     b c      d
    ; \    /   \    /
    ;  min2     min2
    ;    \        /
    ;     \      /
    ;       min2

    ; set up call to min2 of a and b
    push DWORD PTR [EBP + 4*3] ; b
    push DWORD PTR [EBP + 4*2] ; a
    call min2 ; EAX now holds the smaller of a and b
    mov DWORD PTR [EBP - 4*3], EAX ; save min of a and b in first allocated space
    pop EDX ; clean up params
    pop EDX

    ; next, call to min2 of c and d
    push DWORD PTR [EBP + 4*5] ; d
    push DWORD PTR [EBP + 4*4] ; c
    call min2 ; EAX now holds the smaller of c and d
    mov DWORD PTR [EBP - 4*4], EAX; move into allocated space
    pop EDX ; clean up params
    pop EDX

    ; lastly, call min2 on the two results
    push DWORD PTR [EBP - 4*4] ; min2 of c and d
    push DWORD PTR [EBP - 4*3] ; min2 of a and b
    call min2 ; EAX holds return value of this procedure
    pop EDX
    pop EDX

    ; get rid of allocated memory
    pop EDX
    pop EDX

    ; restore registers
    pop EDX
    popfd

    pop EBP
    ret
min4Signed ENDP


END
