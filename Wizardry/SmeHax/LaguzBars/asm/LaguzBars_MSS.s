.thumb
.align

.include "LaguzBars_Defs.s"

.global LaguzBarMSSGetter
.type LaguzBarMSSGetter, %function


LaguzBarMSSGetter:
@return bar value in r0
@r8 = current unit data


push {r14}

mov r0,r8
ldr r0,[r0,#4]
ldrb r0,[r0,#4]
blh IsClassLaguz
cmp r0,#0
beq RetNotLaguz

mov r0,r8
blh GetLaguzBar
b GoBack

RetNotLaguz:
mov r0,#255

GoBack:
pop {r1}
bx r1

.ltorg
.align

