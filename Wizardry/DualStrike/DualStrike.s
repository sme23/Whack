.thumb
.align

.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.global DualStrike
.type DualStrike, %function



DualStrike:

// Input
// r4 - attacker
// r5 - defender

push {r4-r7, lr}

// Check both for pair up
ldrb r0, [r4, #0x1b] // rescuee allegiance byte
cmp r0, #0x0
bne End
ldrb r0, [r5, #0x1b] // rescuee allegiance byte
cmp r0, #0x0
bne End

// Add DS Bonus to attacker
mov r0, r4
mov r1, r5
blh GetBestDualStrikePartner
add r4, #0x5A //atk
ldrb r0, [r4]
add r0, r1
strh r0, [r4] 

End:
pop {r4-r7, r15}

.ltorg
.align
