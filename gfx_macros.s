.equ F_BLACK, 0
.equ F_BLUE, 1
.equ SCREEN, 0x4000
.equ ATTRS,  0x5800

.macro line_calc _reg, _x, _y
    ld      _reg,#(SCREEN+(32*64)*(_y/64)+32*((_y/8)%8)+256*(_y%8)+_x)
.endm

.macro attr_calc _reg, _x, _y
    ld      _reg,#(ATTRS+_y*32+_x)
.endm

.macro attr_calc_l _reg, _x, _y
    ld      _reg,#<(ATTRS+_y*32+_x)
.endm

.macro line_down _l, _h, ?break
    inc     _h
    ld      a,_h
    and     #7
    jr      nz,break
    ld      a,_l
    sub     #-32
    ld      _l,a
    sbc     a,a
    and     #0xF8
    add     a,_h
    ld      _h,a
break:
.endm
