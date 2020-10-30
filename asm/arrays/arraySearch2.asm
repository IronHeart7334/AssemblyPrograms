; general comments
;   Write an assembly language program that sequentially searches an array of word sized signed integer for a search value.
;   Load the array with values and define the array size in the .DATA section.
;   Store a 0 in EAX when the search value is found, and 1 in EAX when the search value is not found.

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
theAnswer	DWORD	0ABCDABCDh

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    ; not started yet
	mov EAX, 23902
	add EAX, -32
	mov theAnswer, EAX

	mov EAX, 0
	ret
main	ENDP

END
