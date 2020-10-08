.thumb
.align

.global SoundRoomPostgameUnlock
.type SoundRoomPostgameUnlock, %function

.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm


SoundRoomPostgameUnlock:
push {r14}
@using a global flag isn't going to work because this is outside of any save files
@need to designate an area with EMS to write to and read from with this
mov r0,#1
pop {r1}
bx r1

.ltorg
.align


