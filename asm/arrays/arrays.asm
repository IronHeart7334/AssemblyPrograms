; general comments
;   Create a program that cycles through a 10 element word sized unsigned integer array
;   from the first to the last element.
;   In your named memory create and initialize the array itself.
;   Also code the number of elements as a byte.
;   Use the Assembly Language equivalent of for loop logic.

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
list    WORD 3d, 1d, 4d, 1d, 5d, 9d, 2d, 6d, 5d, 3d
length_ BYTE 10d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

    lea EBX, list        ; EBX = &list, in this case it gets the address of the first element

    mov ECX, 0d           ; FOR (int i = 0; ...
	checkLoopCondition:
        cmp CL, length_
        jae doneWithLoop ; ... i < length of list; ...
        jmp loopBody
    loopBody:
        mov AX, WORD PTR [EBX + 2 * ECX]
        ; In C, this would be derefferencing the element at (EBX + 2 * ECX)
        ; then casting to a WORD
        ; Need to use ECX as the index offset
        inc ECX           ; ... i++)
        jmp checkLoopCondition
    doneWithLoop:
        ; done

	mov EAX, 0
	ret
main	ENDP

END
