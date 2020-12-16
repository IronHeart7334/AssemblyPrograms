; a) Extract bits 3 & 2
; in .DATA...
mask_isolate_bits_3_and_2 BYTE 00001100b
; in .CODE...
mov AL, outcode
and AL, mask_isolate_bits_3_and_2
; outcode 0000 ???? b
;     and 0000 1100 b
; ===================
;         0000 ??00 b

; b) if logic
; isolated bits are still in AL
cmp AL, 1000b
je aboveRegion
cmp AL, 0100b
je belowRegion
jmp withinRegion ; IF (not above or below)
aboveRegion:
    ; point is above
    jmp endCheck
belowRegion:
    ; point is below
    jmp endCheck
withinRegion:
    ; point is within the region
    jmp endCheck
