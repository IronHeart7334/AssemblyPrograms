; general comments
;   prototype:
;       int arrayMax(int* the_array, int number_of_elements);
;   when the number_of_elements is negative or zero then return -128d
;   otherwise return the largest of the first number_of_elements elements of the_array[]
;   the_array[] has byte sized elements

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
theArray BYTE 1d, 2d, 3d, 4d, 5d, 6d, 7d, 8d, 9d, 10d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    mov EBX, 10d ; how many elements to check
    push EBX

    lea EBX, theArray
    push EBX

    call arrayMax

    pop EBX
    pop EBX

    mov EAX, 0
    ret
main ENDP

arrayMax PROC
    push EBP     ; set up stack frame
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address
    ; Now the stack looks like this: (using higher addresses at the top)
    ;               [rubbish]
    ;               [num elements]
    ;               [array address]
    ;               [return address]
    ; ESP -> EBP -> [old EBP]
    ; ESP can move around, so I only care about addresses relative to EBP

    ; Step 4: save all register values except for EAX (the return value)
    pushfd
    push ECX
    push EBX

    ; Step 5: now we get to the actual procedure
    mov EAX, -128d
    checkIfAnyElementsPassed:
        cmp DWORD PTR [EBP + 4*3], 0 ; array size
        jle doReturn
    ; at least one element
    mov EBX, DWORD PTR [EBP + 4*2] ; array pointer
    mov ECX, 1d ; start by comparing 0th and 1st elements
    mov EAX, 0d ; clear high bits
    mov AL, BYTE PTR [EBX] ; dereference first element of the array. It is the current max

    checkIfNoMore: ; WHILE (ECX < array size)
        cmp ECX, DWORD PTR [EBP + 4*3] ; DWORD for size...
        jge doReturn
        cmp AL, BYTE PTR [EBX + 1*ECX] ; current element is a BYTE, offset from EBX
        jl foundNewLargest ; current element is larger than current largest
        jmp nextElement
        foundNewLargest:
            mov AL, BYTE PTR [EBX + 1*ECX]
        nextElement:
            inc ECX
            jmp checkIfNoMore

    doReturn:
        ; Step 6: restore everything (except EAX) back to the way it was
        pop EBX
        pop ECX
        popfd
        pop EBP ; get rid of stack frame

    ret
arrayMax ENDP

END
