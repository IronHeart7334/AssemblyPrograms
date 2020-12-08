; general comments
;   The Taylor Polynomial representation of degree N of a function f(x) centered on A is defined as
;       T(f(x)) = SIGMA for i from 0 to N of f^i(A)*(x - A)/i!
;   Where f^i(A) is the i'th derivative of f with respect to x, evaluated at A
;
;   Euler's number, e, has the characteristic
;       d(e^x)/dx = e^x
;
;   Therefore, e can be approximated using a Taylor Polynomial with A = 0 and x = 1
;       T(f(x)) = SIGMA for i from 0 to N of f^i(A)*(x - A)/i!
;           f(x) = e^x
;       T(e^x) = SIGMA for i from 0 to N of f^i(A)*(x - A)/i!
;           f^i(A) is always e^A = e^0 = 1
;       T(e^x) = SIGMA for i from 0 to N of (x - A)/i!
;           x is 1, A is 0
;       T(e^x) = SIGMA for i from 0 to N of 1/i!
;           pop off the first term of i = 0
;       T(e^x) = 1 + SIGMA for i from 1 to N of 1/i!

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
eulersNumber REAL4   1.0 ; start with just one term
degree       REAL4 100.0 ; the number of terms to use
currTermNum  REAL4   1.0 ; start at i = 1
factorial    REAL4   1.0 ; 0 factorial

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC
    ; Instruction         | ST(0)              | ST(1)               | Comment
    sigmaTop:             ; ~~~                  ~~~                   ~~~
        finit             ; ~~~                  ~~~                   Prepare floating point registers
        fld currTermNum   ; currTermNum          ~~~                   Push the current term number to the floating point stack
        fld degree        ; degree               currTermNum           Push the degree
        fcom              ; degree               currTermNum           Compare currTermNum to degree, setting the float comparison flags
        fstsw AX          ; degree               currTermNum           Save the float status word to the AX integer registers
        sahf              ; degree               currTermNum           Copy the high-bits of AX to the integer comparison flags
        jb sigmaEnd       ; degree               currTermNum           if degree < currTermNum, jump to the end of sigma
    sigmaBody:            ; degree               currTermNum           drops to here otherwise
        fstp degree       ; currTermNum          ~~~                   pops degree from the stack
        fld factorial     ; (currTermNum - 1)!   currTermNum           push the factorial from the previous iteration
        fmul              ; currTermNum!         ~~~                   (n - 1)! * n is n!
        fst factorial     ; currTermNum!         ~~~                   updates saved factorial
        fld1              ; 1.0                  currTermNum!          push 1.0
        fdivr             ; 1.0 / currTermNum!   ~~~                   compute the next term in the series
        fld eulersNumber  ; eulersNumber         1.0 / currTermNum !   load the current estimate of Euler's number
        fadd              ; new eulersNumber     ~~~                   make the estimate more accurate
        fstp eulersNumber ; ~~~                  ~~~                   update the saved estimate
        fld currTermNum   ; currTermNum          ~~~                   push the current term number for updating
        fld1              ; 1.0                  currTermNum           pushes 1.0
        fadd              ; 1.0 + currTermNum    ~~~                   advances to the next term
        fstp currTermNum  ; ~~~                  ~~~                   stores the new term for the next iteration
        jmp sigmaTop      ; ~~~                  ~~~                   go back to the top of the loop
    sigmaEnd:
        ; done


	mov EAX, 0
	ret
main	ENDP

END
