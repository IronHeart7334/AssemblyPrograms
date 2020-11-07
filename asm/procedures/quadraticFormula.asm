; general comments
;   Practice Problem: write a procedure given by:
;   int discriminant(int a, int b, int c)
;   where -1000d <= a, b, c <= 1000d

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
_a DWORD 2d
_b DWORD 5d
_c DWORD 3d
; discriminant should be 1d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    mov EAX, _c ; push arguments in reverse order
    push EAX
    mov EAX, _b
    push EAX
    mov EAX, _a
    push EAX

    call discriminant

    pop EAX
    pop EAX
    pop EAX

	mov EAX, 0
	ret
main	ENDP



discriminant PROC
    push EBP ; set up stack frame
    mov EBP, ESP ; EBP now points to the address of the EBP I just pushed (the bottom of the stack frame)

    push EBX
    push EDX
    pushfd ; save old values

    mov EAX, 4d
    imul DWORD PTR [EBP + 4*2]; _a is located 2 frames above EBP
    imul DWORD PTR [EBP + 4*4]; EAX is now 4ac
    mov EBX, EAX ; move 4ac into EBX

    mov EAX, DWORD PTR [EBP + 4*3]; _b is located 3 frames above EBP
    imul EAX ; b^2 is now stored in EDX:EAX, but only takes up the lower half
    sub EAX, EBX ; EAX is now b^2 - 4ac

    popfd
    pop EDX
    pop EBX

    pop EBP ; pop old EBP back into EBP

    ret
discriminant ENDP

END
