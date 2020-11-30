; general comments
;   Write a console32 Assembly Language program to calculate the volume of a right circular cone
;   using the formula
;       v = (PI*(r^2)*h) / 3
; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
radius REAL4 2.5
height REAL4 4.0
volume REAL4 0.0 ; answer should be 25 * PI (~ 78.5)

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    finit
    ; I use these comments to keep track of the ST registers
    ; Instruction | ST(0)     |  ST(1)
    fld radius    ; r            ~~~
    fld radius    ; r            r
    fmul          ; r^2          ~~~
    fld height    ; h            r^2
    fmul          ; h(r^2)       ~~~
    fldpi         ; PI           h(r^2)
    fmul          ; PI(r^2)h     ~~~
    mov EAX, 3d   ; PI(r^2)h     ~~~
    fild EAX      ; 3.0          PI(r^2)h
    fdiv          ; PI(r^2)h/3   ~~~
    fstp volume   ; ~~~          ~~~

	mov EAX, 0
	ret
main	ENDP

END
