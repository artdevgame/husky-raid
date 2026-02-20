extends Node3D

@onready var arena = $Arena
@onready var hud = $HUD
@onready var spawn_manager = $SpawnManager

var player_scene : PackedScene

func _ready() -> void:
	player_scene = preload("res://scenes/player.tscn")
	
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.timer_updated.connect(_on_timer_updated)
	GameManager.match_ended.connect(_on_match_ended)
	
	spawn_players()

func spawn_players() -> void:
	var teams = NetworkManager.assign_teams()
	
	for player_id in teams:
		var team = teams[player_id]
		spawn_player(player_id, team)

func spawn_player(player_id: int, team: int) -> void:
	var player = player_scene.instantiate()
	player.team = team
	player.player_id = player_id
	
	player.position = get_spawn_position(team)
	
	add_child(player)
	
	if player_id == NetworkManager.local_player_id:
		setup_local_player(player)

func get_spawn_position(team: int) -> Vector3:
	var spawn_points : Array
	
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

func setup_local_player(player) -> void:
	var camera = player.get_node("CameraPivot/Camera3D")
	camera.current = true

func _on_score_updated(red: int, blue: int) -> void:
	if hud:
		hud.update_score(red, blue)

func _on_timer_updated(seconds: int) -> void:
	if hud:
		hud.update_timer(seconds)

func _on_match_ended(winner: int) -> void:
	get_tree().change_scene_to_file("res://scenes/scoreboard.tscn")
