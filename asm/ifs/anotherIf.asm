; general comments
;   if(value < 500){
;       value += 2*count
;   } else {
;       number = 65;
;   }
;
; count and number are words in memory
; number is CX
; value is BX
; everything is unsigned
; the product fits in just the lower order half of the registers it's put into

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
count  WORD  5d
number WORD 15d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

	mov BX, 400d
    mov CX, 0d

    cmp BX, 500d
    jb ifBlock
    jmp elseBlock
    ifBlock:
        mov AX, count
		mov DX, 2d
        mul DX
        add BX, AX
        jmp done
    elseBlock:
        mov CX, 65d
        jmp done
    done:
        ; done

	mov EAX, 0
	ret
main	ENDP

END
