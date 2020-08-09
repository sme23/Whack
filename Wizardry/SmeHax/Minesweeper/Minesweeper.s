.thumb
.align


.global MS_InitializeBombsASMC
.type MS_InitializeBombsASMC, %function

.global MS_GetTileValue
.type MS_GetTileValue, %function


.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.equ Roll1RN,0x8000ca0
.equ AddTrap, 0x802e2b8
.equ MapWidth, 0x202E4D4
.equ MapHeight, 0x202E4D6
.equ GetTrapAt, 0x802e1f0

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

@make a trap 
mov r0,#69 @trap ID but doesnt really matter
mov r1,r5 @x value
mov r2,r6 @y value
mov r3,#0 @+0x3 byte but doesnt really matter
blh AddTrap

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



MS_GetTileValue:
push {r4-r7,r14}
mov r4,r0 @x value
mov r5,r1 @y value
mov r6,#0 @init value

@first off, is this a bomb?
mov r0,r4
mov r1,r5
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckTopLeft
@it IS a bomb
mov r6,#0xFF
b GetTileValue_GoBack


@it is NOT a bomb, so let's check the 8 adjacent tiles for bombs

GetTileValue_CheckTopLeft:
mov r0,r4
mov r1,r5
sub r0,#1
sub r1,#1
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckTop
add r6,#1

GetTileValue_CheckTop:
mov r0,r4
mov r1,r5
sub r1,#1
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckTopRight
add r6,#1

GetTileValue_CheckTopRight:
mov r0,r4
mov r1,r5
add r0,#1
sub r1,#1
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckRight
add r6,#1

GetTileValue_CheckRight:
mov r0,r4
mov r1,r5
add r0,#1
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckBottomRight
add r6,#1

GetTileValue_CheckBottomRight:
mov r0,r4
mov r1,r5
add r0,#1
add r1,#1
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckBottom
add r6,#1

GetTileValue_CheckBottom:
mov r0,r4
mov r1,r5
add r1,#1
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckBottomLeft
add r6,#1

GetTileValue_CheckBottomLeft:
mov r0,r4
mov r1,r5
sub r0,#1
add r1,#1
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckLeft
add r6,#1

GetTileValue_CheckLeft:
mov r0,r4
mov r1,r5
sub r0,#1
blh GetTrapAt
cmp r0,#0
beq GetTileValue_CheckLeft
add r6,#1

GetTileValue_GoBack:
mov r0,r6
pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align







