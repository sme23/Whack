.thumb
.align

.include "LaguzBars_Defs.s"

@ =======================================================
@ ========== INCREMENT AND DECREMENT PER PHASE ==========
@ =======================================================

	
.global IncDecLaguzBarsPerPhase
.type IncDecLaguzBarsPerPhase, %function


IncDecLaguzBarsPerPhase:

push {r4-r7,r14}

mov r6,#0

@inc bars of units based on current phase
ldr r0,=#0x202BCF0 @chapter data struct
ldrb r0,[r0,#0x0F] @current phase

cmp r0,#0x80
beq IncDecLaguzBarsPerPhase_IsEnemyPhase

cmp r0,#0x40
beq IncDecLaguzBarsPerPhase_IsNPCPhase


IncDecLaguzBarsPerPhase_IsPlayerPhase:
ldr r4,=#0x202BE4C @start of player unit structs
mov r7,#62 @# of times to loop through structs
b IncDecLaguzBarsPerPhase_LoopStart

IncDecLaguzBarsPerPhase_IsEnemyPhase:
ldr r4,=#0x202CFBC @start of enemy unit structs
mov r7,#49 @# of times to loop through structs
b IncDecLaguzBarsPerPhase_LoopStart

IncDecLaguzBarsPerPhase_IsNPCPhase:
ldr r4,=#0x202DDCC @start of NPC unit structs
mov r7,#19 @# of times to loop through structs

IncDecLaguzBarsPerPhase_LoopStart:
cmp r6,r7
beq IncDecLaguzBarsPerPhase_LoopExit
ldr r0,[r4]
cmp r0,#0
beq IncDecLaguzBarsPerPhase_LoopRestart

mov r0,r4
bl IsLaguzTransformed
cmp r0,#2
beq IncDecLaguzBarsPerPhase_LoopRestart
cmp r0,#1
beq IncDecLaguzBarsPerPhase_LoopTransformed

IncDecLaguzBarsPerPhase_LoopUntransformed:
mov r0,r4
bl GetLaguzBar
mov r5,r0
mov r0,r4
bl GetBarTurnGain
add r0,r5
mov r1,r0
mov r0,r4
bl SetLaguzBar
b IncDecLaguzBarsPerPhase_LoopRestart


IncDecLaguzBarsPerPhase_LoopTransformed:
mov r0,r4
bl GetLaguzBar
mov r5,r0
mov r0,r4
bl GetBarTurnLoss
mov r1,r0
mov r0,r5
sub r0,r1
mov r1,r0
mov r0,r4
bl SetLaguzBar


IncDecLaguzBarsPerPhase_LoopRestart:
add r4,#0x48
mov r5,#0
add r6,#1
b IncDecLaguzBarsPerPhase_LoopStart


IncDecLaguzBarsPerPhase_LoopExit:

pop {r4-r7}
pop {r0}
bx r0

.ltorg
.align



@ ========================================================
@ ========== INCREMENT AND DECREMENT PER BATTLE ==========
@ ========================================================

.global IncDecLaguzBarsPerBattle
.type IncDecLaguzBarsPerBattle, %function

IncDecLaguzBarsPerBattle: @r4 = unit struct
push {r5-r6,r14}


@validate action as combat
ldr r0,=#0x203A958 @action struct
ldrb r0,[r0,#0x11] @action taken
cmp r0,#2 @combat action
bne IncDecLaguzBarsPerBattle_GoBack

mov r6,r5

mov r0,r4
bl IsLaguzTransformed
cmp r0,#2
beq IncDecLaguzBarsPerBattle_CheckDefender
cmp r0,#1
beq IncDecLaguzBarsPerBattle_IsTransformed

IncDecLaguzBarsPerBattle_IsUntransformed:
mov r0,r4
bl GetLaguzBar
mov r5,r0
mov r0,r4
bl GetBarBattleGain
add r0,r5
mov r1,r0
mov r0,r4
bl SetLaguzBar
b IncDecLaguzBarsPerBattle_CheckDefender


IncDecLaguzBarsPerBattle_IsTransformed:
mov r0,r4
bl GetLaguzBar
mov r5,r0
mov r0,r4
bl GetBarBattleLoss
mov r1,r0
mov r0,r5
sub r0,r1
mov r1,r0
mov r0,r4
bl SetLaguzBar


IncDecLaguzBarsPerBattle_CheckDefender:
mov r0,r6
bl IsLaguzTransformed
cmp r0,#2
beq IncDecLaguzBarsPerBattle_GoBack
cmp r0,#1
beq IncDecLaguzBarsPerBattle_IsTransformed2

IncDecLaguzBarsPerBattle_IsUntransformed2:
mov r0,r6
bl GetLaguzBar
mov r5,r0
mov r0,r6
bl GetBarBattleGain
add r0,r5
mov r1,r0
mov r0,r6
bl SetLaguzBar
b IncDecLaguzBarsPerBattle_GoBack


IncDecLaguzBarsPerBattle_IsTransformed2:
mov r0,r6
bl GetLaguzBar
mov r5,r0
mov r0,r6
bl GetBarBattleLoss
mov r1,r0
mov r0,r5
sub r0,r1
mov r1,r0
mov r0,r6
bl SetLaguzBar



IncDecLaguzBarsPerBattle_GoBack:
pop {r5-r6}
pop {r0}
bx r0

.ltorg
.align

