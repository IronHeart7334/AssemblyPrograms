; general comments
; preprocessor directives
.586
.MODEL FLAT
; external files to link with
; stack configuration
.STACK 4096
; named memory allocation and initialization
.DATA
oldRoot REAL4 1.5
newRoot REAL4 0.0
three   REAL4 3.0 ; can't do immediates
four    REAL4 4.0
nine    REAL4 9.0
; names of procedures defined in other *.asm files in the project
; procedure code
.CODE
main	PROC
    ; ... loop stuff up here
    ; Instructrion | ST(0)                | ST(1)             | ST(2)
    finit          ; ~~~                    ~~~                 ~~~
    fld oldRoot    ; old                    ~~~                 ~~~
    fld oldRoot    ; old                    old                 ~~~
    fmul           ; old^2                  ~~~                 ~~~
    fld nine       ; 9                      old^2               ~~~
    fmul           ; 9old^2                 ~~~                 ~~~
    fld oldRoot    ; old                    9old^2              ~~~
    fld oldRoot    ; old                    old                 9old^2
    fmul           ; old^2                  9old^2              ~~~
    fld oldRoot    ; old                    old^2               9old^2
    fmul           ; old^3                  9old^2              ~~~
    fld three      ; 3                      old^3               9old^2
    fmul           ; 3old^3                 9old^2              ~~~
    fld four       ; 4                      3old^3              9old^2
    fsub           ; 3old^3-4               9old^2              ~~~
    fdivr          ; (3old^3-4)/(9old^2)    ~~~                 ~~~
    fld oldRoot    ; old                    (3old^3-4)/(9old^2) ~~~
    fsubr          ; old-(3old^3-4)/(9old^2) ~~~                ~~~
    fstp newRoot   ; ~~~                     ~~~                ~~~
    ; ... more loop down here
	mov EAX, 0
	ret
main	ENDP
END
