.thumb
.align

.include "LaguzBars_Defs.s"

@ ======================================================
@ ========= UNTRANSFORM AT THE END OF CHAPTERS =========
@ ======================================================


.global UntransformTransformedLaguz
.type UntransformTransformedLaguz, %function


UntransformTransformedLaguz:

@we need to check for each player unit to see if they are transformed
@if so, we need to untransform them
@should be lib funcs for both of these, after getting each unit ptr
@so we can setup a loop for this then

push {r4-r7,r14}

ldr r4,=#0x202BE4C @start of player unit structs
mov r5,#0 @number of units checked so far

UntransformTransformedLaguz_LoopStart:
@have we checked every unit?
cmp r5,#62
beq UntransformTransformedLaguz_LoopExit

@does unit exist?
ldr r0,[r4]
cmp r0,#0
beq UntransformTransformedLaguz_LoopExit

@is unit transformed?
mov r0,r4
bl IsLaguzTransformed
cmp r0,#0
beq UntransformTransformedLaguz_LoopRestart

@untransform them
mov r0,r4
bl LaguzUntransform

UntransformTransformedLaguz_LoopRestart:
add r4,#0x48 @size of unit struct
add r5,#1
b UntransformTransformedLaguz_LoopStart


UntransformTransformedLaguz_LoopExit:

pop {r4-r7}
mov r0,#0
pop {r1}
bx r1


.ltorg
.align





@ ===================================================
@ ========== AUTO-TRANSFORM ENEMIES & NPCS ==========
@ ===================================================


.global AutoTransformNonPlayerLaguz
.type AutoTransformNonPlayerLaguz, %function

AutoTransformNonPlayerLaguz:
push {r4-r5,r14}

@loop through every enemy & npc unit
@check if untransformed laguz
@check bar
@if both true, transform
@restart loop

ldr r4,=#0x202CFBC @start of enemy unit structs
mov r5,#0

AutoTransformNonPlayerLaguz_Loop1Start:
cmp r5,#49
beq AutoTransformNonPlayerLaguz_Loop1Exit
ldr r0,[r4]
cmp r0,#0
beq AutoTransformNonPlayerLaguz_Loop1Restart

@check if untransformed laguz
mov r0,r4
bl IsLaguzTransformed
cmp r0,#0
bne AutoTransformNonPlayerLaguz_Loop1Restart

@check bar
mov r0,r4
bl GetLaguzBar
cmp r0,#30
bne AutoTransformNonPlayerLaguz_Loop1Restart

@transform
mov r0,r4
bl GetTransformedClass
mov r1,#84 @size of char table entry
mul r0,r1
ldr r1,=ClassTable
add r0,r1
str r0,[r4,#4]
mov r0,r4
bl ToggleLaguzTransformed

AutoTransformNonPlayerLaguz_Loop1Restart:
add r4,#0x48 @size of unit struct
add r5,#1
b AutoTransformNonPlayerLaguz_Loop1Start


AutoTransformNonPlayerLaguz_Loop1Exit:

ldr r4,=#0x202DDCC @start of NPC unit structs
mov r5,#0

AutoTransformNonPlayerLaguz_Loop2Start:
cmp r5,#19
beq AutoTransformNonPlayerLaguz_GoBack
ldr r0,[r4]
cmp r0,#0
beq AutoTransformNonPlayerLaguz_Loop2Restart

@check if untransformed laguz
mov r0,r4
bl IsLaguzTransformed
cmp r0,#0
bne AutoTransformNonPlayerLaguz_Loop2Restart

@check bar
mov r0,r4
bl GetLaguzBar
cmp r0,#30
bne AutoTransformNonPlayerLaguz_Loop2Restart

@transform
mov r0,r4
bl GetTransformedClass
mov r1,#84 @size of char table entry
mul r0,r1
ldr r1,=ClassTable
add r0,r1
str r0,[r4,#4]
mov r0,r4
bl ToggleLaguzTransformed

AutoTransformNonPlayerLaguz_Loop2Restart:
add r4,#0x48 @size of unit struct
add r5,#1
b AutoTransformNonPlayerLaguz_Loop2Start


AutoTransformNonPlayerLaguz_GoBack:

pop {r4-r5}
pop {r0}
bx r0

.ltorg
.align





