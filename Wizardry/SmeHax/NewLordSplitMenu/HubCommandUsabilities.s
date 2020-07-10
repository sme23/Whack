.thumb
.align

@certain commands are not to be selectable before certain requirements are met
@namely, having beaten other chapters and setting specific global flags
@going to need a set of ID links on the flag IDs as they're definitions at the moment


.global CommandUsability_ManaketeMayhem
.type CommandUsability_ManaketeMayhem, %function

.global CommandEffect_ManaketeMayhem
.type CommandEffect_ManaketeMayhem, %function

.global CommandUsability_BloodFeud
.type CommandUsability_BloodFeud, %function

.global CommandEffect_BloodFeud
.type CommandEffect_BloodFeud, %function

.global CommandUsability_MiniThracia
.type CommandUsability_MiniThracia, %function

.global CommandEffect_MiniThracia
.type CommandEffect_MiniThracia, %function

.global CommandUsability_DemonBlood
.type CommandUsability_DemonBlood, %function

.global CommandEffect_DemonBlood
.type CommandEffect_DemonBlood, %function

.global CommandUsability_AceAttorney
.type CommandUsability_AceAttorney, %function

.global CommandEffect_AceAttorney
.type CommandEffect_AceAttorney, %function

.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.equ CheckEventId,0x8083da8


CommandUsability_ManaketeMayhem:
push {r14}

@check if relevant flags are set to access this scenario

ldr r0,=SkirmishInGalliaBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
bne ManaketeMayhem_RetTrue

mov r0,#2 @returns greyed out if flag is not set
b ManaketeMayhem_GoBack

ManaketeMayhem_RetTrue:
mov r0,#1

ManaketeMayhem_GoBack:
pop {r1}
bx r1

.ltorg
.align

CommandEffect_ManaketeMayhem:
push {r4-r5,r14}

mov r4,r1 @need this for later
mov r5,r0 @also need this for later

@check if relevant flags are set to access this scenario
ldr r0,=SkirmishInGalliaBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
bne ManaketeMayhem_CallEffect

ldr r1,=LockedScenarioText_ManaketeMayhemIDLink
ldrh r1,[r1]
mov r0,r5
ldr r2,=#0x0804F580 @ Sets that text ID for the error text
mov r14,r2
.short 0xF800
mov r0,#0x8
b ManaketeMayhem_GoBack2

.ltorg
.align

ManaketeMayhem_CallEffect:
mov r1,r4
bl prEventMenuCommandEffect


ManaketeMayhem_GoBack2:
pop {r4-r5}
pop {r1}
bx r1

.ltorg
.align





CommandUsability_BloodFeud:
push {r14}

@check if relevant flags are set to access this scenario

ldr r0,=FatedRevelationsBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
bne BloodFeud_RetTrue

mov r0,#2 @returns greyed out if flag is not set
b BloodFeud_GoBack

BloodFeud_RetTrue:
mov r0,#1

BloodFeud_GoBack:
pop {r1}
bx r1

.ltorg
.align

CommandEffect_BloodFeud:
push {r4-r5,r14}

mov r4,r1 @need this for later
mov r5,r0 @also need this for later

@check if relevant flags are set to access this scenario
ldr r0,=FatedRevelationsBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
bne BloodFeud_CallEffect

ldr r1,=LockedScenarioText_BloodFeudIDLink
ldrh r1,[r1]
mov r0,r5
ldr r2,=#0x0804F580 @ Sets that text ID for the error text
mov r14,r2
.short 0xF800
mov r0,#0x8
b BloodFeud_GoBack2

.ltorg
.align

BloodFeud_CallEffect:
mov r1,r4
bl prEventMenuCommandEffect


BloodFeud_GoBack2:
pop {r4-r5}
pop {r1}
bx r1

.ltorg
.align



CommandUsability_MiniThracia:
push {r14}

@check if relevant flags are set to access this scenario

ldr r0,=FatedRevelationsBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
bne MiniThracia_RetTrue

mov r0,#2 @returns greyed out if flag is not set
b MiniThracia_GoBack

MiniThracia_RetTrue:
mov r0,#1

MiniThracia_GoBack:
pop {r1}
bx r1

.ltorg
.align

CommandEffect_MiniThracia:
push {r4-r5,r14}

mov r4,r1 @need this for later
mov r5,r0 @also need this for later

@check if relevant flags are set to access this scenario
ldr r0,=FatedRevelationsBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
bne MiniThracia_CallEffect

ldr r1,=LockedScenarioText_MiniThraciaIDLink
ldrh r1,[r1]
mov r0,r5
ldr r2,=#0x0804F580 @ Sets that text ID for the error text
mov r14,r2
.short 0xF800
mov r0,#0x8
b MiniThracia_GoBack2

.ltorg
.align

MiniThracia_CallEffect:
mov r1,r4
bl prEventMenuCommandEffect


MiniThracia_GoBack2:
pop {r4-r5}
pop {r1}
bx r1

.ltorg
.align



CommandUsability_DemonBlood:
push {r14}

@check if relevant flags are set to access this scenario

ldr r0,=ManaketeMayhemBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
beq DemonBlood_RetGrey
ldr r0,=StatusSanctuaryBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
beq DemonBlood_RetGrey
ldr r0,=FromTheDarknessBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
beq DemonBlood_RetGrey
ldr r0,=MerchantMadnessBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
bne DemonBlood_RetTrue


DemonBlood_RetGrey:
mov r0,#2 @returns greyed out if flag is not set
b DemonBlood_GoBack

DemonBlood_RetTrue:
mov r0,#1

DemonBlood_GoBack:
pop {r1}
bx r1

.ltorg
.align

CommandEffect_DemonBlood:
push {r4-r5,r14}

mov r4,r1 @need this for later
mov r5,r0 @also need this for later

@check if relevant flags are set to access this scenario
ldr r0,=ManaketeMayhemBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
beq DemonBlood_DoLockedText
ldr r0,=StatusSanctuaryBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
beq DemonBlood_DoLockedText
ldr r0,=FromTheDarknessBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
beq DemonBlood_DoLockedText
ldr r0,=MerchantMadnessBeatenFlagIDLink
ldrh r0,[r0]
blh CheckEventId
cmp r0,#0
bne DemonBlood_CallEffect

DemonBlood_DoLockedText:

ldr r1,=LockedScenarioText_DemonBloodIDLink
ldrh r1,[r1]
mov r0,r5
ldr r2,=#0x0804F580 @ Sets that text ID for the error text
mov r14,r2
.short 0xF800
mov r0,#0x8
b DemonBlood_GoBack2

.ltorg
.align

DemonBlood_CallEffect:
mov r1,r4
bl prEventMenuCommandEffect


DemonBlood_GoBack2:
pop {r4-r5}
pop {r1}
bx r1

.ltorg
.align



CommandUsability_AceAttorney:
push {r14}

AceAttorney_RetTrue:
mov r0,#1

AceAttorney_GoBack:
pop {r1}
bx r1

.ltorg
.align

CommandEffect_AceAttorney:
push {r4-r5,r14}

mov r4,r1 @need this for later
mov r5,r0 @also need this for later


mov r1,r4
bl prEventMenuCommandEffect


AceAttorney_GoBack2:
pop {r4-r5}
pop {r1}
bx r1

.ltorg
.align



