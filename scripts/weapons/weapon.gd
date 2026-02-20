extends Node3D

class_name Weapon

enum WeaponType { ASSAULT_RIFLE, PISTOL, SHOTGUN, SNIPER, ROCKET_LAUNCHER, ENERGY_SWORD }

@export_category("Weapon Stats")
@export var weapon_name := "Weapon"
@export var weapon_type := WeaponType.ASSAULT_RIFLE
@export var damage := 14
@export var fire_rate := 600.0
@export var magazine_size := 32
@export var reserve_ammo := 90
@export var reload_time := 2.0
@export var spread := 0.05
@export var projectile_speed := 50.0
@export var zoom_multiplier := 1.5
@export var is_auto := true
@export var is_hitscan := true
@export var is_melee := false
@export var explosion_radius := 0.0

var current_ammo : int
var current_reserve : int
var is_reloading := false
var can_fire := true
var fire_timer := 0.0

var owner_player : Node3D = null
var muzzle_point : Node3D = null

signal fired(projectile)
signal out_of_ammo()
signal reloaded()

func _ready() -> void:
	current_ammo = magazine_size
	current_reserve = reserve_ammo

func _process(delta: float) -> void:
	if not can_fire:
		fire_timer -= delta
		if fire_timer <= 0:
			can_fire = true

func can_shoot() -> bool:
	return can_fire and not is_reloading and current_ammo > 0

func try_fire() -> bool:
	if not can_shoot():
		if current_ammo <= 0:
			emit_signal("out_of_ammo")
		return false
	
	can_fire = false
	fire_timer = 60.0 / fire_rate
	current_ammo -= 1
	
	perform_fire()
	
	if current_ammo <= 0:
		emit_signal("out_of_ammo")
	
	return true

func perform_fire() -> void:
	if muzzle_point == null:
		return
	
	var dir = get_fire_direction()
	
	if is_hitscan:
		perform_hitscan(dir)
	else:
		spawn_projectile(dir)
	
	apply_recoil()

func get_fire_direction() -> Vector3:
	var base_dir = -muzzle_point.global_transform.basis.z
	var random_spread = Vector3(
		randf_range(-spread, spread),
		randf_range(-spread, spread),
		randf_range(-spread, spread)
	)
	return (base_dir + random_spread).normalized()

func perform_hitscan(dir: Vector3) -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		muzzle_point.global_position,
		muzzle_point.global_position + dir * 1000.0
	)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_obj = result.collider
		if hit_obj.has_method("take_damage"):
			hit_obj.take_damage(damage, get_parent().multiplayer.get_unique_id())

func spawn_projectile(dir: Vector3) -> void:
	var projectile = preload("res://assets/prefabs/projectile.tscn").instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = muzzle_point.global_position
	projectile.velocity = dir * projectile_speed
	projectile.damage = damage
	projectile.explosion_radius = explosion_radius
	projectile.owner_id = get_parent().multiplayer.get_unique_id()
	
	emit_signal("fired", projectile)

func apply_recoil() -> void:
	if owner_player and owner_player.camera:
		owner_player.camera.rotation.x -= spread * 0.5

func reload() -> void:
	if is_reloading or current_ammo == magazine_size or current_reserve <= 0:
		return
	
	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	
	var needed = magazine_size - current_ammo
	var to_load = min(needed, current_reserve)
	current_ammo += to_load
	current_reserve -= to_load
	
	is_reloading = false
	emit_signal("reloaded")

func get_weapon_type_name() -> String:
	match weapon_type:
		WeaponType.ASSAULT_RIFLE: return "Assault Rifle"
		WeaponType.PISTOL: return "Pistol"
		WeaponType.SHOTGUN: return "Shotgun"
		WeaponType.SNIPER: return "Sniper Rifle"
		WeaponType.ROCKET_LAUNCHER: return "Rocket Launcher"
		WeaponType.ENERGY_SWORD: return "Energy Sword"
		_: return weapon_name
