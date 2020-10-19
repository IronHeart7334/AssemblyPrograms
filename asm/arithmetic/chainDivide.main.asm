; general comments
;   computes (2xy) / (x + y)
;   where x and y are unsigned BYTES
;   note that this method of chaining ONLY works if at least to operands in the numerator are BYTE sized

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
_x     BYTE  12d
_y     BYTE   3d
result WORD  0d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

	mov AL, 2d
    mov AH, _x
    mul AH     ; AX is now AH * AL (2x)

    mov DH, 0d
    mov DL, _y ; extends _y to a WORD
    mul DX     ; DX:AX is now AX * DX (2xy)
    ; note that we cannot chain multiplication past this point without bit shifting or knowing DX is 0

    mov BH, 0d
    mov BL, _x ; BX is now x
    mov CH, 0d
    mov CL, _y
    add BX, CX ; BX is now x + y. Note that this is a WORD, while the numerator is a DWORD, so division will work

    div BX     ; (DX:AX)/BX's numerator is now stored in AX
    mov result, AX

	mov EAX, 0
	ret
main	ENDP

END
