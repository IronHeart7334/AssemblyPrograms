; general comments
;   This program computes PI using the Tailor Polynomial of inverse tangent.
;
;   1.
;       1 / (1 - x) = the sum of (n from 0 to infinity) of x^n
;   2.
;       let x = -x
;       1 / (1 + x) = the sum of (n from 0 to infinity) of (-x)^n
;   3.
;       let x = x^2
;       1 / (1 + x^2) = the sum of (n from 0 to infinity) of (-x)^2n
;   4. Integrate both sides with respect to x
;       arctan(x) = the sum of (n from 0 to infinity) of ((-x)^(2n+1))/(2n+1)
;   5. let x = 1
;       arctan(1) = the sum of (n from 0 to infinity) of ((-1)^(2n+1))/(2n+1)
;       pi/4 = the sum of (n from 0 to infinity) of ((-1)^(2n+1))/(2n+1)
;   6. multiply both sides by 4
;       pi = 4(the sum of (n from 0 to infinity) of ((-1)^(2n+1))/(2n+1))

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
maxNumTerms DWORD 0FFFFh ; how many terms of the series to use
maskGetParity DWORD 00000000000000000000000000000001b
calculatedPi REAL4 0.0
difference REAL4 0.0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    finit
    mov EDX, maxNumTerms
    push EDX
    call computePi
    pop EDX
    mov calculatedPi
    fldpi ; push the "official" PI
    push EAX ; for some reason, I can't just fild EAX. Found this solution online
    fild DWORD PTR [ESP] ; push my computed PI
    pop EAX
    fsub
    fstp difference ; see how far I'm off by
    mov EAX, 0
    ret
main ENDP


computePi PROC
    ; Set up stack frame
    push EBP
    mov EBP, ESP

    ; save registers
    pushfd
    push EDX
    push ECX

    ; do the computation
    mov ECX, 0 ; n starts at 0
    mov EAX, 0 ; sum starts at 0
    sigmaTop:
        cmp ECX, DWORD PTR [EBP + 4*2]; the maxNumTerms I passed
        je endOfSigma
    sigmaBody:
        finit ; not sure if I need this
        ; use EDX to hold 2n + 1
        mov EDX, ECX ; EDX is n
        add EDX, EDX ; EDX is 2n
        inc EDX      ; EDX is 2n + 1
        fld1 ; ST(0) is now 1.0
        push EDX
        fild DWORD PTR [ESP] ; ST(0) is now (2n + 1), ST(1) is now 1.0
        pop EDX
        fdiv ; ST(0) is now (1 / (2n + 1))
        and EDX, maskGetParity ; EDX now only contains its last bit
        cmp EDX, 1d
        je itsOddSoNegate
        jmp doneSigning
        itsOddSoNegate:
            fchs ; ST(0) is now (-1 / (2n + 1))
        doneSigning: ; by now, ST(0) contains the next term in the series
            push EAX
            fild DWORD PTR [ESP] ; ST(0) is now the current sum, ST(1) is the current term
            pop EAX
            fadd ; add the new term to the sum
            push EAX
            fstp DWORD PTR [ESP]; pops current sum into EAX to save it for the next iteration
            pop EAX
        inc ECX
        jmp sigmaTop
    endOfSigma:
        push EAX
        fild DWORD PTR [ESP] ; push the sum
        pop EAX
        mov ECX, 4d
        push ECX
        fild DWORD PTR [ESP] ; ST(0) is now 4d, ST(1) is now PI / 4
        pop ECX
        fmul ; ST(0) now contains PI
        push EAX
        fstp DWORD PTR [ESP] ; pop PI into return value
        pop EAX

    ; restore registers
    pop ECX
    pop EDX
    popfd

    ; remove stack fram
    pop EBP

    ret
computePi ENDP

END
