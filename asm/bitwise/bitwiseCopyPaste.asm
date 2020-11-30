; general comments
;	An example of how to copy and paste bits from one integer to another

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
copyHere            BYTE 10110111b ; can use larger size if you want
pasteHere           BYTE 10011101b
maskIsolateBits2To5 BYTE 00111100b ; use this to copy
maskClearBits0To3   BYTE 11110000b ; use this before pasting
result              BYTE 00000000b

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
	; Instruction               | AL        | AH
	mov AL, copyHere            ; 1011 0111   ~~~~ ~~~~
    mov AH, pasteHere           ; 1011 0111   1001 1101
	;     1011 0111
	; and 0011 1100
	; is  0011 0100
	and AL, maskIsolateBits2To5 ; 0011 0100   1001 1101 Copy...
	;     1001 1101
	; and 1111 0000
	; is  1001 0000
	and AH, maskClearBits0To3   ; 0011 0100   1001 0000 Clear...
	shr AL, 2d                  ; 0000 1101   1001 0000 Shift the "clipboard" into position...
	;     1001 0000
	; or  0000 1101
	; is  1001 1101
	or AH, AL                   ; 0000 1101   1001 1101 Paste
	mov result, AH

	mov EAX, 0
	ret
main	ENDP

END
