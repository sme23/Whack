.thumb
.align

.global EnableFreeMovementASMC
.type EnableFreeMovementASMC, %function

.global DisableFreeMovementASMC
.type DisableFreeMovementASMC, %function

.global NewPlayerPhaseEvaluationFunc
.type NewPlayerPhaseEvaluationFunc, %function

.global NewMakePhaseControllerFunc
.type NewMakePhaseControllerFunc, %function

.global FreeMovement_MainLoop
.type FreeMovement_MainLoop, %function


.macro blh to,reg=r3
	push {\reg}
	ldr \reg,=\to
	mov r14,\reg
	pop {\reg}
	.short 0xF800
.endm

.equ NewBlockingProc, 0x8002CE1
.equ GotoProcLabel, 0x8002F25
.equ BreakProcLoop, 0x8002E95


EnableFreeMovementASMC:
ldr r0,=#0x203F2B0	@location of flag
ldrb r1,[r0]		@load a byte
mov r2,#0x1			@this is the mask for the flag
orr r1,r2			@set the flag if not already set
strb r1,[r0]		@store back the byte
bx r14				@return

.ltorg
.align

DisableFreeMovementASMC:
ldr r0,=#0x203F2B0	@location of flag
ldrb r1,[r0]		@load a byte
mov r2,#0x1			@this is the mask for the flag
neg r2,r2			@invert it since we want to disable this
and r1,r2			@this now gives everything that we loaded except for the flag
strb r1,[r0]		@store back the byte
bx r14				@return

.ltorg
.align

GetFreeMovementState:
ldr r0,=#0x203F2B0	@location of flag
ldrb r1,[r0]		@load a byte
mov r2,#0x1			@this is the mask for the flag
and r1,r2			@get only the flag from the loaded byte
mov r0,r1			@return the resulting value
bx r14				@return

.ltorg
.align


NewPlayerPhaseEvaluationFunc:
push {r4,r14}
mov r4,r0 @r4 = parent proc

@check the state of the free movement flag
bl GetFreeMovementState
cmp r0,#1
bne PhaseEval_PlayerPhaseAsNormal

ldr r0,=FreeMovementControlProc
mov r1,r4
blh NewBlockingProc
b PhaseEval_CombinedBits

.ltorg
.align

PhaseEval_PlayerPhaseAsNormal:
ldr r0,=#0x859AAD8 @E_PLAYERPHASE proc
mov r1,r4 @r1 = parent proc
blh NewBlockingProc

PhaseEval_CombinedBits:
mov r1,#7 @7 = proc label
blh GotoProcLabel
mov r0,r4 @r0 = parent proc
blh BreakProcLoop
pop {r4}
pop {r0}
bx r0

.ltorg
.align


NewMakePhaseControllerFunc:
push {r4,r14}
mov r4,r0 @r4 = parent proc

@check the state of the free movement flag
bl GetFreeMovementState
cmp r0,#1
bne PhaseController_DoVanillaFunction

@start our free movement proc instead of the proc we would do otherwise
ldr r0,=FreeMovementControlProc
mov r1,r4
blh NewBlockingProc
b PhaseController_GoBack

.ltorg
.align

PhaseController_DoVanillaFunction:
ldr r0,=#0x202BCF0 @chapter data
ldrb r0,[r0,#0xF] @current phase
cmp r0,#0
beq PhaseController_IsPlayerPhase
b PhaseController_IsComputerPhase

.ltorg
.align

PhaseController_IsComputerPhase:
ldr r0,=#0x85A7F08 @computer phase proc
mov r1,r4
blh NewBlockingProc
b PhaseController_GoBack

.ltorg
.align

PhaseController_IsPlayerPhase:
ldr r0,=#0x859AAD8 @E_PLAYERPHASE proc
mov r1,r4
blh NewBlockingProc

PhaseController_GoBack:
mov r0,r4
blh BreakProcLoop
pop {r4}
pop {r0}
bx r0

.ltorg
.align



FreeMovement_MainLoop:
push {r4-r7,r14}

mov r6,r0 @r6 = parent proc
bl HandleUnitMovement @in place of the cursor movement function, same general idea

pop {r4-r7}
pop {r0}
bx r0

.ltorg
.align


.equ gpKeyState,0x858791C
.equ gGameState,0x202BCB0
.equ MoveCameraByStepMaybe,0x8015838
.equ SomeFunc,0x801588C


CheckDirectionalButtonPress:
push {r14}
ldr r0,=gpKeyState
ldr r2,[r0]
ldr r2,[r2,#4]

CheckUp:
mov r0,#0x40 @up
and r0,r2
cmp r0,#0
beq CheckLeft
mov r0,#1
b RetDirectionPressed

CheckLeft:
mov r0,#0x20
and r0,r2
cmp r0,#0
beq CheckDown
mov r0,#2
b RetDirectionPressed

CheckDown:
mov r0,#0x80
and r0,r2
cmp r0,#0
beq CheckRight
mov r0,#3
b RetDirectionPressed

CheckRight:
mov r0,#0x10
and r0,r2
cmp r0,#0
beq RetNoPress
mov r0,#4
b RetDirectionPressed

RetNoPress:
mov r0,#0

RetDirectionPressed:
pop {r1}
bx r1

.ltorg
.align



.equ MoveUnit,0x807A015 @r0 = unit struct, r1 = x coord, r1 = y coord, r3 = some constant (always 1? is this speed?)
.equ GetSomeEventEngineMoveRelatedBitfield,0x800FCD9
.equ CenterCameraOntoPosition,0x8015D85
.equ TryPrepareEventUnitMovement,0x800FC91
.equ CanUnitCrossTerrain,0x801949D

.global HandleUnitMovement
.type HandleUnitMovement, %function

HandleUnitMovement: @analogue of HandlePlayerCursorMovement
push {r4-r7,r14}

@let's see if we can just make this dumb
@to move units 

@order of operations here

@1. check for button press of any direction
@2. if true, check which direction
@3. once direction is found, if B is being pressed move the unit 2 steps in that direction
@otherwise, only move them 1 step

blh GetSomeEventEngineMoveRelatedBitfield
mov r7,r0

@check for directional button press
bl CheckDirectionalButtonPress
cmp r0,#0
beq HandleUnitMovement_GoBack

push {r6}

@now we uhhh index a jump table ig

lsl r0,r0,#2
ldr r1,=jpt_UnitDirection
add r0,r1
ldr r0,[r0]

ldr r1,=#0x202BE4C @first player unit
mov r4,r1
ldrb r6,[r4,#0x11]
ldrb r5,[r4,#0x10]

bx r0

.ltorg
.align

jpt_UnitDirection:
.word 0
.word MoveUp+0x8000001
.word MoveLeft+0x8000001
.word MoveDown+0x8000001
.word MoveRight+0x8000001

MoveUp:
mov r0,r4
mov r1,r5
mov r2,r6
cmp r2,#0
beq MoveReconvene
sub r2,#1
b MoveReconvene

MoveLeft:
mov r0,r4
mov r1,r5
mov r2,r6
cmp r1,#0
beq MoveReconvene
sub r1,#1
b MoveReconvene

MoveDown:
mov r0,r4
mov r1,r5
mov r2,r6
ldr r3,=#0x202E4D4
ldrh r3,[r3,#2]
sub r3,#1
cmp r2,r3
beq MoveReconvene
add r2,#1
b MoveReconvene

MoveRight:
mov r0,r4
mov r1,r5
mov r2,r6
ldr r3,=#0x202E4D4
ldrh r3,[r3]
sub r3,#1
cmp r1,r3
beq MoveReconvene
add r1,#1
b MoveReconvene

@this probably needs rewritten, look int MuCtr stuff to do so (structure a REDA in RAM and have it read that as the instruction?)

MoveReconvene:
mov r5,r1
mov r6,r2

@check if the tile we're trying to move to is impassable
@get terrain at that tile
ldr r2,=#0x202E4DC @terrain map
ldr r2,[r2]
lsl r1,r6,#2
add r2,r1
ldr r2,[r2]
add r2,r5
ldrb r1,[r2]
mov r0,r4
blh CanUnitCrossTerrain
cmp r0,#0
beq SkipMovingUnit

mov r0,r4
mov r1,r5
mov r2,r6
mov r3,r7 @redundant some of the time but not always
blh MoveUnit

@do fancy graphical thing here for moving map sprites


SkipMovingUnit:

@make the camera follow your movement
mov r0,r7
mov r1,r5
mov r2,r6
blh CenterCameraOntoPosition

@pause for some number of frames defined in proc sleeps via goto
pop {r0}

@check if B is being pressed
ldr r1,=gpKeyState
ldr r1,[r1]
ldr r1,[r1,#4]

mov r2,#0x2 @B button
and r1,r2
cmp r1,#0
beq SlowerProc
mov r1,#8
b GotoGivenSleepProcLabel
SlowerProc:
mov r1,#16
GotoGivenSleepProcLabel:
blh GotoProcLabel


HandleUnitMovement_GoBack:
pop {r4-r7}
pop {r0}
bx r0

.ltorg
.align



ldr r2,=gpKeyState
ldr r3,[r2]
ldrh r1,[r3,#4] @load currently pressed keys halfword
mov r0,#2		@check if B is pressed
and r0,r1
cmp r0,#0
beq HandleUnitMovement_StandardMoveSpeed @if not, move normal speed

@this is checking cursor display coordinates; repurposing these for current unit display coordinates as well (need to find current displayed map area and work from there)

@ldr r0,=gGameState
@ldr r0,[r0,#0x20] 
@ldr r1,=#0x70007
@and r0,r1
@cmp r0,#0
@bne StandardMoveSpeed

@move twice as fast if B is [b]eing pressed
@ldrh r0,[r3,#0x10]
@bl HandleCursorMovement @think this is just the visual part of moving the cursor actually; replace with our own for moving the unit?
mov r0,#8
blh MoveCameraByStepMaybe @This is directly related to cursor position data
mov r0,#8
blh SomeFunc @investigate
b HandleUnitMovement_PostMoveSpeed

.ltorg
.align

HandleUnitMovement_StandardMoveSpeed:
@ldr r0,[r2]
@ldrh r0,[r0,#6]
@bl HandleCursorMovement @think this is just the visual part of moving the cursor actually; replace with our own for moving the unit?
mov r0,#4
blh MoveCameraByStepMaybe
mov r0,#4
blh SomeFunc @investigate

HandleUnitMovement_PostMoveSpeed:

@theres a check here for cursor display coordinates so we're going to not
@actually lets understand what cursor is doing better first



@sets keys newly pressed this frame to
@Start|Right|Left|Up|Down|10|11|12|13|14|15
ldr r0,=gpKeyState
ldr r2,[r0]
ldrh r1,[r2,#8]
ldr r0,=#0xFcF4
and r0,r1
strh r0,[r2,#8]





