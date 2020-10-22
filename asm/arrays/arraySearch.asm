; general comments
;   Create a program that searches a signed integer doubleword array of up to 5 elements for a particular value.
;   Indicate the result of the search in register AL (1 when found, 0 when not found)
; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
list      DWORD   25d, 32d, 888d, 12d, 6d
length    BYTE     5d
searchFor DWORD 1000d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    lea EBX, list
    mov CL, 0d
    mov AL, 0d

    checkLoopCondition:
        cmp AL, 1d
        je doneSearching ; break out if found already
        cmp CL, length
        jae doneSearching ; break out if I've searched all elements
        jmp loopBody
    loopBody:
        mov EDX, DWORD PTR [EBX + 4 * CL]
        cmp EDX, searchFor ; IF (current element is searchFor) { set AL to 1 }
        je found
        jmp notFound
        found:
            mov AL, 1d
            jmp checkLoopCondition
        notFound:
            inc CL
            jmp checkLoopCondition
    doneSearching:
        ; done


	mov EAX, 0
	ret
main	ENDP

END
