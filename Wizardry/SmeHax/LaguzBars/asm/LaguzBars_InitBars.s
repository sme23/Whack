.thumb
.align

.include "LaguzBars_Defs.s"

@ =============================================================
@ ========== INITIALIZE BARS AT BEGINNING OF CHAPTER ==========
@ =============================================================

.global InitializeLaguzBarsIfFirstTurn
.type InitializeLaguzBarsIfFirstTurn, %function

InitializeLaguzBarsIfFirstTurn:
push {r4,r14}

@make sure it's the first turn and player phase

@character data struct (202BCF0) contatins both turn and phase

@if (turn == 1 && phase == 0) we do our thing; otherwise, no

ldr r1,=#0x202BCF0
ldrh r0,[r1,#0x10]
cmp r0,#1
bne InitializeLaguzBars_GoBack

ldrb r0,[r1,#0x0F]
cmp r0,#0
bne InitializeLaguzBars_GoBack


@loop through every player character until we find an empty struct

ldr r4,=#0x202BE4C @start of player unit structs

InitializeLaguzBars_LoopStart1:

ldr r0,[r4]
cmp r0,#0
beq InitializeLaguzBars_LoopEnd1

@get class ID
ldr r0,[r4,#4]	@r0 = pointer to class data
ldrb r0,[r0,#4]  @r0 = class ID

bl IsClassLaguz @returns true or false
cmp r0,#0
beq InitializeLaguzBars_LoopRestart1

@get char ID
ldr r0,[r4] 	@r0 = pointer to char data
ldrb r0,[r0,#4] @r0 = char ID

@add to bar starting position table offset
ldr r1,=BarStartingPositionTable
add r0,r1

ldrb r1,[r0] 	@r0 = bar starting position

mov r0,r4
bl SetLaguzBar

@check if unit has either skill that denotes them needing to transform here
ldr r0,=SkillTester
mov r14,r0
mov r0,r4
ldr r1,=WildheartIDLink
ldrb r1,[r1]
.short 0xF800
cmp r0,#0
bne InitializeLaguzBars_AutotransformPlayerUnit

ldr r0,=SkillTester
mov r14,r0
mov r0,r4
ldr r1,=FormshiftIDLink
ldrb r1,[r1]
.short 0xF800
cmp r0,#0
beq InitializeLaguzBars_LoopRestart1

InitializeLaguzBars_AutotransformPlayerUnit:
mov r0,r4
bl LaguzTransform

InitializeLaguzBars_LoopRestart1:
add r4,#0x48
b InitializeLaguzBars_LoopStart1

InitializeLaguzBars_LoopEnd1:

ldr r4,=#0x202CFBC @start of enemy unit structs

InitializeLaguzBars_LoopStart2:

ldr r0,[r4]
cmp r0,#0
beq InitializeLaguzBars_LoopEnd2

@get class ID
ldr r0,[r4,#4]	@r0 = pointer to class data
ldrb r0,[r0,#4]  @r0 = class ID

bl IsClassLaguz @returns true or false
cmp r0,#0
beq InitializeLaguzBars_LoopRestart2

@get char ID
ldr r0,[r4] 	@r0 = pointer to char data
ldrb r0,[r0,#4] @r0 = char ID

@add to bar starting position table offset
ldr r1,=BarStartingPositionTable
add r0,r1

ldrb r1,[r0] 	@r0 = bar starting position

mov r0,r4
bl SetLaguzBar

InitializeLaguzBars_LoopRestart2:
add r4,#0x48
b InitializeLaguzBars_LoopStart2

InitializeLaguzBars_LoopEnd2:


ldr r2,=#0x202DDCC @start of NPC unit structs

InitializeLaguzBars_LoopStart3:

ldr r0,[r4]
cmp r0,#0
beq InitializeLaguzBars_GoBack

@get class ID
ldr r0,[r4,#4]	@r0 = pointer to class data
ldrb r0,[r0,#4]  @r0 = class ID

bl IsClassLaguz @returns true or false
cmp r0,#0
beq InitializeLaguzBars_LoopRestart3

@get char ID
ldr r0,[r4] 	@r0 = pointer to char data
ldrb r0,[r0,#4] @r0 = char ID

@add to bar starting position table offset
ldr r1,=BarStartingPositionTable
add r0,r1

ldrb r1,[r0] 	@r0 = bar starting position

mov r0,r4
bl SetLaguzBar

InitializeLaguzBars_LoopRestart3:
add r4,#0x48
b InitializeLaguzBars_LoopStart3


InitializeLaguzBars_GoBack:
pop {r4}
pop {r0}
bx r0

.ltorg
.align


@ ======================================
@ ========= INIT BARS AT PREP ==========
@ ======================================

.global InitializeLaguzBarsIfPrepScreen
.type InitializeLaguzBarsIfPrepScreen, %function


InitializeLaguzBarsIfPrepScreen:
push {r4,r14}


@loop through every player character until we find an empty struct

ldr r4,=#0x202BE4C @start of player unit structs

InitializeLaguzBars2_LoopStart1:

ldr r0,[r4]
cmp r0,#0
beq InitializeLaguzBars2_LoopEnd1

@get class ID
ldr r0,[r4,#4]	@r0 = pointer to class data
ldrb r0,[r0,#4]  @r0 = class ID

bl IsClassLaguz @returns true or false
cmp r0,#0
beq InitializeLaguzBars2_LoopRestart1

@get char ID
ldr r0,[r4] 	@r0 = pointer to char data
ldrb r0,[r0,#4] @r0 = char ID

@add to bar starting position table offset
ldr r1,=BarStartingPositionTable
add r0,r1

ldrb r1,[r0] 	@r0 = bar starting position

mov r0,r4
bl SetLaguzBar

@check if unit has either skill that denotes them needing to transform here
ldr r0,=SkillTester
mov r14,r0
mov r0,r4
ldr r1,=WildheartIDLink
ldrb r1,[r1]
.short 0xF800
cmp r0,#0
bne InitializeLaguzBars2_AutotransformPlayerUnit

ldr r0,=SkillTester
mov r14,r0
mov r0,r4
ldr r1,=FormshiftIDLink
ldrb r1,[r1]
.short 0xF800
cmp r0,#0
beq InitializeLaguzBars2_LoopRestart1

InitializeLaguzBars2_AutotransformPlayerUnit:
mov r0,r4
bl LaguzTransform


InitializeLaguzBars2_LoopRestart1:
add r4,#0x48
b InitializeLaguzBars2_LoopStart1

InitializeLaguzBars2_LoopEnd1:

ldr r4,=#0x202CFBC @start of enemy unit structs

InitializeLaguzBars2_LoopStart2:

ldr r0,[r4]
cmp r0,#0
beq InitializeLaguzBars2_LoopEnd2

@get class ID
ldr r0,[r4,#4]	@r0 = pointer to class data
ldrb r0,[r0,#4]  @r0 = class ID

bl IsClassLaguz @returns true or false
cmp r0,#0
beq InitializeLaguzBars2_LoopRestart2

@get char ID
ldr r0,[r4] 	@r0 = pointer to char data
ldrb r0,[r0,#4] @r0 = char ID

@add to bar starting position table offset
ldr r1,=BarStartingPositionTable
add r0,r1

ldrb r1,[r0] 	@r0 = bar starting position

mov r0,r4
bl SetLaguzBar

InitializeLaguzBars2_LoopRestart2:
add r4,#0x48
b InitializeLaguzBars2_LoopStart2

InitializeLaguzBars2_LoopEnd2:


ldr r2,=#0x202DDCC @start of NPC unit structs

InitializeLaguzBars2_LoopStart3:

ldr r0,[r4]
cmp r0,#0
beq InitializeLaguzBars2_GoBack

@get class ID
ldr r0,[r4,#4]	@r0 = pointer to class data
ldrb r0,[r0,#4]  @r0 = class ID

bl IsClassLaguz @returns true or false
cmp r0,#0
beq InitializeLaguzBars2_LoopRestart3

@get char ID
ldr r0,[r4] 	@r0 = pointer to char data
ldrb r0,[r0,#4] @r0 = char ID

@add to bar starting position table offset
ldr r1,=BarStartingPositionTable
add r0,r1

ldrb r1,[r0] 	@r0 = bar starting position

mov r0,r4
bl SetLaguzBar


InitializeLaguzBars2_LoopRestart3:
add r4,#0x48
b InitializeLaguzBars2_LoopStart3


InitializeLaguzBars2_GoBack:
pop {r4}
pop {r0}
bx r0


.ltorg
.align

