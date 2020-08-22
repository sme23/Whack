.thumb
.align


.global MS_InitializeBombsASMC
.type MS_InitializeBombsASMC, %function

.global MS_GetTileValue
.type MS_GetTileValue, %function

.global MS_UncoverTileAtActiveUnitPos
.type MS_UncoverTileAtActiveUnitPos, %function

.global MS_UncoverTileAt
.type MS_UncoverTileAt, %function

.global MS_CommandUsability
.type MS_CommandUsability, %function

.global NextRN_19
.type NextRN_19, %function


.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.equ RandNext,0x8000B88
.equ AddTrap, 0x802e2b8
.equ MapWidth, 0x202E4D4
.equ MapHeight, 0x202E4D6
.equ GetTrapAt, 0x802e1f0
.equ gMapRawTiles, 0x859a9d4
.equ gActiveUnit, 0x3004e50
.equ CallEventEngine, 0x800d07C
.equ gChapterData, 0x202bcf0
.equ RefreshTilesMaybe, 0x8019624


NextRN_19:
push {r14}
blh RandNext
mov r1,#19
mul r0,r1
cmp r0,#0
bge NextRN_19_skip
ldr r1,=#0xFFFF
add r0,r1
NextRN_19_skip:
asr r0,r0,#0x10
pop {r1}
bx r1

.ltorg
.align


MS_InitializeBombsASMC:
push {r4-r7,r14}

@get a random number from 0-19, then add 21 to it

mov r0,#19
blh NextRN_19
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
blh NextRN_19
@store in a not-scratch register
mov r5,r0 

@get a Y value from 0-(map_height-1)
ldr r0,=MapHeight
ldrh r0,[r0]
sub r0,#1
blh NextRN_19
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
beq GetTileValue_GoBack
add r6,#1

GetTileValue_GoBack:
mov r0,r6
pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align


MS_UncoverTileAtActiveUnitPos: @this will be called as a unit menu command effect
push {r14}

@find the active unit pos
ldr r0,=gActiveUnit
ldr r0,[r0]
ldrb r1,[r0,#0x11] @y coord
ldrb r0,[r0,#0x10] @x coord


bl MS_UncoverTileAt

mov r0,#0x94
pop {r1}
bx r1

.ltorg
.align



MS_UncoverTileAt:
push {r4-r7,r14}

mov r4,r0 @x coord
mov r5,r1 @y coord

@use these to index the tile map
@we can't just use teq's outline for this verbatim
@since tile map entries are 2 bytes instead of 1
@same general idea tho

ldr r2,=gMapRawTiles
ldr r2,[r2]
lsl r1,r5,#2 @*4
add r2,r1
ldr r2,[r2] @row pointer
lsl r0,r4,#1 @*2
add r2,r0

@now let's hold onto this address for a bit
mov r6,r2

@is the value at this address anything other than the ID of the covered tile (0x0000)?
ldrh r0,[r6]
cmp r0,#0
bne UncoverTile_GoBack

@get the value of the tile
mov r0,r4
mov r1,r5
bl MS_GetTileValue
@if the value 0xFF?
cmp r0,#0xFF
beq UncoverTile_IsBomb
@is the value 0?
cmp r0,#0
bne UncoverTile_DoTheUncovering
@if so, then recursion :33333333333333
ldr r7,=#0xFFFFFFFF

UncoverTileAt_Recursion1:
mov r0,r4
mov r1,r5
sub r0,#1
sub r1,#1
cmp r0,r7
beq UncoverTileAt_Recursion2
cmp r1,r7
beq UncoverTileAt_Recursion2
bl MS_UncoverTileAt

UncoverTileAt_Recursion2:
mov r0,r4
mov r1,r5
sub r1,#1
cmp r1,r7
beq UncoverTileAt_Recursion3
bl MS_UncoverTileAt


UncoverTileAt_Recursion3:
mov r0,r4
mov r1,r5
add r0,#1
sub r1,#1
cmp r1,r7
beq UncoverTileAt_Recursion4
bl MS_UncoverTileAt


UncoverTileAt_Recursion4:
mov r0,r4
mov r1,r5
add r0,#1
bl MS_UncoverTileAt


UncoverTileAt_Recursion5:
mov r0,r4
mov r1,r5
add r0,#1
add r1,#1
bl MS_UncoverTileAt


UncoverTileAt_Recursion6:
mov r0,r4
mov r1,r5
add r1,#1
bl MS_UncoverTileAt


UncoverTileAt_Recursion7:
mov r0,r4
mov r1,r5
sub r0,#1
add r1,#1
cmp r0,r7
beq UncoverTileAt_Recursion8
bl MS_UncoverTileAt


UncoverTileAt_Recursion8:
mov r0,r4
mov r1,r5
sub r0,#1
cmp r0,r7
beq UncoverTileAt_RecursionEnd
bl MS_UncoverTileAt


UncoverTileAt_RecursionEnd:
@set current tile to 0x0004 and return
mov r0,#4
strh r0,[r6]
b UncoverTile_GoBack

UncoverTile_DoTheUncovering:
@tile ID is 0x000C+(value*4)
lsl r0,r0,#2 @*4
mov r1,#0xC
add r0,r1
strh r0,[r6]
b UncoverTile_GoBack

UncoverTile_IsBomb:
@first, uncover the tile
mov r0,#0xC
strh r0,[r6]



@next, go boom
ldr	r0,=CallEventEngine
mov	lr, r0
ldr	r0, =MinesweeperGoBoom
mov	r1, #0x01
.short	0xF800


UncoverTile_GoBack:
@refresh from buffer
blh RefreshTilesMaybe

pop {r4-r7}
pop {r0}
bx r0

.ltorg
.align




MS_CommandUsability:
push {r14}
@is current chapter ID correct?
ldr r0,=gChapterData
ldrb r0,[r0,#0xE]
ldr r1,=MinesweeperChIDLink
ldrb r1,[r1]
cmp r0,r1
bne Command_RetFalse
mov r0,#1
b Command_GoBack

Command_RetFalse:
mov r0,#3

Command_GoBack:
pop {r1}
bx r1

.ltorg
.align






