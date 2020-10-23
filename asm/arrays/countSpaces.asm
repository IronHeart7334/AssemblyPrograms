; general comments
;   Create a program that creates and initializes a C-string-style ASCII array.
;   Determine the length of the string and store the answer in DH.
;   Determine the number of spaces in the string and store the answer in DL.
;   Verify that your program works for the empty string,
;   one that has space(s) at the beginning and end,
;   and one that has many spaces spread throughout.
; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
cString BYTE "Hello World!", 0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    mov DL, 0d ; number of spaces
    lea EBX, cString
    mov ECX, 0d

    checkForNullTerminator:
        mov AL, BYTE PTR [EBX + 1*ECX]
        cmp AL, 0d
        je itsNullTerminator
        jmp nextChar
    nextChar:
        mov AL, BYTE PTR [EBX + 1*ECX]
        cmp AL, " " ; oddly enough, characters are stored using double quotes
        je itsASpace
        jmp notASpace
        itsASpace:
            inc DL
            jmp nextPartOfLoop
        notASpace:
            jmp nextPartOfLoop
        nextPartOfLoop:
            inc CL
            jmp checkForNullTerminator
    itsNullTerminator:
        mov DH, CL ; length of the string is the index of the null terminator

	mov EAX, 0
	ret
main	ENDP

END
