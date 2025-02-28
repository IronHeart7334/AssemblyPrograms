; general comments
; Register Dictionary:
;     AL contains the effective hours someone is paid for
;     AH contains the number of hours beyond 40
;     AX contains the product of paid hours and pay rate
;     BL contains the pay per hour

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
weeklyHours	BYTE 47d
payPerHour  BYTE 33d
grossPay    WORD 0d

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
	mov AL, weeklyHours     ; start by counting all their hours only once
	cmp AL, 40d             ; IF (weeklyHours > 40) THEN
    ja doubleCountBeyond40  ;     count hours beyond 40 twice
                            ; ELSE
    jmp doneComputingHours  ;     don't double-count any hours
	                        ; ENDIF

    doubleCountBeyond40:
        mov AH, weeklyHours
        sub AH, 40d         ; AH now contains weeklyHours - 40 (hours beyond 40)
        add AL, AH          ; AL is now weeklyHours + (weeklyHours - 40) = 2(weeklyHours) - 40
                            ; this double-counts hours over 40 hours
        jmp doneComputingHours

    doneComputingHours:     ; by this point, AL contains the effective hours they've worked
	    mov BL, payPerHour
        mul BL              ; computes payPerHour * effective hours, and stores in AX
        mov grossPay, AX

	mov EAX, 0
	ret
main	ENDP

END
