; general comments
; Register Dictionary:
;   - EAX contains the index where the character was found (-1 if not found)
;   - EBX contains the cString address
;   - ECX contains the current index
; preprocessor directives
.586
.MODEL FLAT
; external files to link with
; stack configuration
.STACK 4096
; named memory allocation and initialization
.DATA
searchCString BYTE "Example search string", 0
searchFor     BYTE "c"
; names of procedures defined in other *.asm files in the project
; procedure code
.CODE
main	PROC
	mov EAX, -1
    mov ECX, 0
    lea EBX, searchCString
    checkCurrentByte:
        cmp EAX, -1
        jne doneProcessing ; IF(EAX is not -1){done processing because found}
        cmp BYTE PTR [EBX + 1*ECX], 0
        jmp doneProcessing ; IF(current byte is null terminator){nothing left to process}
    loopBody:
        cmp BYTE PTR [EBX + 1*ECX], searchFor
        je yayFound
        inc ECX ; else, not found
        jmp checkCurrentByte
        yayFound: ; if (current byte is what I'm searching for)
            mov EAX, ECX ; falls though to done processing
    doneProcessing:
        ; done
	mov EAX, 0
	ret
main	ENDP
END
