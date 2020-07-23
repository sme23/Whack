.thumb
.align

.include "LaguzBars_Defs.s"

@ =================================
@ ========== STAT BOOSTS ==========
@ =================================


.global TransformationStatBoostCheck
.type TransformationStatBoostCheck, %function

.global Str_TransformBoost
.type Str_TransformBoost, %function

.global Skl_TransformBoost
.type Skl_TransformBoost, %function

.global Spd_TransformBoost
.type Spd_TransformBoost, %function

.global Def_TransformBoost
.type Def_TransformBoost, %function

.global Res_TransformBoost
.type Res_TransformBoost, %function

.global Con_TransformBoost
.type Con_TransformBoost, %function

.global Mov_TransformBoost
.type Mov_TransformBoost, %function

.global Mag_TransformBoost
.type Mag_TransformBoost, %function





TransformationStatBoostCheck:
@r0 = unit struct, r1 = stat index

push {r4-r7,r14}
mov r4,r0 @r4 = unit struct
mov r5,r1 @r5 = stat index

mov r0,r4
bl IsLaguzTransformed
cmp r0,#0
beq TransformationStatBoostCheck_RetFalse

ldr r0,=TransformationStatBoostTable
ldr r1,[r4,#4]
ldrb r1,[r1,#4]
mov r2,#8
mul r1,r2
add r0,r1
add r0,r5
ldrb r0,[r0]

mov r6,r0
@do we have Wildheart?

ldr r0,=SkillTester
mov r14,r0
mov r0,r4
ldr r1,=WildheartIDLink
ldrb r1,[r1]
.short 0xF800
cmp r0,#0
beq TransformationStatBoostCheck_DontHalveBonus
lsr r6,r6,#1 @/2

TransformationStatBoostCheck_DontHalveBonus:
mov r0,r6
b TransformationStatBoostCheck_GoBack

TransformationStatBoostCheck_RetFalse:
mov r0,#0
 
TransformationStatBoostCheck_GoBack:
pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align




Str_TransformBoost:
push {r4-r7,r14}
mov r4,r1 @unit
mov r5,r0 @stat

mov r0,r4
mov r1,#0 @stat index

bl TransformationStatBoostCheck
add r5,r0

Str_TransformBoost_GoBack:
mov r1,r4
mov r0,r5

pop {r4-r7}
pop {r2}
bx r2

.ltorg
.align


Skl_TransformBoost:
push {r4-r7,r14}
mov r4,r1 @unit
mov r5,r0 @stat

mov r0,r4
mov r1,#1 @stat index

bl TransformationStatBoostCheck
add r5,r0


Skl_TransformBoost_GoBack:
mov r1,r4
mov r0,r5

pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align


Spd_TransformBoost:
push {r4-r7,r14}
mov r4,r1 @unit
mov r5,r0 @stat

mov r0,r4
mov r1,#2 @stat index

bl TransformationStatBoostCheck
add r5,r0


Spd_TransformBoost_GoBack:
mov r1,r4
mov r0,r5

pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align


Def_TransformBoost:
push {r4-r7,r14}
mov r4,r1 @unit
mov r5,r0 @stat

mov r0,r4
mov r1,#3 @stat index

bl TransformationStatBoostCheck
add r5,r0


Def_TransformBoost_GoBack:
mov r1,r4
mov r0,r5

pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align


Res_TransformBoost:
push {r4-r7,r14}
mov r4,r1 @unit
mov r5,r0 @stat

mov r0,r4
mov r1,#4 @stat index

bl TransformationStatBoostCheck
add r5,r0


Res_TransformBoost_GoBack:
mov r1,r4
mov r0,r5

pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align


Con_TransformBoost:
push {r4-r7,r14}
mov r4,r1 @unit
mov r5,r0 @stat

mov r0,r4
mov r1,#5 @stat index

bl TransformationStatBoostCheck
add r5,r0


Con_TransformBoost_GoBack:
mov r1,r4
mov r0,r5

pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align


Mov_TransformBoost:
push {r4-r7,r14}
mov r4,r1 @unit
mov r5,r0 @stat

mov r0,r4
mov r1,#6 @stat index

bl TransformationStatBoostCheck
add r5,r0


Mov_TransformBoost_GoBack:
mov r1,r4
mov r0,r5

pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align


Mag_TransformBoost:
push {r4-r7,r14}
mov r4,r1 @unit
mov r5,r0 @stat

mov r0,r4
mov r1,#7 @stat index

bl TransformationStatBoostCheck
add r5,r0


Mag_TransformBoost_GoBack:
mov r1,r4
mov r0,r5

pop {r4-r7}
pop {r1}
bx r1

.ltorg
.align


