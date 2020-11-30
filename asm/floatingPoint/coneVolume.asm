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
    ; Instruction | ST(0)   |   ST(1) | ST(2) | ST(3) | ST(4)
    mov EAX, 3d   ; ~~~          ~~~     ~~~     ~~~     ~~~
    fild EAX      ;	3.0          ~~~     ~~~     ~~~     ~~~
    fld height    ; h            3.0     ~~~     ~~~     ~~~
    fldpi         ; PI           h       3.0     ~~~     ~~~
    fld radius    ; r            PI      h       3.0     ~~~
    fld radius    ; r            r       PI      h       3.0
    fmul          ; r^2          PI      h       3.0     ~~~
    fmul          ; PI(r^2)      h       3.0     ~~~     ~~~
    fmul          ; PI(r^2)h     3.0     ~~~     ~~~     ~~~
    fdivr         ; PI(r^2)h/3   ~~~     ~~~     ~~~     ~~~
    fstp volume   ; ~~~          ~~~     ~~~     ~~~     ~~~

	mov EAX, 0
	ret
main	ENDP

END
