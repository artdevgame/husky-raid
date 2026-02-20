extends Weapon

func _init() -> void:
	weapon_name = "Assault Rifle"
	weapon_type = WeaponType.ASSAULT_RIFLE
	damage = 14
	fire_rate = 600
	magazine_size = 32
	reload_time = 2.0
	spread = 0.05
	is_auto = true
	is_hitscan = true
