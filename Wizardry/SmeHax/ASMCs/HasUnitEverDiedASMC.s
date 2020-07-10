.thumb
.align

.global HasUnitEverDiedASMC
.type HasUnitEverDiedASMC, %function

.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.equ MemorySlot1,0x30004BC
.equ MemorySlotC,0x30004E8
.equ GetUnitStructFromEventParameter,0x800BC50
.equ BWL_GetEntry,0x80A4CFC


HasUnitEverDiedASMC: 
push {r14}

@memory slot 1 = char ID
ldr r0,=MemorySlot1
ldrh r0,[r0]

blh GetUnitStructFromEventParameter

ldr r0,[r0]
ldrb r0,[r0,#4]

@get their BWL data
blh BWL_GetEntry

ldrb r0,[r0] @the very first piece of BWL data is losses
ldr r1,=MemorySlotC
str r0,[r1]

pop {r0}
bx r0

.ltorg
.align

