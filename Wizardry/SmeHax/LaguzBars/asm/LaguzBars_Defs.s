.thumb
.align

@shared defs file for each piece

.macro blh to, reg=r3
    ldr \reg, =\to
    mov lr, \reg
    .short 0xF800
.endm
.equ GetUnit,0x8019430
