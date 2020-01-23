.area _CODE

_main::
    ld      hl,#0        ; addr. for immediate = _main+1
    ld      de,#{LoaderStart}
    push    de
    ld      bc,#_progbits+{SkipOffset}
    add     hl,bc
    ld      bc,#{LoaderSize}
    ldir
    ret

.area _DATA

_progbits:
