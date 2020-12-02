; general comments
;   This program computes PI using the Tailor Polynomial of inverse tangent.
;
;   1.
;       1 / (1 - x) = the sum of (n from 0 to infinity) of x^n
;   2.
;       let x = -x
;       1 / (1 + x) = the sum of (n from 0 to infinity) of (-x)^n = ((-1)^n)*((x)^n)
;   3.
;       let x = x^2
;       1 / (1 + x^2) = the sum of (n from 0 to infinity) of ((-1)^n)*((x)^2n)
;   4. Integrate both sides with respect to x
;       arctan(x) = the sum of (n from 0 to infinity) of ((-1)^n)*((x)^2n+1) / (2n+1)
;   5. let x = 1
;       arctan(1) = the sum of (n from 0 to infinity) of ((-1)^n)*((1)^2n+1) / (2n+1)
;       pi/4 = the sum of (n from 0 to infinity) of ((-1)^n) / (2n+1)
;   6. multiply both sides by 4
;       pi = 4(the sum of (n from 0 to infinity) of ((-1)^n) / (2n+1))
;
;   The class I'm taking doesn't cover floating point functions,
;   so I'll have to wait to improve this

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
maxNumTerms   DWORD 1000d ; how many terms of the series to use
maskGetParity DWORD 00000000000000000000000000000001b
currentN      REAL4 0.0
calculatedPi  REAL4 0.0
difference    REAL4 0.0
four          REAL4 4.0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    mov ECX, 0d ; store term number here as well to get parity
    sigmaTop:
        finit ; need this each iteration
        cmp ECX, maxNumTerms
        jae sigmaEnd ; if currentN >= maxNumTerms
    sigmaBody:
        ; Instruction | ST(0) | ST(1)
        fld currentN  ; n       ~~~
        fld ST(0)     ; n       n
        fadd          ; 2n      ~~~
        fld1          ; 1       2n
        fadd          ; 2n+1    ~~~
        fld1          ; 1       2n+1
        fdivr         ;1/(2n+1) ~~~
        mov EDX, ECX
        and EDX, maskGetParity ; EDX now only contains its last bit
        cmp EDX, 1d
        je itsOddSoNegate ; odd terms have odd powers of -1
        jmp doneSigning
        itsOddSoNegate:
            fchs ; ST(0) is now (-1 / (2n + 1))
        doneSigning:
            ; Instruction     | ST(0) | ST(1)
                              ; term    ~~~
            fld calculatedPi  ; sum     term
            fadd              ; newSum  ~~~
            fstp calculatedPi ; ~~~     ~~~
            fld currentN      ; n       ~~~
            fld1              ; 1       n
            fadd              ; n+1     ~~~
            fstp currentN     ; ~~~     ~~~
            inc ECX
            jmp sigmaTop
    sigmaEnd:
        ; Instruction     | ST(0) | ST(1)
                          ; ~~~     ~~~
        fld calculatedPi  ; pi/4    ~~~
        fld four          ; 4       pi/4
        fmul              ; pi      ~~~
        fstp calculatedPi

    fldpi ; push the "official" PI
    fld calculatedPi
    fsub
    fstp difference ; see how far I'm off by

    mov EAX, 0
    ret
main ENDP

END
