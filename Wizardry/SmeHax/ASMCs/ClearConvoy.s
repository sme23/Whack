.thumb
.align


.global ClearConvoyASMC
.type ClearConvoyASMC, %function


ClearConvoyASMC:
@this clears the convoy of all items
@to be used at the end of chapters here when cleaning up the state of things before returning to scenario selection


ldr r0,=#0x203A81C
ldr r1,=#0x203A8E4
mov r2,#0

LoopStart:
cmp r0,r1
beq LoopExit
str r2,[r0]
add r0,#4
b LoopStart


LoopExit:
bx r14


.ltorg
.align
