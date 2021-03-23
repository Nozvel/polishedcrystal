; BattleAnimCommands indexes (see engine/battle_anims/anim_commands.asm)
	const_def $cf
FIRST_BATTLE_ANIM_CMD EQU const_value

anim_wait: MACRO
	assert (\1) < FIRST_BATTLE_ANIM_CMD, "anim_wait argument must be less than {FIRST_BATTLE_ANIM_CMD}"
	db \1
ENDM

	const anim_statloop_command ; cf
anim_statloop: MACRO
	db anim_statloop_command
	dw \1 ; address
ENDM

	const anim_obj_command ; d0
anim_obj: MACRO
	db anim_obj_command
	db \1 ; object
if _NARG == 4
	db \2 ; x
	db \3 ; y
	db \4 ; param
else
	db \2 * 8 + \3 ; x
	db \4 * 8 + \5 ; y
	db \6 ; param
endc
ENDM

	const anim_1gfx_command ; d1
anim_1gfx: MACRO
	db anim_1gfx_command
	db \1 ; gfx1
ENDM

	const anim_2gfx_command ; d2
anim_2gfx: MACRO
	db anim_2gfx_command
	db \1 ; gfx1
	db \2 ; gfx2
ENDM

	const anim_3gfx_command ; d3
anim_3gfx: MACRO
	db anim_3gfx_command
	db \1 ; gfx1
	db \2 ; gfx2
	db \3 ; gfx3
ENDM

	const anim_4gfx_command ; d4
anim_4gfx: MACRO
	db anim_4gfx_command
	db \1 ; gfx1
	db \2 ; gfx2
	db \3 ; gfx3
	db \4 ; gfx4
ENDM

	const anim_5gfx_command ; d5
anim_5gfx: MACRO
	db anim_5gfx_command
	db \1 ; gfx1
	db \2 ; gfx2
	db \3 ; gfx3
	db \4 ; gfx4
	db \5 ; gfx5
ENDM

	const anim_incobj_command ; d6
anim_incobj: MACRO
	db anim_incobj_command
	db \1 ; id
ENDM

	const anim_setobj_command ; d7
anim_setobj: MACRO
	db anim_setobj_command
	db \1 ; id
	db \2 ; obj
ENDM

	const anim_incbgeffect_command ; d8
anim_incbgeffect: MACRO
	db anim_incbgeffect_command
	db \1 ; effect
ENDM

	const anim_enemyfeetobj_command ; d9
anim_enemyfeetobj: MACRO
	db anim_enemyfeetobj_command
ENDM

	const anim_playerheadobj_command ; da
anim_playerheadobj: MACRO
	db anim_playerheadobj_command
ENDM

	const anim_checkpokeball_command ; db
anim_checkpokeball: MACRO
	db anim_checkpokeball_command
ENDM

	const anim_transform_command ; dc
anim_transform: MACRO
	db anim_transform_command
ENDM

	const anim_raisesub_command ; dd
anim_raisesub: MACRO
	db anim_raisesub_command
ENDM

	const anim_dropsub_command ; de
anim_dropsub: MACRO
	db anim_dropsub_command
ENDM

	const anim_resetobp0_command ; df
anim_resetobp0: MACRO
	db anim_resetobp0_command
ENDM

	const anim_sound_command ; e0
anim_sound: MACRO
	db anim_sound_command
	db (\1 << 2) | \2 ; duration, tracks
	db \3 ; id
ENDM

	const anim_cry_command ; e1
anim_cry: MACRO
	db anim_cry_command
	db \1 ; pitch
ENDM

	const anim_minimizeopp_command ; e2
anim_minimizeopp: MACRO
	db anim_minimizeopp_command
ENDM

	const anim_oamon_command ; e3
anim_oamon: MACRO
	db anim_oamon_command
ENDM

	const anim_oamoff_command ; e4
anim_oamoff: MACRO
	db anim_oamoff_command
ENDM

	const anim_clearobjs_command ; e5
anim_clearobjs: MACRO
	db anim_clearobjs_command
ENDM

	const anim_beatup_command ; e6
anim_beatup: MACRO
	db anim_beatup_command
ENDM

	const anim_0xe7_command ; e7
anim_0xe7: MACRO
	db anim_0xe7_command
ENDM

	const anim_updateactorpic_command ; e8
anim_updateactorpic: MACRO
	db anim_updateactorpic_command
ENDM

	const anim_minimize_command ; e9
anim_minimize: MACRO
	db anim_minimize_command
ENDM

	const anim_0xea_command ; ea
anim_0xea: MACRO
	db anim_0xea_command
ENDM

	const anim_0xeb_command ; eb
anim_0xeb: MACRO
	db anim_0xeb_command
ENDM

	const anim_0xec_command ; ec
anim_0xec: MACRO
	db anim_0xec_command
ENDM

	const anim_0xed_command ; ed
anim_0xed: MACRO
	db anim_0xed_command
ENDM

	const anim_jumpand_command ; ee
anim_jumpand: MACRO
	db anim_jumpand_command
	db \1 ; value
	dw \2 ; address
ENDM

	const anim_jumpuntil_command ; ef
anim_jumpuntil: MACRO
	db anim_jumpuntil_command
	dw \1 ; address
ENDM

	const anim_bgeffect_command ; f0
anim_bgeffect: MACRO
	db anim_bgeffect_command
	db \1 ; effect
	db \2 ; unknown
	db \3 ; unknown
	db \4 ; unknown
ENDM

	const anim_bgp_command ; f1
anim_bgp: MACRO
	db anim_bgp_command
	db \1 ; colors
ENDM

	const anim_obp0_command ; f2
anim_obp0: MACRO
	db anim_obp0_command
	db \1 ; colors
ENDM

	const anim_obp1_command ; f3
anim_obp1: MACRO
	db anim_obp1_command
	db \1 ; colors
ENDM

	const anim_clearsprites_command ; f4
anim_clearsprites: MACRO
	db anim_clearsprites_command
ENDM

	const anim_0xf5_command ; f5
anim_0xf5: MACRO
	db anim_0xf5_command
ENDM

	const anim_0xf6_command ; f6
anim_0xf6: MACRO
	db anim_0xf6_command
ENDM

	const anim_0xf7_command ; f7
anim_0xf7: MACRO
	db anim_0xf7_command
ENDM

	const anim_jumpif_command ; f8
anim_jumpif: MACRO
	db anim_jumpif_command
	db \1 ; value
	dw \2 ; address
ENDM

	const anim_setvar_command ; f9
anim_setvar: MACRO
	db anim_setvar_command
	db \1 ; value
ENDM

	const anim_incvar_command ; fa
anim_incvar: MACRO
	db anim_incvar_command
ENDM

	const anim_jumpvar_command ; fb
anim_jumpvar: MACRO
	db anim_jumpvar_command
	db \1 ; value
	dw \2 ; address
ENDM

	const anim_jump_command ; fc
anim_jump: MACRO
	db anim_jump_command
	dw \1 ; address
ENDM

	const anim_loop_command ; fd
anim_loop: MACRO
	db anim_loop_command
	db \1 ; count
	dw \2 ; address
ENDM

	const anim_call_command ; fe
anim_call: MACRO
	db anim_call_command
	dw \1 ; address
ENDM

	const anim_ret_command ; ff
anim_ret: MACRO
	db anim_ret_command
ENDM
