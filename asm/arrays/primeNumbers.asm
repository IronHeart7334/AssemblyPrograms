; general comments
;   There are many ways to determine prime numbers. Below is a design for one way to find the first 100 primes.
;   Write an Assembly Language program that stores the primes in an array of doublewords primeArray.
;   Professor Chapman's example:
;       prime[0] := 2  {first prime number}
;       prime[1] := 3  {second prime number}
;       primeCount := 2
;       candidate := 5   {first candidate for a new prime}
;       while (primeCount < 100)
;           index := 0
;           while ((index < primeCount) and (prime[index] does not evenly divide candidate))
;               add 1 to index
;           end while
;
;           if (index == primeCount) then
;               {found a new prime number}
;               prime[primeCount] := candidate
;               add 1 to primeCount
;           end if
;           add 2 to candidate
;       end while
;
; Register Dictionary:
;   - EBP holds the address of the prime numbers found array
;   - EAX holds the quotient of dividing prime candidates by prime numbers
;   - AL temporarily holds the maximum number of primes to find
;   - EBX holds candidate prime numbers
;   - BL temporarily holds the number of primes numbers found
;   - ECX holds doubleword offsets from the beginning of the prime number array (indeces)
;   - EDX holds the remainder after dividing prime candidates by prime numbers
; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
primeArray    DWORD 100d dup(0); not sure if I'm allowed to use dup: check
primeCapacity BYTE  100d       ; max number of primes to find
primesFound   BYTE    0d
; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC                                               ; Psuedocode over here
    ; need to leave EAX and EDX open for division          ;
    lea EBP, primeArray                                    ;
    mov ECX, 0d ; temp so I can inc primesFound            ;
    mov EBX, 5d                                            ; candidate := 5
    mov DWORD PTR [EBP + 4*ECX], 2d                        ; prime[0] := 2
    inc ECX                                                ;
    mov DWORD PTR [EBP + 4*ECX], 3d                        ; prime[1] := 3
    inc ECX                                                ;
    mov primesFound, CL                                    ; primeCount := 2
    checkIfFoundEnoughPrimes:                              ;
        mov AH, primesFound                                ;
        mov AL, primeCapacity                              ;
        cmp AH, AL                                         ; while (primeCount < 100)
        jb checkIfPrime                                    ;
        jmp doneFindingPrimes                              ;
    checkIfPrime: ; check if the current candidate is prime;
        mov ECX, 0d                                        ;     index := 0
        doesItFactor:                                      ;     while((index < primeCount) and prime[index] does not evenly divide candidate)
            cmp CL, primesFound                            ;
            jae doneCheckingIfItFactors                    ;
            mov EAX, EBX                                   ;
            mov EDX, 0                                     ;
            ; unsigned, so zero-out EDX instead of cdq     ;
            div DWORD PTR [EBP + 4*ECX]                    ;
            cmp EDX, 0                                     ;
            ; if remainder is 0,                           ;
            ; prime[index] evenly divides the candidate    ;
            je doneCheckingIfItFactors                     ;
            inc ECX                                        ;         add 1 to index
            jmp doesItFactor                               ;     end while
        doneCheckingIfItFactors:                           ;
            cmp ECX, primesFound                           ;     if(index == primeCount) then
            je foundNewPrime                               ;
            jmp callTheNextCandidiate                      ;
        foundNewPrime:                                     ;
            mov [EBP + 4*ECX], EBX                         ;         prime[primeCount] := candidate
            inc ECX                                        ;         add 1 to primeCount
            mov primesFound, CL                            ;     end if
        callTheNextCandidiate:                             ;
            add EBX, 2d                                    ;     add 2 to candidate
            jmp checkIfFoundEnoughPrimes                   ;
    doneFindingPrimes:                                     ; end while
        ; done

	mov EAX, 0
	ret
main	ENDP

END
