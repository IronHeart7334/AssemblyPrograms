; general comments
; 	This algorithm approximates the cube root of a real number x:
;		root := 1.0
;		until ( |root - oldRoot| < smallValue ) loop
;		    oldRoot := root
;			root := (2.0*root + x/(root*root)) / 3.0
;		end until
;	Write a console32 Assembly Language program to approximate the square root of a real number.
;
;	Does he mean cube root instead of square root?

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
root       REAL4 1.0
oldRoot    REAL4 0.0
_x         REAL4 3.12
smallValue REAL4 0.0001
three      REAL4 3.0

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
	checkLoopCondition: ; ST(0)              | ST(1)
		finit           ; ~~~                  ~~~
		fld root        ; root                 ~~~
		fld oldRoot     ; oldRoot              root
		fsub            ; root - oldRoot       ~~~
		fabs            ; | root - oldRoot |   ~~~
		fld smallValue  ; smallValue           | root - oldRoot |
		fcom
		fstsw AX
		sahf
		ja endLoop ; checks if smallValue > | root - oldRoot |
	loopBody: ; ignore the values currently in ST(0) and ST(1)
		; Instruction | ST(0)                     | ST(1)               | ST(2)
		fld root      ; root                      | ~~~                 | ~~~
		fst oldRoot   ; root                      | ~~~                 | ~~~
		fld root      ; root                      | root                | ~~~
		fmul          ; root^2                    | ~~~                 | ~~~
		fld _x        ; x                         | root^2              | ~~~
		fdivr         ; x/(root^2)                | ~~~                 | ~~~
		fld root      ; root                      | x/(root^2)          | ~~~
		fld root      ; root                      | root                | x/(root^2)
		fadd          ; 2*root                    | x/(root^2)          | ~~~
		fadd          ; 2*root + x/(root^2)       | ~~~                 | ~~~
		fld three     ; 3.0                       | 2*root + x/(root^2) | ~~~
		fdiv          ; (2*root + x/(root^2)) / 3 | ~~~                 | ~~~
		fstp root     ; ~~~                       | ~~~                 | ~~~
		jmp checkLoopCondition
	endLoop:
		; done

	mov EAX, 0
	ret
main	ENDP

END
