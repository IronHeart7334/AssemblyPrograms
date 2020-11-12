; general comments
;   write a procedure with the following prototype:
;       void toUpper(char* cString);
;   which converts all lowercase letters in cString to uppercase
;   See an ASCII table for the arithmetic for the conversion

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
main PROC
    lea EBX, cString
    push EBX

    call toUpper

    pop EBX

    mov EAX, 0
    ret
main ENDP

; cdecl says that a procedure must leave all registers (except for EAX) and the stack as it found them
; it returns its value in EAX
; and is not allowed to access named memory locations
; this example in c would be
;   int myProc(int a, int b){
;       return a - b;
;   }
toUpper PROC
    push EBP
    mov EBP, ESP
    ; Now the stack looks like this: (using higher addresses at the top)
    ;               [rubbish]
    ;               [cString address]
    ;               [return address]
    ; ESP -> EBP -> [old EBP]
    pushfd
    push EBX
    push ECX
    push EDX ; use to hold char



    mov EBX, DWORD PTR [EBP + 4*2] ; move the address into EBP
    mov ECX, 0 ; use ECX as counter
    mov EDX, 0 ; zero out high bits
    processNextByte: ; WHILE (cString[ECX] != '\0')
        mov DL, BYTE PTR [EBX + 1*ECX] ; current character
        cmp DL, 0
        je doneWithString

        ; check if in range for lower char
        cmp DL, 97d ; lowercase a
        jb nextByte ; if less than 'a', don't uppercase
        cmp DL, 122d ; 'z'
        ja nextByte
        ; if it passes both tests, uppercase it
        sub DL, 32d ; upper = lower - 32
        mov BYTE PTR [EBX + 1*ECX], DL ; move uppercase char back in

        nextByte:
            inc ECX
            jmp processNextByte

    doneWithString:
        ; done

    pop EDX
    pop ECX
    pop EBX
    popfd
    pop EBP

    ret
toUpper ENDP

END
