.thumb
.align

.global SoundRoomPostgameUnlock
.type SoundRoomPostgameUnlock, %function


SoundRoomPostgameUnlock:
push {r14}
@this is going to use a flag to denote the ending has happened
@but for now unconditionally return true
mov r0,#0
pop {r1}
bx r1

.ltorg
.align


