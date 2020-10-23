; general comments
; 	This program presents some of my ideas for how to use assembly for OOP.
;	I'll be adding to it as I learn more MASM so that it becomes progressively better.

; preprocessor directives
.586
.MODEL FLAT

; external files to link with

; stack configuration
.STACK 4096

; named memory allocation and initialization
.DATA
; Idea: this is how to do structs
person1Id   BYTE   0d    ; this is just so I have something to target with the lea instruction
person1Off  BYTE   5d    ; offense stat
person1Hp   BYTE  20d    ; must treat this as signed, as damage may reduce you to negative HP
person1Type BYTE  "FGHT" ; four-character type "fighter" in this case. This will make dereferencing offsets interesting
longNumber1 DWORD 71h    ; let's see if I can access this

person2Id   BYTE   0d
person2Off  BYTE   7d
person2Hp   BYTE  15d
person2Type BYTE  "NULL"
longNumber2 DWORD 99h

; these will need to change if the order of properties above changes
idOffset    DWORD  0d ; ID is 0 bytes away from the start of the struct
offOffset   DWORD  1d ; ID takes 1 byte, so offense occupies the next one
hpOffset    DWORD  2d
typeOffset  DWORD  3d
longOffset  DWORD  7d ; type takes up 4 bytes, so this is 4 + its offset

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

	; set up the fight
	; AL will hold person1's HP
	lea EBX, person1Id
	mov AL, BYTE PTR [EBX + hpOffset] ; will this work?
	; AH will hold person2's HP
	lea EBX, person2Id
	mov AH, BYTE PTR [EBX + hpOffset] ; looks kind of like "this->getHp", except "this" is EBX. Hmm...

	; fight until someone's out of the game
	checkIfFightOver:
		cmp AL, 0d
		jbe fightOver
		cmp AH, 0d
		jbe fightOver
		jmp nextRound
	nextRound:
		; player 1's turn
		; DL will hold offense values
		lea EBX, person1Id
		mov DL, BYTE PTR [EBX + offOffset]
		sub AH, DL
		; simultaneous attack from person 2
		lea EBX, person2Id
		mov DL, BYTE PTR [EBX + offOffset]
		sub AL, DL
		jmp checkIfFightOver
	fightOver:
		; I don't know what will happen here.
		; I'll just test a few things...
		lea EBX, person1Id
		mov AL, BYTE PTR [EBX + idOffset]     ; can I get the ID?
		mov AL, BYTE PTR [EBX + offOffset]    ; ...offense?
		mov AL, BYTE PTR [EBX + hpOffset]     ; HP
		mov EAX, DWORD PTR [EBX + typeOffset] ; what happens if I try to read 4 consecutive bytes as a DWORD?
		mov EAX, DWORD PTR [EBX + longOffset] ; this is a different size than the others... will that cause problems?

	mov EAX, 0
	ret
main	ENDP

END
