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

	lea EBX, person2
	push EBX
	lea EBX, person1
	push EBX
	call fight
	pop EBX
	pop EBX

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
	push EAX

	; Stack:
	; [garbage]
	; [off    ]
	; [hp     ]
	; [Person*]
	; [return ]
	; [old EBP] <-- EBP
	; [EFLAGS ]
	; [EBX    ]
	; [EAX    ] <-- ESP

	; Now for the actual procedure
	mov EBX, DWORD PTR [EBP + 4*2]                  ; EBX will hold "this" pointer
	mov EAX, DWORD PTR [EBP + 4*3]
	mov BYTE PTR [EBX + 1*0], AL ; this->hp = hp
	mov EAX, DWORD PTR [EBP + 4*4]
	mov BYTE PTR [EBX + 1*1], AL ; this->off = off

	; restore registers
	pop EAX
	pop EBX
	popfd

	; remove stack frame
	pop EBP

	ret
newPerson ENDP

; int getHp(Person* this);
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
	mov EAX, 0
	mov AL, BYTE PTR [EBX + 1*0]   ; first 8 bits are HP

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
	mov EAX, 0
	mov AL, BYTE PTR [EBX + 1*1]   ; second byte is offense

	; restore registers
	pop EBX
	popfd

	; take down stack frame
	pop EBP

	ret
getOff ENDP

; void takeDmg(Person* this, int amount);
takeDmg PROC
	push EBP
	mov EBP, ESP

	pushfd
	push EDX
	push EBX

	; Stack:
	; [garbage]
	; [amount ]
	; [this   ]
	; [return ]
	; [old EBP] <--- EBP
	; [EFLAGS ]
	; [EDX    ]
	; [EBX    ] <--- ESP
	mov EDX, DWORD PTR [EBP + 4*3] ; EDX holds the damage
	push DWORD PTR [EBP + 4*2]     ; push "this"
	call getHp                     ; EAX contains the HP
	pop DWORD PTR [EBP + 4*2]
	cmp EAX, EDX
	jae doTakeDmg
	; else, need to prevent overflow
	mov EDX, EAX ; max out at the person's HP
	doTakeDmg:
		mov EBX, DWORD PTR [EBP + 4*2] ; EBX holds "this"
		sub BYTE PTR [EBX + 1*0], DL   ; reduce this' HP by DL

	pop EBX
	pop EDX
	popfd

	pop EBP

	ret
takeDmg ENDP

; void fight(Person* p1, Person* p2);
fight PROC
	; set up stack frame
	push EBP
	mov EBP, ESP

	; save registers
	pushfd
	push EBX
	push EAX

	; allocate storeage
	push EBX ; target
	push EBX ; attacker

	; Stack:
	; [garbage    ]
	; [person2 ptr]
	; [person1 ptr]
	; [return addr]
	; [old EBP    ] <--- EBP
	; [old EFLAGS ]
	; [old EBX    ]
	; [old EAX    ]
	; [target     ]
	; [attacker   ] <--- ESP

	; actual procedure
	push DWORD PTR [EBP + 4*3]
	pop DWORD PTR [EBP - 4*4] ; start with person2 in target
	push DWORD PTR [EBP + 4*2]
	pop DWORD PTR [EBP - 4*5] ; and person1 as the attacker
	checkIfAttackerIsKoed:
		push DWORD PTR [EBP - 4*5]
		call getHp
		pop DWORD PTR [EBP - 4*5]
		cmp EAX, 0
		je koOccurred
	checkIfTargetIsKoed:
		push DWORD PTR [EBP - 4*4]
		call getHp
		pop DWORD PTR [EBP - 4*4]
		cmp EAX, 0
		je koOccurred
	bothPeopleAreStillUp:
		push DWORD PTR [EBP - 4*5]
		call getOff
		pop DWORD PTR [EBP - 4*5]
		; EAX contains the damage
		push EAX
		push DWORD PTR [EBP - 4*4]
		call takeDmg
		pop DWORD PTR [EBP - 4*4]
		pop EAX

		; lastly, swap attacker and target
		push DWORD PTR [EBP - 4*4]
		push DWORD PTR [EBP - 4*5]
		pop DWORD PTR [EBP - 4*4]
		pop DWORD PTR [EBP - 4*5]

		jmp checkIfAttackerIsKoed
	koOccurred:
		; fight is over

	; clear allocated storage
	pop EBX
	pop EBX

	; restore registers
	pop EAX
	pop EBX
	popfd

	; take down stack frame
	pop EBP

	ret
fight ENDP

END
