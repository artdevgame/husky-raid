extends CharacterBody3D

class_name PlayerController

@export_category("Movement")
@export var base_speed := 6.0
@export var sprint_speed := 9.0
@export var jump_velocity := 8.0
@export var gravity := 20.0
@export var slide_speed := 12.0
@export var thrust_force := 15.0
@export var thrust_cooldown := 2.0
@export var slide_duration := 0.5

@export_category("Combat")
@export var max_health := 100
@export var max_shields := 100
@export var shield_recharge_delay := 3.0
@export var shield_recharge_rate := 25.0

@onready var camera_pivot := $CameraPivot
@onready var camera := $CameraPivot/Camera3D
@onready var muzzle := $CameraPivot/Camera3D/Muzzle
@onready var weapon_holder := $CameraPivot/WeaponHolder
@onready var shield_mesh := $ShieldMesh
@onready var footstep_timer := $FootstepTimer

var current_speed := base_speed
var mouse_sensitivity := 0.002
var is_sprinting := false
var is_crouching := false
var is_sliding := false
var is_thrusting := false
var thrust_timer := 0.0
var slide_timer := 0.0

var health := max_health
var shields := max_shields
var shield_damage_timer := 0.0
var is_alive := true

var current_weapon = null
var held_weapons : Array = []
var grenade_count := 2
var has_flag := false
var team : int = 0
var player_id : int = 0

var input_dir := Vector3.ZERO
var direction := Vector3.ZERO

const AIR_ACCEL := 4.0
const GROUND_ACCEL := 12.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if not multiplayer.is_server():
		return
	
	health = max_health
	shields = max_shields
	
	equip_starting_weapons()

func equip_starting_weapons() -> void:
	var ar_scene = preload("res://assets/prefabs/weapons/assault_rifle.tscn")
	var ar = ar_scene.instantiate()
	equip_weapon(ar)

func _input(event: InputEvent) -> void:
	if not is_alive:
		return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	
	if event.is_action_pressed("fire"):
		try_fire_weapon()
	
	if event.is_action_pressed("jump"):
		jump()
	
	if event.is_action_pressed("reload"):
		reload_weapon()
	
	if event.is_action_pressed("melee"):
		try_melee()
	
	if event.is_action_pressed("throw_grenade"):
		throw_grenade()

func try_melee() -> void:
	if current_weapon and current_weapon.is_melee:
		current_weapon.try_fire()

func throw_grenade() -> void:
	if grenade_count > 0:
		grenade_count -= 1
		var grenade_scene = preload("res://assets/prefabs/grenade.tscn")
		if grenade_scene:
			var grenade = grenade_scene.instantiate()
			get_parent().add_child(grenade)
			grenade.global_position = global_position + Vector3.UP
			grenade.owner_id = multiplayer.get_unique_id()
			var throw_dir = -global_transform.basis.z
			throw_dir.y = 0.5
			grenade.velocity = throw_dir.normalized() * grenade.throw_velocity

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	if not multiplayer.is_server():
		handle_movement_input()
		apply_gravity(delta)
		move_and_slide()
		handle_state_timers(delta)
		return
	
	handle_movement_input()
	handle_sprinting()
	handle_crouching()
	handle_sliding(delta)
	handle_thrusting(delta)
	apply_gravity(delta)
	handle_shield_recharge(delta)
	
	move_and_slide()
	
	if is_on_floor() and velocity.length() > 1.0:
		if footstep_timer.is_stopped():
			footstep_timer.start()
	
	handle_state_timers(delta)

func handle_movement_input() -> void:
	var input_vector := Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_vector -= Vector3.FORWARD
	if Input.is_action_pressed("move_backward"):
		input_vector += Vector3.FORWARD
	if Input.is_action_pressed("move_left"):
		input_vector -= Vector3.RIGHT
	if Input.is_action_pressed("move_right"):
		input_vector += Vector3.RIGHT
	
	input_vector = input_vector.normalized()
	direction = (transform.basis * input_vector).normalized()
	direction = Vector3(direction.x, 0, direction.z).normalized()

func handle_sprinting() -> void:
	is_sprinting = Input.is_action_pressed("sprint") and direction.length() > 0
	
	if is_sprinting and not is_crouching:
		current_speed = sprint_speed
	else:
		current_speed = base_speed

func handle_crouching() -> void:
	is_crouching = Input.is_action_pressed("crouch")
	
	if is_crouching and is_on_floor():
		current_speed = base_speed * 0.5
		collision_layer = 2
	else:
		collision_layer = 1

func handle_sliding(delta: float) -> void:
	if is_sliding:
		current_speed = lerp(current_speed, slide_speed, delta * 5)
		
		if slide_timer > 0:
			slide_timer -= delta
		else:
			is_sliding = false
	elif Input.is_action_pressed("crouch") and is_sprinting and is_on_floor():
		is_sliding = true
		slide_timer = slide_duration

func handle_thrusting(delta: float) -> void:
	if thrust_timer > 0:
		thrust_timer -= delta
	
	if Input.is_action_pressed("thrust") and thrust_timer <= 0 and is_on_floor():
		thrust_timer = thrust_cooldown
		var thrust_dir = direction
		if thrust_dir == Vector3.ZERO:
			thrust_dir = -transform.basis.z
		velocity = thrust_dir * thrust_force
		velocity.y = 3.0

func handle_state_timers(delta: float) -> void:
	if is_on_floor():
		thrust_timer = 0.0
		if is_sliding and Input.is_action_pressed("crouch"):
			pass
		elif direction.length() > 0:
			velocity.x = move_toward(velocity.x, direction.x * current_speed, GROUND_ACCEL * delta)
			velocity.z = move_toward(velocity.z, direction.z * current_speed, GROUND_ACCEL * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, GROUND_ACCEL * delta)
			velocity.z = move_toward(velocity.z, 0, GROUND_ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, direction.x * current_speed, AIR_ACCEL * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_speed, AIR_ACCEL * delta)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func jump() -> void:
	if is_on_floor():
		velocity.y = jump_velocity
		SoundEffects.play_jump()

func handle_shield_recharge(delta: float) -> void:
	if shields >= max_shields:
		shield_mesh.visible = false
		return
	
	if shield_damage_timer > 0:
		shield_damage_timer -= delta
	else:
		shields = min(max_shields, shields + shield_recharge_rate * delta)
		update_health_display()

func take_damage(amount: int, attacker_id: int = 0) -> void:
	if not is_alive:
		return
	
	shield_damage_timer = shield_recharge_delay
	
	var remaining_damage = amount
	
	if shields > 0:
		var shield_damage = min(shields, remaining_damage)
		shields -= shield_damage
		remaining_damage -= shield_damage
		
		if shields <= 0:
			shield_mesh.visible = true
	else:
		shield_mesh.visible = false
	
	health = max(0, health - remaining_damage)
	update_health_display()
	
	if health <= 0:
		die()

func update_health_display() -> void:
	if has_node("HealthBar"):
		var health_bar = $HealthBar
		health_bar.max_value = max_health + max_shields
		health_bar.value = health + shields

func die() -> void:
	is_alive = false
	
	if has_flag:
		drop_flag()
	
	velocity = Vector3.ZERO
	visible = false
	
	SoundEffects.play_death()
	respawn_timer()

func respawn_timer() -> void:
	await get_tree().create_timer(3.0).timeout
	respawn()

func respawn() -> void:
	is_alive = true
	health = max_health
	shields = max_shields
	visible = true
	
	has_flag = false
	
	SoundEffects.play_respawn()
	update_health_display()
	position = get_spawn_position()

func get_spawn_position() -> Vector3:
	var spawn_points : Array = []
	
	if team == 0:
		spawn_points = [
			Vector3(-40, 2, 0),
			Vector3(-35, 2, -10),
			Vector3(-35, 2, 10),
			Vector3(-45, 2, 5),
			Vector3(-45, 2, -5)
		]
	else:
		spawn_points = [
			Vector3(40, 2, 0),
			Vector3(35, 2, -10),
			Vector3(35, 2, 10),
			Vector3(45, 2, 5),
			Vector3(45, 2, -5)
		]
	
	return spawn_points.pick_random()

func drop_flag() -> void:
	has_flag = false
	if has_node("Flag"):
		var flag = $Flag
		flag.reparent(get_parent())
		flag.position = global_position + Vector3.UP
		flag.carrier = null

func equip_weapon(weapon) -> void:
	current_weapon = weapon
	if weapon:
		weapon.reparent(weapon_holder)
		weapon.position = Vector3.ZERO
		weapon.rotation = Vector3.ZERO
		weapon.owner_player = self
		weapon.muzzle_point = muzzle

func pickup_weapon(weapon_type: int) -> void:
	var weapon_scene: PackedScene
	
	match weapon_type:
		0: weapon_scene = preload("res://assets/prefabs/weapons/assault_rifle.tscn")
		1: weapon_scene = preload("res://assets/prefabs/weapons/pistol.tscn")
		2: weapon_scene = preload("res://assets/prefabs/weapons/shotgun.tscn")
		3: weapon_scene = preload("res://assets/prefabs/weapons/sniper.tscn")
		4: weapon_scene = preload("res://assets/prefabs/weapons/rocket_launcher.tscn")
		5: weapon_scene = preload("res://assets/prefabs/weapons/energy_sword.tscn")
	
	if weapon_scene:
		var weapon = weapon_scene.instantiate()
		equip_weapon(weapon)

func try_fire_weapon() -> void:
	if current_weapon and current_weapon.has_method("try_fire"):
		current_weapon.try_fire()

func reload_weapon() -> void:
	if current_weapon and current_weapon.has_method("reload"):
		current_weapon.reload()

func pickup_flag(flag) -> void:
	if not has_flag and flag.team != team:
		has_flag = true
		flag.carrier = self
		flag.state = CTFFlag.FlagState.CARRIED
		
		if has_node("CarriedFlag"):
			var carried_flag = $CarriedFlag
			flag.reparent(carried_flag)
			flag.position = Vector3.ZERO
		
		SoundEffects.play_flag_pickup()

func _on_footstep_timer_timeout() -> void:
	SoundEffects.play_footstep()
