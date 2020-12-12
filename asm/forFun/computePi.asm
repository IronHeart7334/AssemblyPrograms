; general comments
;   This program computes PI using the Power Series
;
;   1. Start with the power series
;       1 / (1 - x) = the sum of (n from 0 to infinity) of x^n
;   2. let x = -x
;       1 / (1 + x) = the sum of (n from 0 to infinity) of (-x)^n = ((-1)^n)*((x)^n)
;   3. let x = x^2
;       1 / (1 + x^2) = the sum of (n from 0 to infinity) of ((-1)^n)*((x)^2n)
;   4. Integrate both sides with respect to x
;       arctan(x) = the sum of (n from 0 to infinity) of ((-1)^n)*((x)^2n+1) / (2n+1)
;   5. let x = 1
;       arctan(1) = the sum of (n from 0 to infinity) of ((-1)^n)*((1)^2n+1) / (2n+1)
;       pi/4 = the sum of (n from 0 to infinity) of ((-1)^n) / (2n+1)
;   6. multiply both sides by 4
;       pi = 4(the sum of (n from 0 to infinity) of ((-1)^n) / (2n+1))
;
;   The class I'm taking doesn't cover floating point functions, so I'll have to wait to improve this

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
maxNumTerms       DWORD 1000d ; how many terms of the series to use
currentTerm       DWORD 0d
calculatedPi      REAL4 0.0
four              REAL4 4.0
negOneToSomePower REAL4 -1.0 ; start at (-1)^-1

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    sigmaTop:
        finit ; need this each iteration
        fild maxNumTerms      ; max         ~~~
        fild currentTerm      ; n           max
        fcom                  ; n           max
        fstsw AX              ; n           max
        sahf                  ; n           max
        jae sigmaEnd          ; break when currentTerm >= maxNumTerms
    sigmaBody:
        fld ST(0)             ; n            n
        fadd                  ; 2n           ~~~
        fld1                  ; 1            2n
        fadd                  ; 2n+1         ~~~
        fld negOneToSomePower ; (-1)^n-1     2n+1
        fchs                  ; (-1)^n       2n+1
        fst negOneToSomePower ; (-1)^n       2n+1
        fdirv                 ;(-1)^n/(2n+1) ~~~   ST(0) now contains the next term of the series
        fld calculatedPi      ; sum          term
        fadd                  ; newSum       ~~~
        fstp calculatedPi     ; ~~~          ~~~
        mov ECX, currentTerm
        inc ECX
        mov currentTerm, ECX
        jmp sigmaTop
    sigmaEnd:
        ; Instruction         | ST(0)      | ST(1)
        fld calculatedPi      ; pi/4         ~~~
        fld four              ; 4            pi/4
        fmul                  ; pi           ~~~
        fstp calculatedPi     ; ~~~          ~~~

    mov EAX, 0
    ret
main ENDP

END
