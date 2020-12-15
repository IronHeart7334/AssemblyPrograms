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
person1 DWORD 2 dup(0) ; Allocate 64 bits per person
person2 DWORD 2 dup(0) ; may later change this to a dynamic memory pool a-la malloc

; names of procedures defined in other *.asm files in the project

; procedure code
.CODE
main	PROC

	; set up the fight

	; Push arguments
	mov EBX, 5d      ; person 1 off
	push EBX
	mov EBX, 20d     ; person 1 HP
	push EBX
	lea EBX, person1 ; load the space allocated for person 1
	push EBX

	; Invoke "constructor"
	call newPerson ; data has been loaded into person1

	; Pop arguments
	pop EBX
	pop EBX
	pop EBX

	; Person1 is now done, on to person 2
	; push actual arguments
	mov EBX, 7d
	push EBX
	mov EBX, 15d
	push EBX
	lea EBX, person2
	push EBX

	call newPerson

	pop EBX
	pop EBX
	pop EBX

	; By now, both people should be fully loaded



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
	mov BYTE PTR [EBX + 1*0], DWORD PTR [EBP + 4*3] ; this->hp = hp
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
	push EBX

	; Stack:
	; [garbage]
	; [this   ]
	; [return ]
	; [old EBP] <-- EBP
	; [EFLAGS ]
	; [EBX    ] <-- ESP

	; actual procedure
	mov EBX, DWORD PTR [EBP + 4*2] ; EBX now contains this pointer
	mov EAX, DWORD PTR [EBX]       ; EAX now contains the actual "object"
	shr EAX, 24d                   ; first 8 bits are HP, so move them to AL, setting others to 0

	; restore registers
	pop EBX
	popfd

	; take down stack frame
	pop EBP

	ret
getHp ENDP

; int getOff(Person* this);
getOff PROC
	; set up stack frame
	push EBP
	mov EBP, ESP

	; save registers
	pushfd
	push EBX

	; Stack:
	; [garbage]
	; [this   ]
	; [return ]
	; [old EBP] <--- EBP
	; [EFLAGS ]
	; [EBX    ] <--- ESP

	; actual procedure
	mov EBX, DWORD PTR [EBP + 4*2] ; EBX now contains "this" pointer
	mov EAX, DWORD PTR [EBX]       ; EAX now contains the first 32 bits of the object
	                               ; [~~~~ ~~~~ XXXX XXXX ~~~~ ~~~~ ~~~~ ~~~~] Bits I want are X's
	shl EAX, 8d                    ; [XXXX XXXX ~~~~ ~~~~ ~~~~ ~~~~ 0000 0000]
	shr EAX, 24d                   ; [0000 0000 0000 0000 0000 0000 XXXX XXXX]
	; done

	; restore registers
	pop EBX
	popfd

	; take down stack frame
	pop EBP

	ret
getOff ENDP

; void fight(Person* p1, Person* p2);
fight PROC
	
	ret
fight ENDP

END
