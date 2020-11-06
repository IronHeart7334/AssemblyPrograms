; general comments
;   Write a procedure given by the following C prototype:
;       int min(int a, int b)
;   where a and b are unsigned doubleword integers,
;   and min returns the smaller of them

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
_a DWORD -32d
_b DWORD  16d
; should yield -32d in EAX

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

	push EBP     ; set up stack frame
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address

    mov EAX, _b
    push EAX     ; push parameters in reverse order

    mov EAX, _a
    push EAX

    call min2    ; remember: this pushes the address of this to the stack,
    ; so before min2 exits, the stack will look like this:
    ; ESP -> [return address]
    ;        [FF FF FF E0 h] (_a)
    ;        [00 00 00 10 h] (_b)
    ; EBP -> [old EBP]

    pop EAX ; trash the parameters I passed
    pop EAX
    pop EBP ; restore EBP

	mov EAX, 0
	ret
main	ENDP

; Returns the smaller value contained in the 2 stack locations above EBP
; the smaller is returned in EAX
min2 PROC
    pushfd ; save EFLAGS for later
    push EBX
    push EDX ; save these two registers

    mov EBX, DWORD PTR [EBP - 4*2] ; _a is two frames above EBP
    mov EDX, DWORD PTR [EBP - 4*1]
    cmp EBX, EDX
    jl EBXIsSmaller ; IF EBX > EDX go to EBXIsSmaller
    mov EAX, EDX ; if EBX is not smaller, either they are the same, or EDX is smaller
    jmp cleanup
    EBXIsSmaller:
        mov EAX, EBX
        ; fall through to cleanup
    cleanup:
        pop EDX
        pop EBX
        popfd ; restore EFLAGS
    ret
min2 ENDP

END
