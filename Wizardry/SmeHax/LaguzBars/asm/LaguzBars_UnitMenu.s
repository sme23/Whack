.thumb
.align

.include "LaguzBars_Defs.s"

@ ============================================
@ ========== TRANSFORM MENU COMMAND ==========
@ ============================================

.global TransformUsability
.type TransformUsability, %function

.global TransformEffect
.type TransformEffect, %function




TransformUsability:
push {r4,r14}
ldr r0,=#0x3004E50
ldr r4,[r0]

@are we an untransformed laguz?
mov r0,r4
bl IsLaguzTransformed 
cmp r0,#0 @1 means transformed, 2 means not a laguz; we only want to do this if we are not transformed, which is 0
bne TransformUsability_ReturnFalse 

@we are!
@is our bar full?
mov r0,r4
bl GetLaguzBar
cmp r0,#30
bne TransformUsability_ReturnFalse

@it is!
@so, we can transform
b TransformUsability_ReturnTrue


TransformUsability_ReturnFalse:
mov r0,#3
b TransformUsability_GoBack


TransformUsability_ReturnTrue:
mov r0,#1


TransformUsability_GoBack:
pop {r4}
pop {r1}
bx r1

.ltorg
.align






TransformEffect:
push {r4,r14}


@TODO: fancy visuals here


ldr r0,=#0x3004E50 @pointer to active unit's unit struct
ldr r4,[r0] @r4 = unit struct

mov r0,r4
bl GetTransformedClass
cmp r0,#0
beq TransformEffect_GoBack

@apply new class
mov r1,#84
mul r0,r1
ldr r1,=ClassTable
add r0,r1

str r0,[r4,#4] @store new class ptr

@set the "is transformed" flag
mov r0,r4
bl ToggleLaguzTransformed

@silently give sharp claw (temp)
@mov r0,r4
@add r0,#0x1E
@mov r1,#0x8B
@strh r1,[r0]

TransformEffect_GoBack:
mov r0,#0x94		@play beep sound & end menu on next frame & clear menu graphics
pop {r4}
pop {r1}
bx r1

.ltorg
.align
