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
main	PROC
    ; need to leave EAX and EDX open for division
    lea EBP, primeArray ; EBP holds the array of prime numbers found
    mov ECX, 0d         ; temp so I can inc primesFound
    mov EBX, 5d         ; EBX holds potential prime numbers

    mov DWORD PTR [EBP + 4*ECX], 2d ; Use this to insert into indeces
    inc ECX
    mov DWORD PTR [EBP + 4*ECX], 3d ; start with 2 and 3
    inc ECX
    mov primesFound, BL

    checkIfFoundEnoughPrimes:
        mov AH, primesFound
        mov AL, primeCapacity
        cmp AH, AL ; WHILE primesFound < primeCapacity
        jb findNextPrime
        jmp doneFindingPrimes
    findNextPrime:
        ; check if candidate is prime
        mov ECX, 0d ; current index of primes to check
        doesItFactor:
            cmp BL, primesFound
            jae noItDoesnt
            mov EAX, EBX                ; copy current factor to EAX...
            mov EDX, 0                  ; unsigned, so zero-out EDX instead of cdq
            div DWORD PTR [EBP + 4*ECX] ; divide by primeArray[ECX]
            cmp EDX, 0                  ; IF remainder is 0
            je yesItDoes
            inc ECX
            jmp doesItFactor
        noItDoesnt: ; then it must be prime
            mov [EBP + 4*ECX], EBX ; ECX is the first empty slot in the primeArray
            inc ECX
            mov primesFound, BL
            jmp callTheNextCandidiate
        yesItDoes: ; can't be prime if it has any factors
            jmp callTheNextCandidiate

        callTheNextCandidiate:
            add EBX, 2d ; next candidate
            jmp checkIfFoundEnoughPrimes
    doneFindingPrimes:
        ; done

	mov EAX, 0
	ret
main	ENDP

END
