.thumb
.align

.global ModularPreBattleSkills
.type ModularPreBattleSkills, %function




ModularPreBattleSkills:
push {r4-r7,r14}
mov r4,r0 @attacker
mov r5,r1 @defender

ldr r6,=ModularPreBattleSkillList

LoopStart:

@needs a fully blank entry to terminate, so you can have 'always applied' effects via skill ID 0
ldr r1,[r6]
cmp r1,#0
bne SkillCheck
ldr r1,[r6,#4]
cmp r1,#0
bne SkillCheck
ldr r1,[r6,#8]
bne SkillCheck
ldr r1,[r6,#12]
beq LoopExit 

@check for skill
SkillCheck:
ldrb r1,[r6]
beq LoopExit
ldr r0,=SkillTester
mov r14,r0
mov r0,r4
.short 0xF800
cmp r0,#0
beq LoopRestart

@apply effects if present
ldrb r0,[r6,#1]
cmp r0,#0
beq ApplyEffect2

mov r1,r4
add r1,#0x5A @attack
ldrh r2,[r1]
add r2,r0
strh r2,[r1]


ApplyEffect2:
ldrb r0,[r6,#2]
cmp r0,#0
beq ApplyEffect3

mov r1,r4
add r1,#0x5C @defense
ldrh r2,[r1]
add r2,r0
strh r2,[r1]

ApplyEffect3:
ldrb r0,[r6,#3]
cmp r0,#0
beq ApplyEffect4

mov r1,r4
add r1,#0x5E @AS
ldrh r2,[r1]
add r2,r0
strh r2,[r1]

ApplyEffect4:
ldrb r0,[r6,#4]
cmp r0,#0
beq ApplyEffect5

mov r1,r4
add r1,#0x60 @hit
ldrh r2,[r1]
add r2,r0
strh r2,[r1]

ApplyEffect5:
ldrb r0,[r6,#5]
cmp r0,#0
beq ApplyEffect6

mov r1,r4
add r1,#0x62 @avoid
ldrh r2,[r1]
add r2,r0
strh r2,[r1]


ApplyEffect6:
ldrb r0,[r6,#6]
cmp r0,#0
beq ApplyEffect7

mov r1,r4
add r1,#0x66 @crit
ldrh r2,[r1]
add r2,r0
strh r2,[r1]


ApplyEffect7:
ldrb r0,[r6,#7]
cmp r0,#0
beq ApplyEffect8

mov r1,r4
add r1,#0x68 @dodge
ldrh r2,[r1]
add r2,r0
strh r2,[r1]


ApplyEffect8:
ldrb r0,[r6,#8]
cmp r0,#0
beq ApplyEffect9

mov r1,r5
add r1,#0x5A @attack
ldrh r2,[r1]
add r2,r0
strh r2,[r1]


ApplyEffect9:
ldrb r0,[r6,#9]
cmp r0,#0
beq ApplyEffect10

mov r1,r5
add r1,#0x5C @defense
ldrh r2,[r1]
add r2,r0
strh r2,[r1]


ApplyEffect10:
ldrb r0,[r6,#10]
cmp r0,#0
beq ApplyEffect11

mov r1,r5
add r1,#0x5E @AS
ldrh r2,[r1]
add r2,r0
strh r2,[r1]

ApplyEffect11:
ldrb r0,[r6,#11]
cmp r0,#0
beq ApplyEffect12

mov r1,r5
add r1,#0x60 @hit
ldrh r2,[r1]
add r2,r0
strh r2,[r1]

ApplyEffect12:
ldrb r0,[r6,#12]
cmp r0,#0
beq ApplyEffect13

mov r1,r5
add r1,#0x62 @avoid
ldrh r2,[r1]
add r2,r0
strh r2,[r1]

ApplyEffect13:
ldrb r0,[r6,#13]
cmp r0,#0
beq ApplyEffect14

mov r1,r5
add r1,#0x66 @crit
ldrh r2,[r1]
add r2,r0
strh r2,[r1]

ApplyEffect14:
ldrb r0,[r6,#14]
cmp r0,#0
beq LoopRestart

mov r1,r5
add r1,#0x68 @dodge
ldrh r2,[r1]
add r2,r0
strh r2,[r1]

LoopRestart:
add r6,#16
b LoopStart




LoopExit:
pop {r4-r7}
pop {r0}
bx r0

.ltorg
.align





