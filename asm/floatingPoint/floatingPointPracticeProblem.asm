; general comments
;   Write a program to calculate:
;       4.3125 - -43.2 * 598732.1562
;          a        b       c
; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
_a      REAL4      4.3125
_b      REAL4    -43.2
_c      REAL4 598732.1562
_result REAL4      0.0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    finit ; prepare floating point registers
    ; Just for fun, I'll evaluate this as a tree:
    ;            /(b)
    ;       ( * )
    ;      /     \(c)
    ;-( - )
    ;      \
    ;       ( a )
    ;
    ; Instruction | ST(0) | ST(1) | ST(2)
                  ; ~~~     ~~~     ~~~
    fld _a        ;  a      ~~~     ~~~
    fld _b        ;  b       a      ~~~
    fld _c        ;  c       b       a
    fmul          ; b*c      a      ~~~
    fsub          ; a-b*c   ~~~     ~~~
    fstp _result  ; ~~~     ~~~     ~~~       
	mov EAX, 0
	ret
main	ENDP

END
