; general comments
;
; Computes:
;     n! / (k!(n-k)!)
;     where 0 <= k < n
;
; Register Dictionary:
;   AX holds
;       temporary values for extending to WORDs
;       the current product of the factorial calculations
;       the low bits of the numerator for division (n!/k!)
;   BX holds
;       the current factor in computing factorials
;       the denominator for division ((n - k)!)
;   CX holds
;       the minimum factor to include in factorial calculations
;       temporary values for setting my resultIsValid flag
;   DX holds the high bits of the numerator for division (1)

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
n_            BYTE 5d
k_            BYTE 3d
numerator     WORD 0d
denominator   WORD 0d
nChooseK      WORD 0d
resultIsValid BYTE 0d ; a flag showing whether or not the result is valid

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    calcNFactOverKFact:
        mov BX, 0
        mov BL, n_ ; extend n_ to a WORD in BX
        mov CX, 0
        mov CL, k_
        inc CX ; CX now contains k + 1

        mov AX, 1d
        checkNFactOverKFactLoop:       ; WHILE BX >= CX (WHILE current factor >= k + 1)
            cmp BX, CX
            jae multiplyNextFactor
            jmp doneWithNFactOverKFact
        multiplyNextFactor:
            mul BX                     ; multiply AX by the current factor
            jc overflowOccurred        ; IF product is too large for AX THEN
                                       ;     jumps to overflowOccured
                                       ; ENDIF
            dec BX                     ; advance BH to the next factor (BX = BX - 1)
            jmp checkNFactOverKFactLoop
                                       ; END WHILE

    doneWithNFactOverKFact:
        mov numerator, AX
        jmp calcNMinusKFact
    ; done with computing n!/k!

    calcNMinusKFact:
        mov BX, 0
        mov BL, n_
        sub BL, k_ ; BX now contains (n - k)
        mov CX, 1d

        mov AX, 1d
        checkNMinusKFactLoop:           ; WHILE BX >= CX (1)
            cmp BX, CX
            jae multiplyNextFactorMinus
            jmp doneWithNMinusKFact
        multiplyNextFactorMinus:
            mul BX                     ; Multiply AX by the current factor
            jc overflowOccurred        ; IF product is too large for AX, THEN jump to overflowOccured ENDIF
            dec BX                     ; advance BX to the next factor
            jmp checkNMinusKFactLoop
                                       ; END WHILE

    doneWithNMinusKFact:
        mov denominator, AX
        jmp divideSection

    divideSection:
        mov AX, numerator
        mov DX, 0 ; would have overflowed if DX is non-zero, but zero it out to be safe
        mov BX, denominator
        div BX ; ensures the result will be WORD sized
        mov nChooseK, AX

        mov CL, 1d
        mov resultIsValid, CL ; report that the result is valid

        jmp endProgram

    overflowOccurred:
        ; cannot compute
        mov CL, 0d
        mov resultIsValid, CL ; report that the result is not valid
        jmp endProgram

    endProgram:
        ; done

	mov EAX, 0
	ret
main	ENDP

END
