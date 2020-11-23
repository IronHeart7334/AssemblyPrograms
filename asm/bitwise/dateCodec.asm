; general comments
;   Write two procedures, prototyped as
;       unsigned int packDate(unsigned int month, unsigned int day, unsigned int year);
;       void unpackDate(unsigned int dateComponents[3], unsigned int packedDate);
;   Test both procedures in main() with a call to packDate with three literal/immediate arguments,
;   and then a call to unpackDate with the return value.

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
_unpacked WORD 0, 0, 0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main PROC
    ; Step 1: before calling the procedure, the caller must push parameters in reverse order
    mov EBX, 2020d
    push EBX
    mov EBX, 25d
    push EBX
    mov EBX, 12d
    push EBX
    ; I'll encode Christmas day, 2020

    ; Step 2: call the procedure
    call packDate ; remember: this pushes the address of this to the stack

    ; Step 9: trash the parameters I passed
    pop EBX
    pop EBX
    pop EBX

    ; Step 1 again, this time for unpackDate
    push EAX ; push the return value from the last procedure
    lea EBX, _unpacked
    push EBX

    ; Step 2
    call unpackDate

    ; Step 9
    pop EBX
    pop EBX

    mov EAX, 0
    ret
main ENDP

; unsigned int packDate(unsigned int month, unsigned int day, unsigned int year);
; Register Dictionary:
;   - EAX contains the encoded data
;   - EBX holds temporary values
; The bits of the value returned are as follows:
; - bits 0  - 15 contain the year
; - bits 16 - 23 contain the day
; - bits 24 - 31 contain the month
; [0000 0000 0000 0000 0000 0000 0000 0000]
; |_Month___|_Day_____|_Year______________|
packDate PROC
    ; Step 3: set up a stack frame as a fixed point on the stack
    push EBP     ; set up stack frame
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address
    ; Now the stack looks like this: (using higher addresses at the top)
    ; [rubbish           ]
    ; [year  (WORD sized)]
    ; [day   (BYTE sized)]
    ; [month (BYTE sized)]
    ; [return address    ]
    ; [old EBP           ] <- EBP <- ESP
    ; ESP can move around, so I only care about addresses relative to EBP

    ; Step 4: save all register values except for EAX (the return value)
    pushfd
    push EBX

    ; Step 5: (optional) allocate temporary storage (saves on register usage)
    ;   this problem doesn't require temporary storage

    ; Step 6: now we get to the actual procedure
    ; Instructions here            | Current state of EAX in bits ('_' to pad out)
    mov EAX, DWORD PTR [EBP + 4*2] ; 0000 0000 0000 0000 0000 0000 MONT H___
    shl EAX, 8d                    ; 0000 0000 0000 0000 MONT H___ 0000 0000
    mov EBX, DWORD PTR [EBP + 4*3] ; * EBX is now the day *
    add EAX, BL                    ; 0000 0000 0000 0000 MONT H___ DAY_ ____
    shl EAX, 16d                   ; MONT H___ DAY_ ____ 0000 0000 0000 0000
    add EBX, DWORD PTR [EBP + 4*4] ; * EBX is now the year *
    add EAX, BX                    ; MONT H___ DAY_ ____ YEAR ____ ____ ____

    ; Step 7: free allocated storage
    ;   no space allocated, so no space to free

    ; Step 8: restore everything (except EAX) back to the way it was
    pop EBX
    popfd
    pop EBP ; get rid of stack frame

    ret
packDate ENDP

; void unpackDate(unsigned int dateComponents[3], unsigned int packedDate);
; Register Dictionary:
;   - EAX holds packedDate for bit shifting
;   - EBX holds a reference to dateComponents
unpackDate PROC
    ; Step 3: set up a stack frame as a fixed point on the stack
    push EBP     ; set up stack frame
    mov EBP, ESP ; EBP is stable, so use it to store the address of old EBP's stack address
    ; Now the stack looks like this: (using higher addresses at the top)
    ; [rubbish                          ]
    ; [packedDate (DWORD)               ]
    ; [dateComponents (array of 3 WORDs)]
    ; [return address                   ]
    ; [old EBP                          ] <- EBP <- ESP
    ; ESP can move around, so I only care about addresses relative to EBP

    ; Step 4: save all register values. Save EAX since this returns void
    pushfd
    push EBX
    push EAX

    ; Step 5: (optional) allocate temporary storage (saves on register usage)
    ;   this problem doesn't require temporary storage

    ; Step 6: now we get to the actual procedure
    ; Instructions here            | Current state of EAX in bits ('_' to pad out)
    mov EAX, DWORD PTR [EBP + 4*3] ; MONT H___ DAY_ ____ YEAR ____ ____ ____
    mov EBX, DWORD PTR [EBP + 4*2] ; * EBX now points to the first element in dateComponents
    mov WORD PTR [EBX + 2*2], AX   ; * Set the year component of dateComponents
    shr EAX, 8d                    ; 0000 0000 MONT H___ DAY_ ____ YEAR ____
    shr AX, 8d                     ; 0000 0000 MONT H___ 0000 0000 DAY_ ____
    mov WORD PTR [EBX + 2*1], AX   ; * Set the day component of dateComponents
    shr EAX, 16d                   ; 0000 0000 0000 0000 0000 0000 MONT H___
    add WORD PTR [EBX + 2*0], AX   ; * Sets the month component of dateComponents

    ; Step 7: free allocated storage
    ;   no space allocated, so no space to free

    ; Step 8: restore everything back to the way it was
    pop EAX
    pop EBX
    popfd
    pop EBP ; get rid of stack frame

    ret
unpackDate ENDP

END
