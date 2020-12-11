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

; Better struct idea
person1 DWORD 2 dup(0) ; Allocate 64 bits per person
person2 DWORD 2 dup(0)

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
	mov ECX, hpOffset
	mov AL, BYTE PTR [EBX + 1*ECX] ; will this work?
	; AH will hold person2's HP
	lea EBX, person2Id
	mov AH, BYTE PTR [EBX + 1*ECX] ; looks kind of like "this->getHp", except "this" is EBX. Hmm...

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
		mov ECX, offOffset
		mov DL, BYTE PTR [EBX + 1*ECX]
		sub AH, DL
		; simultaneous attack from person 2
		lea EBX, person2Id
		mov DL, BYTE PTR [EBX + 1*ECX]
		sub AL, DL
		jmp checkIfFightOver
	fightOver:
		; I don't know what will happen here.
		; I'll just test a few things...
		lea EBX, person1Id
		mov ECX, idOffset
		mov AL, BYTE PTR [EBX + 1*ECX]     ; can I get the ID?
		mov ECX, offOffset
		mov AL, BYTE PTR [EBX + 1*ECX]    ; ...offense?
		mov ECX, hpOffset
		mov AL, BYTE PTR [EBX + 1*ECX]     ; HP
		mov ECX, typeOffset
		mov EAX, DWORD PTR [EBX + 1*ECX] ; what happens if I try to read 4 consecutive bytes as a DWORD?
		; It's backwards??? Why thought? Is this just a Visual Studio formatting thing?
		mov ECX, longOffset
		mov EAX, DWORD PTR [EBX + 1*ECX] ; this is a different size than the others... will that cause problems?

	mov EAX, 0
	ret
main	ENDP

; I'm not sure how structs are really represented in memory, but I can guess.
; 	For this program, I will store each Person "struct" as a quadword like so:
;	- first 8 bytes are HP
;	- second 8 bytes are offense
;	As this gets more complex, I'll be adding more attributes, using the rest of the allocated space



; void newPerson(Person*, int hp, int off);
;	Populates a quadword with data
newPerson PROC
	; establish stack frame
	push EBP
	mov EBP, ESP

	; save registers
	pushfd
	push EBX

	; Stack:
	; [garbage]
	; [off    ]
	; [hp     ]
	; [Person*]
	; [return ]
	; [old EBP] <-- EBP
	; [EFLAGS ]
	; [EBX    ] <-- ESP

	; Now for the actual procedure
	mov EBX, DWORD PTR [EBP + 4*2]                  ; EBX will hold "this" pointer
	mov BYTE PTR [EBX], DWORD PTR [EBP + 4*3]       ; this->hp = hp
	mov BYTE PTR [EBX + 1*1], DWORD PTR [EBP + 4*4] ; this->off = off

	; restore registers
	pop EBX
	popfd

	; remove stack frame
	pop EBP

	ret
newPerson ENDP

; int getHp(Person* this)
getHp PROC
	; set up stack frame
	push EBP
	mov EBP, ESP

	; save registers
	pushfd

	; Stack:
	; [garbage]
	; [this   ]
	; [old EBP] <-- EBP
	; [EFLAGS ] <-- ESP

	; actual procedure
	mov EAX, DWORD PTR [EBP + 4*1] ; EAX now contains this pointer
	mov EAX, DWORD PTR [EAX]       ; EAX now contains the actual "object"
	shr EAX, 24d                   ; first 8 bits are HP, so move them to AL, setting others to 0

	; restore registers
	popfd

	; take down stack frame
	pop EBP

	ret
getHp ENDP

END
