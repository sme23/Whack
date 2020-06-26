.thumb
.align



.global LaguzBarItemUsability
.type LaguzBarItemUsability, %function

.global OliviGrassEffect
.type OliviGrassEffect, %function

.global LaguzStoneEffect
.type LaguzStoneEffect, %function


.equ ItemUse_GoBackLoc,0x0802FF77


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
ldr r4,[r0]
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
bne OliviGrass_GoBack

@transform
mov r0,r4
bl LaguzTransform

OliviGrass_GoBack:
pop {r4-r7}
ldr r0,=ItemUse_GoBackLoc
bx r0

.ltorg
.align



LaguzStoneEffect:
push {r4-r7}
@fill laguz bar & autotransform
ldr r0,=#0x3004E50
ldr r4,[r0]

mov r0,r4
mov r1,#30
bl SetLaguzBar

mov r0,r4
bl LaguzTransform

pop {r4-r7}
ldr r0,=ItemUse_GoBackLoc
bx r0

.ltorg
.align

