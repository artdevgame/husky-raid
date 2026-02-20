extends Area3D

class_name WeaponPickup

enum WeaponType { ASSAULT_RIFLE, PISTOL, SHOTGUN, SNIPER, ROCKET_LAUNCHER, ENERGY_SWORD }

@export var weapon_type := WeaponType.ASSAULT_RIFLE
@export var respawn_time := 30.0

var is_available := true
var respawn_timer := 0.0

@onready var mesh := $MeshInstance3D
@onready var glow := $OmniLight3D
@onready var area := $Area3D

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	update_visuals()

func _process(delta: float) -> void:
	if not is_available:
		respawn_timer -= delta
		if respawn_timer <= 0:
			is_available = true
			update_visuals()

func _on_body_entered(body: Node3D) -> void:
	if not is_available:
		return
	
	if body.has_method("pickup_weapon"):
		body.pickup_weapon(weapon_type)
		start_respawn()

func start_respawn() -> void:
	is_available = false
	respawn_timer = respawn_time
	update_visuals()

func update_visuals() -> void:
	visible = is_available
	area.monitorable = is_available
	area.monitoring = is_available
