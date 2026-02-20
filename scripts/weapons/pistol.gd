extends Weapon

func _init() -> void:
	weapon_name = "Pistol"
	weapon_type = WeaponType.PISTOL
	damage = 18
	fire_rate = 300
	magazine_size = 12
	reload_time = 1.5
	spread = 0.03
	is_auto = false
	is_hitscan = true
