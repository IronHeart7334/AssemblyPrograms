; general comments
; meant to emulate:
;   if((value <= -1234) || (value >= 1000)){
;       value = 0;
;   }
; Where value is in DX

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

	mov DX, 1001d

    cmp DX, -1234d
    jle orAccepted    ; short circuit evaluates
    cmp DX, 1000d
    jge orAccepted    ; if it doesn't succeed here...
    jmp notOrAccepted ; ... go to else block
    orAccepted:
        mov DX, 0d
        jmp done
    notOrAccepted:
        jmp done
    done:
        ; done

	mov EAX, 0
	ret
main	ENDP

END
