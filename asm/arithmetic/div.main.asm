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
    ; We can do this multiplication one of two ways:
	;    1. using addition, then multiplication to minimize register size
	;    2. chaining multiplication, but that would require bit shifting or that x and y be just bytes
	mov AX, _x     ; AX is now x
    add AX, _x     ; AX is now 2x
	mov DX, _y
    mul DX         ; DX:AX is now 2xy
    mov BX, _x     ; BX is now x
    add BX, _y     ; BX is now x + y
    div BX         ; (2xy) / (x + y) is now stored in AX
    mov result, AX ; result is now the quotient

	; or
	;    2. chaining multiplication: watch register sizes closely!
	mov AX, 2d
	mov DX, _x
	mul DX           ; DX:AX is now 2x
	jc cannotCompute ; if 2x is larger than a WORD, I currently lack the tools to move DX:AX to one register for the second multiplication
	mov DX, AX       ; store AX here temporarily...
	mov EAX, 0d
	mov AX, DX       ; zero-out high bits of EAX, set low bits to 2x

	mov EBX, 0d
	mov BX, _y
	mul EBX          ; EAX * EBX is now stored in EDX:EAX (2xy)

	; denominator time: needs to be a DWORD to divide the quadword numerator
    mov EBX, 0d
	add BX, _x       ; denominator is now x
	mov ECX, 0d
	mov CX, _y
	add EBX, ECX     ; denominator is now x + y
	div EBX          ; (EDX:EAX)/(EBX)'s quotient is now in EAX
	mov result, AX   ; result can only hold low bits.

	jmp endBlock
	cannotCompute:
	    ; do nothing
		jmp endBlock
    endBlock:
		; done
	mov EAX, 0
	ret
main	ENDP

END
