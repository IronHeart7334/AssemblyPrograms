; general comments
;   This is a program I made for myself to practice just about everything I've learned in CISP 310 up to this point.
;   This program computes the integral from a to b of f(x) dx using Riemann Sum estimation using the formula
;
;   I = ((b - a) / n) * SIGMA from i = 1 to n of (f(a + i(b - a) / n))
;
;   It should go without saying, but this program isn't very accurate yet, as the class hasn't covered decimal numbers yet.

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
; BUT it will also be used in f(x) for i * deltaX, so that must also be a DWORD for when multiplying together, so deltaX must be stored as a WORD
; BUT since I need to chain multiplication, must store delta x as a BYTE
; delta X is (b - a) / n, so in order for the quotient to be a BYTE, so must n.
; sigma might be rather large, so store it as a DWORD. I can extend deltaX when I need to multiply the two of them
a_     WORD   0d ; can change these 3 values
b_     WORD  50d ; for this to work, n_ must be smaller than b_ - a_. For the highest accuracy, b_ - a_ should be evenly divisible by n_
n_     BYTE  10d ;
deltaX BYTE   0d
sigma  DWORD  0d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

	computeDeltaX:
        mov BX, a_
        mov AX, b_
        sub AX, BX    ; AX is now b - a
        mov CL, n_
        idiv CL        ; stores the remainder of AX / CL in AL ((b - a) / n)
        mov deltaX, AL ; Done computing deltaX

    computeSigma:
                            ; set up the for loop
        mov EBX, 0d         ; store result in EBX
        mov CL, 1d          ; FOR i from 1 to n (inclusive of end points)
        checkSigmaRange:
            cmp CL, n_
            jle addNextTerm
            jmp doneLooping
        addNextTerm:
                                ; to make this easier, f(x) = x to avoid having to do much multiplication
                                ; store f(x) in AX as I'm processing it
            mov EAX, 0d
            mov AL, deltaX
            imul CL             ; AX is now i * deltaX
            add AX, a_          ; AX is now a + i * deltaX (the height of the current rectangle)
            ; check if AX is negative
            cmp AX, 0d          ; IF AX < 0
            jl extSignBit       ;    set high bits of EAX to 1 (sort of a cwd that works on EAX instead of DX:AX)
            jmp doAdd           ; ELSE
                                ;    just leave high bits of EAX as 0
                                ; END IF
            extSignBit:
                mov DX, AX          ; swap out low bits of EAX so I can change the high bits
                mov EAX, 0FFFF0000h ; set high bits of EAX to 1
                mov AX, DX

            doAdd:
                add EBX, EAX        ; add that rectangle's height to the sum
                inc CL              ; remember to increment i!
                jmp checkSigmaRange
        doneLooping:
            mov sigma, EBX

    multiplyTogether:
        ; multiply the total heights of rectangles by the widths
        mov AL, deltaX
        cbw ; extends AL to AX

        mov EDX, sigma
        imul EDX        ; EDX:EAX is now the integral

	mov EAX, 0
	ret
main	ENDP

END
