.thumb
.align

.include "LaguzBars_Defs.s"

.global LaguzBarItemUsability
.type LaguzBarItemUsability, %function

.global OliviGrassEffect
.type OliviGrassEffect, %function

.global LaguzStoneEffect
.type LaguzStoneEffect, %function


.equ ItemUse_GoBackLoc,0x0802FF77
.equ Get_Char_Data,0x08019430
.equ RemoveUnitBlankItems,0x8017984


LaguzBarItemUsability:
@is bar full?

ldr r0,=#0x3004E50
ldr r0,[r0]
bl GetLaguzBar
@r0 = laguz bar

cmp r0,#30
bge ReturnFalse

@are we transformed?
ldr r0,=#0x3004E50
ldr r0,[r0]
bl IsLaguzTransformed
cmp r0,#0 @1 if transformed, 2 if not laguz
bne ReturnFalse 

ReturnTrue:
mov r0,#1
b GoBack

ReturnFalse:
mov r0,#0

GoBack:
pop {r4,r5}
pop {r1}
bx r1


.ltorg
.align




OliviGrassEffect:

push {r4-r7}
@add 15 to the bar for current unit
@bounds checking in the setter

ldr r0,=#0x3004E50
ldr r0,[r0]
ldrb    r1,[r4,#0x12]        @item slot

mov r4,r0
mov r5,r1

mov r0,r4
bl GetLaguzBar
add r0,#15
mov r1,r0
mov r0,r4
bl SetLaguzBar

@get bar again, is it full?
mov r0,r4
bl GetLaguzBar

cmp r0,#30
bne OliviGrass_DecrementUses

@transform
mov r0,r4
bl LaguzTransform

OliviGrass_DecrementUses:

@remove 1 use
mov r1,r5
mov 		r2,r4 @get char struct
add 		r2,#0x1E @get start of inventory data
lsl 		r1,r1,#1 @multiply item slot by 2, for length of inventory entry
add 		r2,r1 @r2 = offset of item entry

ldrh r6,[r2] @get item halfword
lsr r0,r6,#8 @keep only durability byte in r0
sub r0,#1

cmp r0,#0
bne OliviGrass_SkipRemovingItem 

@if uses is now 0, write back 0 over it & shuffle inventory up w/ function that does that

strh r0,[r2] @removes item
mov r0,r4
ldr r3,=RemoveUnitBlankItems
mov r14,r3
.short 0xF800
b LaguzStoneEffect_GoBack

OliviGrass_SkipRemovingItem:
lsl r0,r0,#8
mov r1,#0xFF
and r6,r1
orr r6,r0
strh r6,[r2]

OliviGrass_GoBack:
pop {r4-r7}
ldr r0,=ItemUse_GoBackLoc
bx r0

.ltorg
.align



LaguzStoneEffect:
push {r4-r7}

ldr r0,=#0x3004E50
ldr r0,[r0]
ldrb    r1,[r4,#0x12]        @item slot

mov r4,r0
mov r5,r1

mov r0,r4
mov r1,#30
bl SetLaguzBar

mov r0,r4
bl LaguzTransform

@remove 1 use

mov r1,r5
mov 		r2,r4 @get char struct
add 		r2,#0x1E @get start of inventory data
lsl 		r1,r1,#1 @multiply item slot by 2, for length of inventory entry
add 		r2,r1 @r2 = offset of item entry

ldrh r6,[r2] @get item halfword
lsr r0,r6,#8 @keep only durability byte in r0
sub r0,#1

cmp r0,#0
bne LaguzStoneEffect_SkipRemovingItem 

@if uses is now 0, write back 0 over it & shuffle inventory up w/ function that does that

strh r0,[r2] @removes item
mov r0,r4
ldr r3,=RemoveUnitBlankItems
mov r14,r3
.short 0xF800
b LaguzStoneEffect_GoBack

LaguzStoneEffect_SkipRemovingItem:
lsl r0,r0,#8
mov r1,#0xFF
and r6,r1
orr r6,r0
strh r6,[r2]

LaguzStoneEffect_GoBack:
pop {r4-r7}
ldr r0,=ItemUse_GoBackLoc
bx r0

Get_Char_Data:
.long 

.ltorg
.align
