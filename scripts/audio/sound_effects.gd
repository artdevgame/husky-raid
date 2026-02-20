extends Node

const FOOTSTEP : String = "footstep"
const JUMP : String = "jump"
const LAND : String = "land"
const FIRE_AR : String = "fire_ar"
const FIRE_PISTOL : String = "fire_pistol"
const FIRE_SHOTGUN : String = "fire_shotgun"
const FIRE_SNIPER : String = "fire_sniper"
const FIRE_ROCKET : String = "fire_rocket"
const RELOAD : String = "reload"
const EMPTY_CLIP : String = "empty_clip"
const MELEE_SWING : String = "melee_swing"
const MELEE_HIT : String = "melee_hit"
const GRENADE_THROW : String = "grenade_throw"
const GRENADE_EXPLODE : String = "grenade_explode"
const EXPLOSION : String = "explosion"
const SHIELD_BREAK : String = "shield_break"
const SHIELD_RECHARGE : String = "shield_recharge"
const PLAYER_DIE : String = "player_die"
const PLAYER_RESPAWN : String = "player_respawn"
const FLAG_PICKUP : String = "flag_pickup"
const FLAG_CAPTURE : String = "flag_capture"
const FLAG_RETURN : String = "flag_return"
const FLAG_DROP : String = "flag_drop"
const UI_CLICK : String = "ui_click"
const UI_HOVER : String = "ui_hover"
const MATCH_START : String = "match_start"
const MATCH_END : String = "match_end"

func get_sound_path(sound_name: String) -> String:
	return "res://assets/audio/sfx/" + sound_name + ".ogg"

func play_sound(sound_name: String, volume: float = 0.0) -> void:
	if not has_node("/root/AudioManager"):
		return
	
	var path = get_sound_path(sound_name)
	if ResourceLoader.exists(path):
		var stream = load(path)
		AudioManager.play_sfx(stream, volume)

func play_footstep() -> void:
	play_sound(FOOTSTEP, -10.0)

func play_jump() -> void:
	play_sound(JUMP, -5.0)

func play_land() -> void:
	play_sound(LAND, -5.0)

func play_fire(weapon_type: String) -> void:
	match weapon_type:
		"assault_rifle": play_sound(FIRE_AR, -5.0)
		"pistol": play_sound(FIRE_PISTOL, -5.0)
		"shotgun": play_sound(FIRE_SHOTGUN, -2.0)
		"sniper": play_sound(FIRE_SNIPER, 0.0)
		"rocket_launcher": play_sound(FIRE_ROCKET, 0.0)
		"energy_sword": play_sound(MELEE_SWING, 0.0)

func play_reload() -> void:
	play_sound(RELOAD, -5.0)

func play_shield_break() -> void:
	play_sound(SHIELD_BREAK, 0.0)

func play_shield_recharge() -> void:
	play_sound(SHIELD_RECHARGE, -10.0)

func play_death() -> void:
	play_sound(PLAYER_DIE, 0.0)

func play_respawn() -> void:
	play_sound(PLAYER_RESPAWN, -5.0)

func play_flag_pickup() -> void:
	play_sound(FLAG_PICKUP, 0.0)

func play_flag_capture() -> void:
	play_sound(FLAG_CAPTURE, 0.0)

func play_flag_return() -> void:
	play_sound(FLAG_RETURN, -5.0)
