.thumb
.align

.global CurrentTestimonyGetter
.type CurrentTestimonyGetter, %function

.global TestimonyCommandUsability
.type TestimonyCommandUsability, %function

.global PressEffect
.type PressEffect, %function

.global PresentEffect
.type PresentEffect, %function

.global HearEffect
.type HearEffect, %function

.global ConsultUsability
.type ConsultUsability, %function

.global SetCurrentTestimonyASMC
.type SetCurrentTestimonyASMC, %function

.global CurrentStatementGetter
.type CurrentStatementGetter, %function

.global GetRelevantEventPointer
.type GetRelevantEventPointer, %function

.global TalkUsability
.type TalkUsability, %function

.global AlmNeverStopsMoving
.type AlmNeverStopsMoving, %function

.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.equ GetUnit,0x8019430
.equ EventStart,0x800D07C
.equ VanillaTalkUsability,0x8023C80
.equ MemorySlot2,0x30004C0
.equ ClearActiveUnit,0x801d75c  
.equ gActiveUnit, 0x3004E50


@we could use flags for this but that's boring
@the first entry of the debuff table always goes unused and is saved through suspendso we can poke at there
@use a byte to save current testimony ID
@then we can set to each table values indexed by current testimony ID
@value gets initialized to 0 so first testimony is ID 0


CurrentTestimonyGetter:
ldr r0,=#0x203F106 @random, otherwise unused byte in unused 0th entry of debuff table to use for this
ldrb r0,[r0]
bx r14

.ltorg
.align


SetCurrentTestimonyASMC:
ldr r1,=MemorySlot2
ldr r1,[r1]
ldr r0,=#0x203F106
strb r1,[r0]
bx r14

.ltorg
.align


CurrentStatementGetter:
push {r14}
@what unit is at active unit's (x,y-1)
ldr r0,=#0x3004E50
ldr r1,[r0]
ldrb r0,[r1,#0x10]
ldrb r1,[r1,#0x11]
sub r1,#1

ldr r2,=#0x202E4D8
ldr r2,[r2]
lsl r1,#2
add r2,r1
ldr r2,[r2]
add r2,r0
ldrb r0,[r2]
blh GetUnit

ldr r0,[r0]
ldrb r0,[r0,#4]
mov r1,#209
cmp r0,r1
blt CurrentStatementGetter_ReturnInvalid
sub r0,r1
b CurrentStatementGetter_GoBack

CurrentStatementGetter_ReturnInvalid:
mov r0,#0xFF

CurrentStatementGetter_GoBack:
pop {r1}
bx r1

.ltorg
.align


GetRelevantEventPointer: @r0 = pointer to table to index
push {r4-r5,r14}
mov r4,r0
bl CurrentTestimonyGetter
mov r5,r0
bl CurrentStatementGetter
mov r3,r0
lsl r0,r5,#5 @32-byte entries
add r0,r4
lsl r1,r3,#2 @*4
add r0,r1
ldr r0,[r0]
pop {r4-r5}
pop {r1}
bx r1

.ltorg
.align




TestimonyCommandUsability:
push {r14}

@see if there is a current statement
bl CurrentStatementGetter
cmp r0,#0xFF
beq TestimonyCommandUsability_RetFalse
mov r0,#1
b TestimonyCommandUsability_GoBack

TestimonyCommandUsability_RetFalse:
mov r0,#3

TestimonyCommandUsability_GoBack:
pop {r1}
bx r1

.ltorg
.align

PressEffect:
push {r4,r14}
@call Wait effect lol
ldr r0,=#0x8022739
mov r14,r0
.short 0xF800

@get press event ptr for current testimony & statement
ldr r0,=PressEventPointerTable
bl GetRelevantEventPointer
@run event
mov r1,#2
blh EventStart

mov r0,#0x94
pop {r4}
pop {r1}
bx r1

.ltorg
.align


PresentEffect:
push {r14}
@get press event ptr for current testimony & statement
ldr r0,=PresentEventPointerTable
bl GetRelevantEventPointer
@run event
mov r1,#2
blh EventStart
mov r0,#0x94
pop {r1}
bx r1

.ltorg
.align


HearEffect:
push {r14}
@get press event ptr for current testimony & statement
ldr r0,=HearEventPointerTable
bl GetRelevantEventPointer
@run event
mov r1,#1
blh EventStart
mov r0,#0x94
pop {r1}
bx r1

.ltorg
.align


TalkUsability:
@ban Talk from AA chapter in favor of Consult
push {r14}
ldr r0,=#0x202BCF0
ldrb r0,[r0,#0xE]

ldr r1,=AceAttorneyChIDLink
ldrb r1,[r1]
cmp r0,r1
beq TalkUsability_RetFalse
blh VanillaTalkUsability
b TalkUsability_GoBack

TalkUsability_RetFalse:
mov r0,#3

TalkUsability_GoBack:
pop {r1}
bx r1
.ltorg
.align


ConsultUsability:
@Talk usability but an extra check for being in the right chapter
push {r14}
ldr r0,=#0x202BCF0
ldrb r0,[r0,#0xE]

ldr r1,=AceAttorneyChIDLink
ldrb r1,[r1]
cmp r0,r1
bne ConsultUsability_RetFalse
blh VanillaTalkUsability
b ConsultUsability_GoBack

ConsultUsability_RetFalse:
mov r0,#3

ConsultUsability_GoBack:
pop {r1}
bx r1

.ltorg
.align



AlmNeverStopsMoving:
bx r14

.ltorg
.align


.global StopTheThingAAAAA
.type StopTheThingAAAAA, %function

StopTheThingAAAAA:
@make the active unit visible
push {r4,r14}
ldr r0,=gActiveUnit
ldr r4,[r0]

ldr r1,[r4,#0xC]
mov r0,#0x4B
neg r0,r0
and r1,r0
str r1,[r4,#0xC]

pop {r4}
pop {r0}
bx r0

.ltorg
.align


.global TheOTherStopAAAAAAAAAAA
.type TheOTherStopAAAAAAAAAAA, %function

TheOTherStopAAAAAAAAAAA:
@make the active unit invisible again
push {r4,r14}
ldr r0,=gActiveUnit
ldr r4,[r0]

ldr r1,[r4,#0xC]
mov r0,#0x4B
orr r1,r0
str r1,[r4,#0xC]

pop {r4}
pop {r0}
bx r0

.ltorg
.align





