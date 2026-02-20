extends Control

@onready var title = $VBoxContainer/Title
@onready var host_button = $VBoxContainer/HostButton
@onready var join_button = $VBoxContainer/JoinButton
@onready var ip_label = $VBoxContainer/IPLabel
@onready var ip_input = $VBoxContainer/IPInput
@onready var connect_button = $VBoxContainer/ConnectButton
@onready var back_button = $VBoxContainer/BackButton
@onready var game_code_label = $VBoxContainer/GameCodeLabel

var state = "menu"

func _ready() -> void:
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.connection_failed.connect(_on_connection_failed)

func show_menu() -> void:
	state = "menu"
	host_button.visible = true
	join_button.visible = true
	ip_label.visible = false
	ip_input.visible = false
	connect_button.visible = false
	back_button.visible = false
	game_code_label.visible = false

func show_host_menu() -> void:
	state = "host"
	host_button.visible = false
	join_button.visible = false
	ip_label.visible = false
	ip_input.visible = false
	connect_button.visible = false
	back_button.visible = true
	
	NetworkManager.create_game()
	var code = NetworkManager.get_game_code()
	game_code_label.text = "Game Code: " + code
	game_code_label.visible = true

func show_join_menu() -> void:
	state = "join"
	host_button.visible = false
	join_button.visible = false
	ip_label.visible = true
	ip_input.visible = true
	connect_button.visible = true
	back_button.visible = true

func _on_host_button_pressed() -> void:
	show_host_menu()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_join_button_pressed() -> void:
	show_join_menu()

func _on_connect_button_pressed() -> void:
	var ip = ip_input.text
	NetworkManager.join_game(ip)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_back_button_pressed() -> void:
	show_menu()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_player_connected(player_id: int, info: Dictionary) -> void:
	print("Player connected: ", player_id)

func _on_connection_failed() -> void:
	print("Connection failed")
	show_menu()
