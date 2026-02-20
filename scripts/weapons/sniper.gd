extends Weapon

func _init() -> void:
	weapon_name = "Sniper Rifle"
	weapon_type = WeaponType.SNIPER
	damage = 450
	fire_rate = 30
	magazine_size = 4
	reload_time = 4.0
	spread = 0.0
	zoom_multiplier = 3.0
	is_auto = false
	is_hitscan = true
