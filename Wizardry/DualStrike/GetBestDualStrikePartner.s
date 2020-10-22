.thumb
.align

.equ UnitBuffer, 0x203ED40 // 0x203EFB8 normally
.equ Map_Offset, 0x202E4D8
.equ GetUnit, 0x8019430

.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.global GetBestDualStrikePartner
.type GetBestDualStrikePartner, %function

.global GetUnitAt
.type GetUnitAt, %function

.global CopyToUnitBuffer
.type CopyToUnitBuffer, %function

.global CheckSameAllegiance
.type CheckSameAllegiance, %function

.global CheckDamageDealt
.type CheckDamageDealt, %function



GetBestDualStrikePartner:

// Input 
// r0 - attacker
// r1 - defender

// Output 
// r0 - unit struct of most damaging DS partner (0 if none)
// r1 - damage dealt by most damaging DS partner (0 if none)

push {r4-r7,lr}

// r4 - attacker
// r5 - defender
// r6 - current best canditate
// r7 - current best canditates damage dealt

mov r4, r0
mov r5, r1
mov r6, #0x0
mov r7, #0x0

@ Unit Above
ldrb r0, [r4, #0x10]
ldrb r1, [r4, #0x11]
cmp r1, #0x0
beq UnitRight  // at top of map
sub r1, #1 // 1 tile above
blh GetUnitAt
cmp r0, #0x0
beq UnitRight

push {r0}
mov r1, r4
blh CheckSameAllegiance
mov r1, r0
pop {r0}
cmp r1, #0x0
beq UnitRight

push {r0}
mov r1, r5
blh CheckDamageDealt
mov r1, r0
pop {r0}
cmp r1, r7
blt UnitRight
mov r6, r0
mov r7, r1

UnitRight:
ldrb r0, [r4, #0x10]
ldrb r1, [r4, #0x11]
add r0, #1 // 1 tile right
blh GetUnitAt
cmp r0, #0x0
beq UnitBelow

push {r0}
mov r1, r4
blh CheckSameAllegiance
mov r1, r0
pop {r0}
cmp r1, #0x0
beq UnitBelow

push {r0}
mov r1, r5
blh CheckDamageDealt
mov r1, r0
pop {r0}
cmp r1, r7
blt UnitBelow
mov r6, r0
mov r7, r1

UnitBelow:
ldrb r0, [r4, #0x10]
ldrb r1, [r4, #0x11]
add r1, #1 // 1 tile below
blh GetUnitAt
cmp r0, #0x0
beq UnitLeft

push {r0}
mov r1, r4
blh CheckSameAllegiance
mov r1, r0
pop {r0}
cmp r1, #0x0
beq UnitLeft

push {r0}
mov r1, r5
blh CheckDamageDealt
mov r1, r0
pop {r0}
cmp r1, r7
blt UnitLeft
mov r6, r0
mov r7, r1

UnitLeft:
ldrb r0, [r4, #0x10]
ldrb r1, [r4, #0x11]
cmp r0, #0x0
beq End // at left edge of map
sub r0, #1 // 1 tile left
blh GetUnitAt
cmp r0, #0x0
beq End

push {r0}
mov r1, r4
blh CheckSameAllegiance
mov r1, r0
pop {r0}
cmp r1, #0x0
beq End

push {r0}
mov r1, r5
blh CheckDamageDealt
mov r1, r0
pop {r0}
cmp r1, r7
blt End
mov r6, r0
mov r7, r1

End:
mov r0, r6
mov r1, r7
pop {r4-r7}
pop {r2}
bx r2

.ltorg
.align



CopyToUnitBuffer:

// Input
// r0 - Unit
// r1 - true if not at +0x7F

push {r4,lr}

mov r4, r0
ldr r0, =UnitBuffer
cmp r1, #0x0
bne DoNotAddCopyToUnitBuffer
add r0, #0x80
DoNotAddCopyToUnitBuffer:
mov r1, #0x0

// r0 - UnitBuffer Location
// r1 - Current offset
// r4 - Unit struct

CopyToUnitBufferLoop:
ldrb r2, [r4, r1]
strb r2, [r0, r1]
add r1, #1
cmp r1, #0x47 // struct length
bgt EndCopyToUnitBufferLoop
b CopyToUnitBufferLoop

EndCopyToUnitBufferLoop:
pop {r4}
pop {r0}
bx r0

.ltorg
.align



GetUnitAt:

// Input
// r0 - x
// r1 - y

// Ouput
// r0 - unit struct

push {lr}

ldr		r2,=Map_Offset	@Load the location in the table of tables of the map you want
ldr		r2,[r2]			@Offset of maps table of row pointers
lsl		r1,#0x2			@multiply y coordinate by 4
add		r2,r1			@so that we can get the correct row pointer
ldr		r2,[r2]			@Now were at the beginning of the row data
add		r2,r0			@add x coordinate
ldrb	r0,[r2]			@load datum at those coordinates
blh 	GetUnit

pop {r1}
bx r1

.ltorg
.align



CheckSameAllegiance:

// Input
// r0 - unit struct 1
// r1 - unit struct 2

// Ouput
// r0 - true if allied

push {lr}

ldrb r2, [r0, #0xB] // deployment (alleg in top 2 bits)
lsr r2, #0x6
ldrb r3, [r1, #0xB]
lsr r3, #0x6
cmp r2, r3
bne RetFalseCheckSameAllegiance
mov r0, #0x1
b EndCheckAllegiance

RetFalseCheckSameAllegiance:
mov r0, #0x0
EndCheckAllegiance:
pop {r1}
bx r1

.ltorg
.align



CheckDamageDealt:

// Input
// r0 - unit struct 1
// r1 - unit struct 2

// Ouput
// r0 - damage 1 deals to 2

push {r4,r5,lr}

push {r1}
mov r1, #0x1
blh CopyToUnitBuffer
pop {r1}

mov r0, r1
mov r1, #0x0
blh CopyToUnitBuffer

ldr r0, =UnitBuffer
mov r1, r0
add r1, #0x80

blh BtlLoopParent // calculate stuff in unit buffer

ldr r1, =UnitBuffer
add r1, #0x5A
ldrh r0, [r1] //atk

add r1, #0x80
add r1, #0x2
ldrh r1, [r1] //def

cmp r1, r0
bge RetZeroCheckDamageDealt
sub r0, r1
b EndCheckDamageDealt

RetZeroCheckDamageDealt:
mov r0, #0x0
EndCheckDamageDealt:
pop {r4,r5}
pop {r1}
bx r1

.ltorg
.align
