.area _HEADER (ABS)
.org 28800

.area _CODE

.include "gfx_macros.s"

.equ TITLE_H, 14
.equ TITLE_W, 8
.equ TITLE_BORD,   (0x40*1+(0<<3)+5)
.equ TITLE_BORD_S, (0x40*0+(0<<3)+5)
.equ TITLE_TEXT,   (0x40*1+(0<<3)+7)
.equ TITLE_TEXT_S, (0x40*0+(0<<3)+7)

_main::
    ld      hl,#_data
    line_calc de, (32-TITLE_W)/2, 161
    ld      b,#TITLE_H
1$:
    push    bc
    push    de
    ld      bc,#TITLE_W
    ldir
    pop     de
    pop     bc
    line_down e, d
    djnz    1$

; 11
    attr_calc de, (32-TITLE_W)/2, 20
    ld      a,#TITLE_BORD
    ld      (de),a
    inc     de

; 12-17
    ld      b,#TITLE_W-2
    ld      a,#TITLE_TEXT
2$:
    ld      (de),a
    inc     de
    djnz    2$
; 18
    ld      a,#TITLE_BORD
    ld      (de),a

; 21
    attr_calc_l e, (32-TITLE_W)/2, 21
    ld      a,#TITLE_BORD_S
    ld      (de),a
    inc     e
; 22-27
    ld      b,#TITLE_W-2
    ld      a,#TITLE_TEXT_S
3$:
    ld      (de),a
    inc     de
    djnz    3$
;28
    ld      a,#TITLE_BORD_S
    ld      (de),a

    ret

.area _DATA

_data:
.include "loadtitle.s"
