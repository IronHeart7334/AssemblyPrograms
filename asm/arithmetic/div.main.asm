; general comments
; Computes (2xy) / (x + y)
; both are unsigned WORDS

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
_x     WORD   32d
_y     WORD   64d
result WORD   0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    ; I lack the tools to chain multiplication with WORDS for now, so I'll have to add instead of multiplying by 2
	mov AX, _x     ; AX is now x
    add AX, _x     ; AX is now 2x
	mov DX, _y
    mul DX         ; DX:AX is now 2xy
    mov BX, _x     ; BX is now x
    add BX, _y     ; BX is now x + y
    div BX         ; (2xy) / (x + y) is now stored in AX
    mov result, AX ; result is now the quotient

	mov EAX, 0
	ret
main	ENDP

END
