; general comments
;   Write a program to compute the volume of a triangular prism.
;   Define a procedure who's prototype in C would look like
;       unsigned int triangularPrismVolume(unsigned int height, unsigned int length , unsigned int width);
;   Where 1 <= height, length, width <= 100
;   Use the formula V = (height * length * width) / 2
;   Treat the volume as the quotient after division
;   Use the smallest register sizes possible

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
height BYTE 10d
length BYTE  5d
width  BYTE  4d
volume DWORD 0d ; 8- and 16-bits are not enough to hold the largest volume (500000d)
; volume should be 100d (00 00 00 64 h)

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    mov EBX, 0 ; set high bits of B register
    mov BL, width
    push EBX ; only allowed to push DWORD registers
    mov BL, length
    push EBX
    mov BL, height
    push EBX

    call triangularPrismVolume
    mov volume, EAX ; save value computed by the procedure
    pop EBX
    pop EBX
    pop EBX

    mov EAX, 0
    ret
main ENDP

; Register Dictionary:
;   - EBP contains the address of this procedure's stack frame
;   - EDX will contain the high bits of multiplication
;   -  BX will temporarily hold the dividend (2d)
;   - EAX holds the remainder after division
;   Note that all of these except EAX are restored by the end of the procedure
;
; While I could divide by 2 before multiplying a second time,
; integer division is not commutative with multiplication,
; so my answer would be off if the last multiplicand is odd
triangularPrismVolume PROC
    push EBP
    mov EBP, ESP
    ; Now the stack looks like this: (using higher addresses at the top)
    ;               [rubbish]
    ;               [width]
    ;               [length]
    ;               [height]
    ;               [return address]
    ; ESP -> EBP -> [old EBP]
    ; ESP can move around, so I only care about addresses relative to EBP

    ; save all register values except for EAX (the return value)
    pushfd
    push EDX
    push EBX

    ; now we get to the actual procedure
    ; first parameter is two frames above EBP, as the return address is one above
    mov EAX, DWORD PTR [EBP + 4*2] ; EAX now holds height
    mov EDX, DWORD PTR [EBP + 4*3] ; EDX now holds length
    mul DL; height and length only take up the lowermost byte of their register.
    ; AX now contains height * length
    mov EDX, DWORD PTR [EBP + 4*4] ; EDX now holds the width
    ; width only uses 1 byte, but to chain multiplication, need to treat it as a word
    mul DX; height * length * width is now in DX:AX
    mov BX, 2d
    div BX; need a WORD sized register to use the correct numerator (DX:AX)
    ; quotient is now in AX, whose high bits are still 0, so just leave it there

    ; restore everything (except EAX) back to the way it was
    pop EBX
    pop EDX
    popfd
    pop EBP ; get rid of stack frame

    ret
triangularPrismVolume ENDP

END
