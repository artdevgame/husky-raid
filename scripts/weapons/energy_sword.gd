extends Weapon

@export var lunge_force := 20.0

func _init() -> void:
	weapon_name = "Energy Sword"
	weapon_type = WeaponType.ENERGY_SWORD
	damage = 200
	magazine_size = -1
	reload_time = 0.0
	is_auto = false
	is_hitscan = false
	is_melee = true

func _physics_process(delta: float) -> void:
	if not can_fire:
		fire_timer -= delta
		if fire_timer <= 0:
			can_fire = true
			visible = false

func try_fire() -> bool:
	if not can_fire:
		return false
	
	can_fire = false
	fire_timer = 0.5
	visible = true
	
	perform_melee()
	return true

func perform_melee() -> void:
	if owner_player:
		var forward_dir = -owner_player.global_transform.basis.z
		owner_player.velocity = forward_dir * lunge_force
		owner_player.velocity.y = 5.0
	
	if muzzle_point == null:
		return
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		owner_player.global_position,
		owner_player.global_position + (-owner_player.global_transform.basis.z) * 3.0
	)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_obj = result.collider
		if hit_obj.has_method("take_damage"):
			hit_obj.take_damage(damage, get_parent().multiplayer.get_unique_id())
