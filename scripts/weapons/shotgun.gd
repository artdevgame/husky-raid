extends Weapon

func _init() -> void:
	weapon_name = "Shotgun"
	weapon_type = WeaponType.SHOTGUN
	damage = 100
	fire_rate = 60
	magazine_size = 6
	reload_time = 3.0
	spread = 0.2
	is_auto = false
	is_hitscan = true

func perform_fire() -> void:
	if muzzle_point == null:
		return
	
	for i in range(8):
		var dir = get_fire_direction()
		perform_hitscan(dir)
	
	apply_recoil()
