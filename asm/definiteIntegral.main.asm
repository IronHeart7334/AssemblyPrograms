; general comments
;   This is a program I made for myself to practice just about everything I've learned in CISP 310 up to this point.
;   This program computes the integral from a to b of f(x) dx using rectangular estimation using the formula
;
;   I = ((b - a) / n) * SIGMA from i = 1 to n of (f(a + i(b - a) / n))

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
; everything must be signed
; delta X will be multiplied by sigma, so that limits it to at most a DWORD so the product can fit in EDX:EAX
; BUT it will also be used in f(x), so f(x) will need to manage its size carefully
; delta X is (b - a) / n, so in order for the quotient to be a DWORD, so must n. I can use cdq to extend b - a to a quadword for division
deltaX DWORD  0d
a_     DWORD  0d
b_     DWORD  5d
n_     DWORD 10d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

	computeDeltaX:
        mov EBX, a_
        mov EAX, b_
        sub EAX, EBX    ; EAX is now b - a
        mov ECX, n_
        cdq             ; EDX:EAX is now b - a
        idiv ECX        ; stores the remainder of EDX:EAX / ECX in EAX (b - a) / n
        mov deltaX, EAX ; Done computing deltaX

	mov EAX, 0
	ret
main	ENDP

END
