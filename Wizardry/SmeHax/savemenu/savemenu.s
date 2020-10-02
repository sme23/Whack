.thumb
.align

.global PlaySongByProcArg
.type PlaySongByProcArg, %function


.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.equ ChangeBGMSmooth,0x80024d5

 PlaySongByProcArg:

push {r14}
@r0 = song ID
mov r1,#0
blh ChangeBGMSmooth
pop {r0}
bx r0

.ltorg
.align

