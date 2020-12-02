; general comments
;   Create a console32 Assembly Language program to calculate the series
;       SIGMA of n from 0 to ? of (x + n)^(1/2)
;   where x is positive floating point number
;   Determine the number of terms required until the sum is at least 50 times as large as x.
; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
_x       REAL4 1.25
_sum     REAL4 0.0
temp     DWORD 0d
fifty    REAL4 50.0
_max     REAL4 0.0
numTerms DWORD 0d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    mov ECX, 0d ; use this to track the number of terms
    finit     ; ST(0) | ST(1)
    fld _x    ; _x      ~~~
    fld fifty ; 50      _x
    fmul      ; 50*_x   ~~~
    fstp _max ; ~~~     ~~~
    ; max is now set

    sigmaTop:
        finit ; need to do this at the start of each iteration
        ; re-load values
        ; Instruction | ST(0) | ST(1)
        fld _max      ; _max    ~~~
        fld _sum      ; _sum    _max
        fcom
        fstsw AX ; Float Store The Status Word
        sahf     ; Store AH in Flags
        jae sigmaEnd ; exit if sum >= max
    sigmaBody:
        ; Instruction | ST(0)          | ST(1) | ST(2) | ST(3)
                      ; _sum            _max    ~~~     ~~~
        mov temp, ECX ;
        fild temp     ; ECX             _sum    _max    ~~~
        fld _x        ; _x              ECX     _sum    _max
        fadd          ; _x+ECX          _sum    _max    ~~~
        fsqrt         ;sqrt(x+ECX)      _sum    _max    ~~~
        fadd          ;_sum+sqrt(x+ECX) _max    ~~~     ~~~
        fstp _sum     ; _max            ~~~     ~~~     ~~~
        inc ECX
        jmp sigmaTop
    sigmaEnd:
        ; ECX will now contain the number of terms
        mov numTerms, ECX

	mov EAX, 0
	ret
main	ENDP

END
