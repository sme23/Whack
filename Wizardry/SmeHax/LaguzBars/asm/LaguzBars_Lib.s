.thumb
.align

.include "LaguzBars_Defs.s"

@general library functions

@ ===========================================
@ ========== GENERAL USE FUNCTIONS ==========
@ ===========================================

.global IsClassLaguz
.type IsClassLaguz, %function

.global IsLaguzTransformed
.type IsLaguzTransformed, %function

.global GetLaguzBar
.type GetLaguzBar, %function

.global SetLaguzBar
.type SetLaguzBar, %function

.global GetBarTurnGain
.type GetBarTurnGain, %function

.global GetBarTurnLoss
.type GetBarTurnLoss, %function

.global GetBarBattleGain
.type GetBarBattleGain, %function

.global GetBarBattleLoss
.type GetBarBattleLoss, %function

.global GetTransformedClass
.type GetTransformedClass, %function

.global ToggleLaguzTransformed
.type ToggleLaguzTransformed, %function

.global LaguzUntransform
.type LaguzUntransform, %function

.global LaguzTransform
.type LaguzTransform, %function



IsClassLaguz: @r0 = class ID

ldr r2,=LaguzClassList

IsClassLaguz_LoopStart:
ldrb r1,[r2]
cmp r1,#0
beq IsClassLaguz_RetFalse
cmp r1,r0
beq IsClassLaguz_RetTrue
add r2,#1
b IsClassLaguz_LoopStart

IsClassLaguz_RetTrue:
mov r0,#1
b IsClassLaguz_GoBack

IsClassLaguz_RetFalse:
mov r0,#0

IsClassLaguz_GoBack:
bx r14

.ltorg
.align





IsLaguzTransformed: @r0 = unit pointer

push {r4,r14}
mov r4,r0

@check if unit's class is laguz
ldr r0,[r4,#4]
ldrb r0,[r0,#4]

bl IsClassLaguz
cmp r0,#0
beq IsLaguzTransformed_RetNotLaguz


ldrb r0,[r4,#0xB] 	@allegiance byte
mov r1,#0x8 		@size of debuff table entry
mul r0,r1
ldr r1,=DebuffTableLink
ldr r1,[r1]
add r1,r0
ldrb r0,[r1,#6] 	@our byte

lsl r0,r0,#25
lsr r0,r0,#31		@r0 = transformed bool

cmp r0,#0
beq IsLaguzTransformed_GoBack
mov r0,#1
b IsLaguzTransformed_GoBack

IsLaguzTransformed_RetFalse:
mov r0,#0
b IsLaguzTransformed_GoBack

IsLaguzTransformed_RetNotLaguz:
mov r0,#2

IsLaguzTransformed_GoBack:
pop {r4}
pop {r1}
bx r1

.ltorg
.align





GetLaguzBar: @r0 = unit struct

push {r4,r14}
mov r4,r0

@first, see if we are a laguz class

ldr r0,[r4,#4]
ldrb r0,[r0,#4]

bl IsClassLaguz
cmp r0,#0
beq GetLaguzBar_ReturnNil

@we are laguz!

@check for skills
@ldr r0,=SkillTester
@mov r14,r0
@mov r0,r4
@ldr r1,=WildheartIDLink
@ldrb r1,[r1]
@.short 0xF800
@cmp r0,#0
@bne GetLaguzBar_AlwaysFull

@ldr r0,=SkillTester
@mov r14,r0
@mov r0,r4
@ldr r1,=FormshiftIDLink
@ldrb r1,[r1]
@.short 0xF800
@cmp r0,#0
@beq GetLaguzBar_NoSkills

@GetLaguzBar_AlwaysFull:
@mov r0,#30
@b GetLaguzBar_GoBack


GetLaguzBar_NoSkills:
@get the external data byte

ldrb r0,[r4,#0xB] 	@allegiance byte
mov r1,#0x8 		@size of debuff table entry
mul r0,r1
ldr r1,=DebuffTableLink
ldr r1,[r1]
add r1,r0
ldrb r0,[r1,#6] 	@our byte

mov r1,#0x3F
and r0,r1 			@r0 = just the bar

b GetLaguzBar_GoBack

GetLaguzBar_ReturnNil:
mov r0,#0

GetLaguzBar_GoBack:
pop {r4}
pop {r1}
bx r1

.ltorg
.align



 


SetLaguzBar: @r0 = unit struct, r1 = new value

push {r4-r5,r14}
mov r4,r0
mov r5,r1

@bounds check input
cmp r5,#30
ble SetLaguzBar_AreWeGood
mov r5,#30

SetLaguzBar_AreWeGood: @if our new value is <0 we should force-untransform, if possible
cmp r5,#0
bge SetLaguzBar_WeGood
mov r5,#0
mov r0,r4
bl LaguzUntransform

SetLaguzBar_WeGood:

@first, see if we are a laguz class

ldr r0,[r4,#4]
ldrb r0,[r0,#4]

bl IsClassLaguz
cmp r0,#0
beq SetLaguzBar_GoBack

@do we have Wildheart or Formshift?
@ldr r0,=SkillTester
@mov r14,r0
@mov r0,r4
@ldr r1,=WildheartIDLink
@ldrb r1,[r1]
@.short 0xF800
@cmp r0,#0
@bne SetLaguzBar_BarAlwaysFull

@ldr r0,=SkillTester
@mov r14,r0
@mov r0,r4
@ldr r1,=FormshiftIDLink
@ldrb r1,[r1]
@.short 0xF800
@cmp r0,#0
@beq SetLaguzBar_NoSkills

@SetLaguzBar_BarAlwaysFull:
@mov r5,#30
@b SetLaguzBar_SetBarValue


SetLaguzBar_NoSkills:
ldrb r0,[r4,#0xB] 	@allegiance byte
mov r1,#0x8 		@size of debuff table entry
mul r0,r1
ldr r1,=DebuffTableLink
ldr r1,[r1]
add r1,r0
ldrb r0,[r1,#6] 	@our byte


SetLaguzBar_SetBarValue:
mov r2,#0xC0
and r0,r2 			@r0 = the part of the byte that's not the bar

orr r0,r5			@r0 = the byte with the new bar value
strb r0,[r1,#6]		@store the byte

SetLaguzBar_GoBack:
pop {r4-r5}
pop {r0}
bx r0

.ltorg
.align



GetBarTurnGain: @r0 = unit struct
push {r4,r14}
mov r4,r0

@get class ID
ldr r0,[r4,#4]
ldrb r0,[r0,#4] 	@r0 = class ID

lsl r0,r0,#2 @*4

ldr r1,=TransformationSpeedTable
add r1,r0
ldrb r0,[r1]

pop {r4}
pop {r1}
bx r1

.ltorg
.align




GetBarTurnLoss: @r0 = unit struct
push {r4,r14}
mov r4,r0

@get class ID
ldr r0,[r4,#4]
ldrb r0,[r0,#4] 	@r0 = class ID

lsl r0,r0,#2 @*4

ldr r1,=TransformationSpeedTable
add r1,r0
ldrb r0,[r1,#2]

pop {r4}
pop {r1}
bx r1

.ltorg
.align



GetBarBattleGain: @r0 = unit struct
push {r4,r14}
mov r4,r0

@get class ID
ldr r0,[r4,#4]
ldrb r0,[r0,#4] 	@r0 = class ID

lsl r0,r0,#2 @*4

ldr r1,=TransformationSpeedTable
add r1,r0
ldrb r0,[r1,#1]

pop {r4}
pop {r1}
bx r1

.ltorg
.align



GetBarBattleLoss: @r0 = unit struct
push {r4,r14}
mov r4,r0

@get class ID
ldr r0,[r4,#4]
ldrb r0,[r0,#4] 	@r0 = class ID

lsl r0,r0,#2 @*4

ldr r1,=TransformationSpeedTable
add r1,r0
ldrb r0,[r1,#3]

pop {r4}
pop {r1}
bx r1

.ltorg
.align



GetTransformedClass: @r0 = unit struct
push {r4,r14}
mov r4,r0

@we want to loop through the laguz class list
@but only checking every second byte
@then when we find a match return [current list pos +1] 

ldr r3,=LaguzClassList
ldr r2,[r4,#4]
ldrb r2,[r2,#4]

GetTransformedClass_LoopStart:
ldrb r1,[r3]
cmp r1,#0
beq GetTransformedClass_RetNoClass
cmp r1,r2
beq GetTransformedClass_LoopExit

GetTransformedClass_LoopRestart:
add r3,#2
b GetTransformedClass_LoopStart


GetTransformedClass_LoopExit:
ldrb r0,[r3,#1]
b GetTransformedClass_GoBack

GetTransformedClass_RetNoClass:
mov r0,#0

GetTransformedClass_GoBack:
pop {r4}
pop {r1}
bx r1

.ltorg
.align



ToggleLaguzTransformed: @r0 = unit struct
push {r4,r14}
mov r4,r0

@check if unit's class is laguz
ldr r0,[r4,#4]
ldrb r0,[r0,#4]

bl IsClassLaguz
cmp r0,#0
beq ToggleLaguzTransformed_GoBack


ldrb r0,[r4,#0xB] 	@allegiance byte
mov r1,#0x8 		@size of debuff table entry
mul r0,r1
ldr r1,=DebuffTableLink
ldr r1,[r1]
add r1,r0
ldrb r0,[r1,#6] 	@our byte

mov r2,#0x40 @bit to check
and r0,r2
cmp r0,#0
beq ToggleLaguzTransformed_NotTransformed

ldrb r0,[r1,#6]
mov r2,#0xBF
and r0,r2

b ToggleLaguzTransformed_GoBack


ToggleLaguzTransformed_NotTransformed:
ldrb r0,[r1,#6]
orr r0,r2

ToggleLaguzTransformed_GoBack:
strb r0,[r1,#6]
pop {r4}
pop {r0}
bx r0

.ltorg
.align






LaguzUntransform: @r0 = unit struct
push {r4,r14}
mov r4,r0

@find untransformed class
ldr r0,[r4,#4]
ldrb r2,[r0,#4]

ldr r3,=LaguzClassList
add r3,#1

LaguzUntransform_LoopStart:
ldrb r1,[r3]
cmp r1,#0
beq LaguzUntransform_GoBack
cmp r1,r2
beq LaguzUntransform_LoopExit

add r3,#2
b LaguzUntransform_LoopStart


LaguzUntransform_LoopExit:
@r3 = [address of class ID] + 1
sub r3,#1
ldrb r1,[r3]
@r1 = class ID
mov r0,#84 @size of class table entry
mul r0,r1
ldr r1,=ClassTable
add r0,r1
str r0,[r4,#4] @class = untransformed class

@toggle transformed bit
mov r0,r4
bl ToggleLaguzTransformed

@do fancy animation here

LaguzUntransform_GoBack:
pop {r4}
pop {r0}
bx r0

.ltorg
.align






LaguzTransform: @r0 = unit struct
push {r4,r14}
mov r4,r0

ldr r0,[r4,#4]
ldrb r2,[r0,#4]

ldr r3,=LaguzClassList

LaguzTransform_LoopStart:
ldrb r1,[r3]
cmp r1,#0
beq LaguzTransform_GoBack
cmp r1,r2
beq LaguzTransform_LoopExit

add r3,#2
b LaguzTransform_LoopStart


LaguzTransform_LoopExit:
@r3 = [address of class ID] - 1
add r3,#1
ldrb r1,[r3]
@r1 = class ID
mov r0,#84 @size of class table entry
mul r0,r1
ldr r1,=ClassTable
add r0,r1
str r0,[r4,#4] @class = untransformed class

@toggle transformed bit
mov r0,r4
bl ToggleLaguzTransformed

@do fancy animation here

LaguzTransform_GoBack:
pop {r4}
pop {r0}
bx r0

.ltorg
.align
