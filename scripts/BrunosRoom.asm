BrunosRoom_Script:
	call BrunoShowOrHideExitBlock
	call EnableAutoTextBoxDrawing
	ld hl, BrunosRoomTrainerHeaders
	ld de, BrunosRoom_ScriptPointers
	ld a, [wBrunosRoomCurScript]
	call ExecuteCurMapScriptInTable
	ld [wBrunosRoomCurScript], a
	ret

BrunoShowOrHideExitBlock:
; Blocks or clears the exit to the next room.
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	ret z
	ld a, [wGameStage] ; Check if player has beat game
	and a
	jr nz, .Rematch
	CheckEvent EVENT_BEAT_BRUNOS_ROOM_TRAINER_0
	jr z, .blockExitToNextRoom
	ld a, $5
	jp .setExitBlock
.blockExitToNextRoom
	ld a, $24
.setExitBlock
	ld [wNewTileBlockID], a
	lb bc, 0, 2
	predef_jump ReplaceTileBlock
.Rematch
	CheckEvent EVENT_BEAT_BRUNOS_ROOM_TRAINER_1
	jr z, .blockExitToNextRoom
	ld a, $5
	jr .setExitBlock

ResetBrunoScript:
	xor a ; SCRIPT_BRUNOSROOM_DEFAULT
	ld [wBrunosRoomCurScript], a
	ret

BrunosRoom_ScriptPointers:
	def_script_pointers
	dw_const BrunosRoomDefaultScript,               SCRIPT_BRUNOSROOM_DEFAULT
	dw_const DisplayEnemyTrainerTextAndStartBattle, SCRIPT_BRUNOSROOM_BRUNO_START_BATTLE
	dw_const BrunosRoomBrunoEndBattleScript,        SCRIPT_BRUNOSROOM_BRUNO_END_BATTLE
	dw_const BrunosRoomPlayerIsMovingScript,        SCRIPT_BRUNOSROOM_PLAYER_IS_MOVING
	dw_const DoRet,                                 SCRIPT_BRUNOSROOM_NOOP

BrunoScriptWalkIntoRoom:
; Walk six steps upward.
	ld hl, wSimulatedJoypadStatesEnd
	ld a, D_UP
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld a, $6
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_BRUNOSROOM_PLAYER_IS_MOVING
	ld [wBrunosRoomCurScript], a
	ld [wCurMapScript], a
	ret

BrunosRoomDefaultScript:
	ld hl, BrunoEntranceCoords
	call ArePlayerCoordsInArray
	jp nc, CheckFightingMapTrainers
	xor a
	ldh [hJoyPressed], a
	ldh [hJoyHeld], a
	ld [wSimulatedJoypadStatesEnd], a
	ld [wSimulatedJoypadStatesIndex], a
	ld a, [wCoordIndex]
	cp $3  ; Is player standing one tile above the exit?
	jr c, .stopPlayerFromLeaving
	CheckAndSetEvent EVENT_AUTOWALKED_INTO_BRUNOS_ROOM
	jr z, BrunoScriptWalkIntoRoom
.stopPlayerFromLeaving
	ld a, TEXT_BRUNOSROOM_BRUNO_DONT_RUN_AWAY
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID  ; "Don't run away!"
	ld a, D_UP
	ld [wSimulatedJoypadStatesEnd], a
	ld a, $1
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_BRUNOSROOM_PLAYER_IS_MOVING
	ld [wBrunosRoomCurScript], a
	ld [wCurMapScript], a
	ret

BrunoEntranceCoords:
	dbmapcoord  4, 10
	dbmapcoord  5, 10
	dbmapcoord  4, 11
	dbmapcoord  5, 11
	db -1 ; end

BrunosRoomPlayerIsMovingScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	call Delay3
	xor a ; SCRIPT_BRUNOSROOM_DEFAULT
	ld [wJoyIgnore], a
	ld [wBrunosRoomCurScript], a
	ld [wCurMapScript], a
	ret

BrunosRoomBrunoEndBattleScript:
	call EndTrainerBattle
	ld a, [wIsInBattle]
	cp $ff
	jp z, ResetBrunoScript
	ld a, [wGameStage] ; Check if player has beat game
	and a
	jr nz, .Rematch
	ld a, TEXT_BRUNOSROOM_BRUNO
.continue
	ldh [hSpriteIndexOrTextID], a
	call DisplayTextID
;;;;;;;;;; PureRGBnote: ADDED: sound effect for the doors opening
	ld a, SFX_GO_INSIDE
	rst _PlaySound
	ret
;;;;;;;;;;
.Rematch
	ld a, TEXT_BRUNOSROOM_BRUNO_REMATCH
	jr .continue

BrunosRoom_TextPointers:
	def_text_pointers
	dw_const BrunosRoomBrunoText,            TEXT_BRUNOSROOM_BRUNO
	dw_const BrunosRoomBrunoRematchText,     TEXT_BRUNOSROOM_BRUNO_REMATCH
	dw_const BrunosRoomBrunoDontRunAwayText, TEXT_BRUNOSROOM_BRUNO_DONT_RUN_AWAY

BrunosRoomTrainerHeaders:
	def_trainers
BrunosRoomTrainerHeader0:
	trainer EVENT_BEAT_BRUNOS_ROOM_TRAINER_0, 0, BrunoBeforeBattleText, BrunoEndBattleText, BrunoAfterBattleText
BrunosRoomTrainerHeader1:
	trainer EVENT_BEAT_BRUNOS_ROOM_TRAINER_1, 0, BrunoRematchBeforeBattleText, BrunoRematchEndBattleText, BrunoRematchAfterBattleText
	db -1 ; end

BrunosRoomBrunoText:
	text_asm
	ld hl, BrunosRoomTrainerHeader0
	call TalkToTrainer
	rst TextScriptEnd

BrunosRoomBrunoRematchText:
	text_asm
	ld hl, BrunosRoomTrainerHeader1
	call TalkToTrainer
	rst TextScriptEnd

BrunoBeforeBattleText:
	text_far _BrunoBeforeBattleText
	text_end

BrunoEndBattleText:
	text_far _BrunoEndBattleText
	text_end

BrunoAfterBattleText:
	text_far _BrunoAfterBattleText
	text_end

BrunoRematchBeforeBattleText:
	text_far _BrunoRematchBeforeBattleText
	text_end

BrunoRematchEndBattleText:
	text_far _BrunoRematchEndBattleText
	text_end

BrunoRematchAfterBattleText:
	text_far _BrunoRematchAfterBattleText
	text_end

BrunosRoomBrunoDontRunAwayText:
	text_far _BrunosRoomBrunoDontRunAwayText
	text_end
