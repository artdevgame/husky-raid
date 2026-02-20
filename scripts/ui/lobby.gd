extends Control

@onready var player_list = $PlayerList
@onready var start_button = $StartButton
@onready var leave_button = $LeaveButton

var players : Array = []

func _ready() -> void:
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	refresh_player_list()

func refresh_player_list() -> void:
	for child in player_list.get_children():
		child.queue_free()
	
	if NetworkManager.is_host:
		for peer_id in NetworkManager.peers:
			add_player_entry(peer_id, "Player " + str(peer_id))
		add_player_entry(NetworkManager.local_player_id, "Host (You)")
	else:
		add_player_entry(NetworkManager.local_player_id, "Player (You)")

func add_player_entry(id: int, name: String) -> void:
	var label = Label.new()
	label.text = name + " - " + ("Ready" if is_player_ready(id) else "Not Ready")
	player_list.add_child(label)

func is_player_ready(id: int) -> bool:
	return NetworkManager.peers.get(id, {}).get("ready", false)

func _on_player_connected(player_id: int, info: Dictionary) -> void:
	refresh_player_list()

func _on_player_disconnected(player_id: int) -> void:
	refresh_player_list()

func _on_start_button_pressed() -> void:
	if not NetworkManager.is_host:
		return
	
	GameManager.start_match()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_leave_button_pressed() -> void:
	NetworkManager.multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
