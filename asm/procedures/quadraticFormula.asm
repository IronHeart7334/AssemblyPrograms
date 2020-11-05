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
_a WORD	 2d
_b WORD -3d
_c WORD  5d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

    push EBP ; set up stack frame
    mov EBP, ESP ; EBP now points to the address of the EBP I just pushed (the bottom of the stack frame)

    mov AX, _c
    cwd ; extend sign bit to fill 32 bits
    push EAX

    mov AX, _b
    cwd
    push AX

    mov AX, _a
    cwd
    push AX

    call discriminant
    pop EAX
    pop EAX
    pop EAX
    pop EBP ; pop old EBP back into EBP

	mov EAX, 0
	ret
main	ENDP



discriminant PROC
    mov EAX, 4d
    imul DWORD PTR [EBP + 4*3]; _a is located 3 frames above EBP
    imul DWORD PTR [EBP + 4*1]; EAX is now 4ac
    mov EBX, EAX ; move 4ac into EBX

    mov EAX, DWORD PTR [EBP + 4*2]; _b is located 2 frames above EBP
    imul EAX ; b^2 is now stored in EDX:EAX, but only takes up the lower half
    sub EAX, EBX ; EAX is now b^2 - 4ac

    ret
discriminant ENDP

END
