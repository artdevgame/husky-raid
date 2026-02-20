extends Area3D

class_name Grenade

enum GrenadeType { FRAG, PLASMA }

@export var grenade_type := GrenadeType.FRAG
@export var damage := 100
@export var explosion_radius := 5.0
@export var throw_velocity := 15.0

var velocity := Vector3.ZERO
var owner_id : int = 0
var lifetime := 2.5

@onready var mesh := $MeshInstance3D
@onready var area := $Area3D

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	explode()

func _physics_process(delta: float) -> void:
	velocity.y -= 20.0 * delta
	global_position += velocity * delta
	
	if global_position.y <= 0.5:
		global_position.y = 0.5
		velocity = Vector3.ZERO

func explode() -> void:
	var bodies = area.get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("take_damage"):
			var dist = global_position.distance_to(body.global_position)
			if dist < explosion_radius:
				var dmg = int(damage * (1.0 - dist / explosion_radius))
				body.take_damage(dmg, owner_id)
	
	queue_free()
