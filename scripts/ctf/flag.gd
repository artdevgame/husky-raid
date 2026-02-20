extends Area3D

class_name CTFFlag

enum FlagState { AT_BASE, CARRIED, DROPPED, RETURNING }

@export var team : int = 0
@export var return_time := 15.0

var state := FlagState.AT_BASE
var carrier : Node3D = null
var home_base : Node3D = null
var drop_timer := 0.0
var return_timer := 0.0

@onready var mesh := $FlagMesh
@onready var glow := $Glow

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	mesh.material_override = StandardMaterial3D.new()
	update_visuals()

func _process(delta: float) -> void:
	match state:
		FlagState.CARRIED:
			if carrier:
				global_position = carrier.global_position + Vector3(0, 1.5, -0.5)
			else:
				state = FlagState.DROPPED
				drop_timer = return_time
		FlagState.DROPPED:
			drop_timer -= delta
			if drop_timer <= 0:
				start_return()
		FlagState.RETURNING:
			var direction = (home_base.global_position - global_position).normalized()
			global_position += direction * 10.0 * delta
			if global_position.distance_to(home_base.global_position) < 1.0:
				state = FlagState.AT_BASE
				update_visuals()

func _on_area_entered(area: Area3D) -> void:
	if state == FlagState.AT_BASE:
		return
	
	if area.has_method("pickup_flag"):
		area.pickup_flag(self)

func pickup_flag(player: Node3D) -> void:
	if state == FlagState.AT_BASE:
		carrier = player
		state = FlagState.CARRIED
		update_visuals()

func drop_flag() -> void:
	carrier = null
	state = FlagState.DROPPED
	drop_timer = return_time

func start_return() -> void:
	state = FlagState.RETURNING
	SoundEffects.play_flag_return()

func capture_flag() -> void:
	state = FlagState.AT_BASE
	carrier = null
	global_position = home_base.global_position
	update_visuals()

func update_visuals() -> void:
	var team_color = Color.RED if team == 0 else Color.BLUE
	
	match state:
		FlagState.AT_BASE:
			visible = true
			mesh.material_override.albedo_color = team_color
			glow.light_color = team_color
		FlagState.CARRIED:
			visible = true
		FlagState.DROPPED:
			visible = true
			mesh.material_override.albedo_color = Color.YELLOW
			glow.light_color = Color.YELLOW
		FlagState.RETURNING:
			visible = true
			mesh.material_override.albedo_color = Color.GREEN
			glow.light_color = Color.GREEN
