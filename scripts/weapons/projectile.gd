extends Area3D

class_name Projectile

var velocity := Vector3.ZERO
var damage := 100
var explosion_radius := 5.0
var owner_id : int = 0
var lifetime := 5.0

@onready var mesh := $MeshInstance3D
@onready var area := $Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += velocity * delta

func _on_body_entered(body: Node3D) -> void:
	if body.get_instance_id() != owner_id:
		explode()

func explode() -> void:
	var bodies = area.get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("take_damage"):
			var dist = global_position.distance_to(body.global_position)
			if dist < explosion_radius:
				var dmg = int(damage * (1.0 - dist / explosion_radius))
				body.take_damage(dmg, owner_id)
	
	queue_free()
