extends Weapon

func _init() -> void:
	weapon_name = "Rocket Launcher"
	weapon_type = WeaponType.ROCKET_LAUNCHER
	damage = 300
	fire_rate = 30
	magazine_size = 2
	reload_time = 4.5
	spread = 0.0
	projectile_speed = 30.0
	is_auto = false
	is_hitscan = false
	explosion_radius = 5.0
