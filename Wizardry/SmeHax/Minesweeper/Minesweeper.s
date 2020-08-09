.thumb
.align


.global MS_InitializeBombsASMC
.type MS_InitializeBombsASMC, %function






.equ Roll1RN,0x8000ca0
.equ AddTrap, 0x802e2b8
.equ MapWidth, 0x202E4D4
.equ MapHeight, 0x202E4D6

MS_InitializeBombsASMC:
push {r4-r7,r14}

@get a random number from 0-19, then add 21 to it

mov r0,#19
blh Roll1RN
add r0,#21

@this will be the number of times to run the following loop
mov r7,r0

InitBombs_LoopStart:
cmp r7,#0
beq InitBombs_LoopExit

@get an X value from 0-(map_width-1)
ldr r0,=MapWidth
ldrh r0,[r0]
sub r0,#1
blh Roll1RN
@store in a not-scratch register
mov r5,r0 

@get a Y value from 0-(map_height-1)
ldr r0,=MapHeight
ldrh r0,[r0]
sub r0,#1
blh Roll1RN
@store in a not-scratch register
mov r6,r0




InitBombs_LoopRestart:
sub r7,#1
b InitBombs_LoopStart


InitBombs_LoopExit:
@done with making bombs

pop {r4-r7}
pop {r0}
bx r0

.ltorg
.align


