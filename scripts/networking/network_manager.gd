extends Node

const DEFAULT_PORT = 7777
const MAX_PLAYERS = 8

var is_host := false
var is_client := false
var peers : Dictionary = {}
var local_player_id := 0

signal player_connected(player_id, player_info)
signal player_disconnected(player_id)
signal connection_failed()
signal game_started()

enum Team { RED, BLUE }

func create_game() -> void:
	is_host = true
	is_client = false
	local_player_id = 1
	peers.clear()
	
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	if err != OK:
		print("Failed to create server: ", err)
		emit_signal("connection_failed")
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	print("Host created game on port ", DEFAULT_PORT)

func join_game(ip_address: String) -> void:
	is_host = false
	is_client = true
	local_player_id = 0
	peers.clear()
	
	var peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(ip_address, DEFAULT_PORT)
	if err != OK:
		print("Failed to create client: ", err)
		emit_signal("connection_failed")
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	print("Joining game at ", ip_address)

func get_game_code() -> String:
	var seed_val = Time.get_ticks_msec()
	var code = ""
	for i in range(6):
		code += char(65 + (seed_val % 26))
		seed_val = (seed_val * 1103515245 + 12345) % (1 << 31)
	return code

func _on_peer_connected(peer_id: int) -> void:
	print("Peer connected: ", peer_id)
	peers[peer_id] = {"ready": false}
	emit_signal("player_connected", peer_id, {"peer_id": peer_id})
	
	if peers.size() >= 1:
		emit_signal("game_started")

func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer disconnected: ", peer_id)
	peers.erase(peer_id)
	emit_signal("player_disconnected", peer_id)

func _on_connection_failed() -> void:
	print("Connection failed")
	emit_signal("connection_failed")

func _on_server_disconnected() -> void:
	print("Server disconnected")
	is_host = false
	is_client = false
	peers.clear()

func send_player_info(info: Dictionary) -> void:
	if is_host:
		peers[local_player_id] = info
	else:
		rpc_id(1, "receive_player_info", local_player_id, info)

@rpc("reliable")
func receive_player_info(player_id: int, info: Dictionary) -> void:
	peers[player_id] = info
	emit_signal("player_connected", player_id, info)

func get_player_team(player_id: int) -> Team:
	var num_red = 0
	var num_blue = 0
	
	for id in peers:
		if peers[id].get("team") == Team.RED:
			num_red += 1
		elif peers[id].get("team") == Team.BLUE:
			num_blue += 1
	
	if player_id == local_player_id:
		if num_red <= num_blue:
			return Team.RED
		else:
			return Team.BLUE
	
	if peers.get(player_id, {}).get("team") != null:
		return peers[player_id].team
	
	return Team.RED

func assign_teams() -> Dictionary:
	var team_counts = {Team.RED: 0, Team.BLUE: 0}
	var assignments = {}
	
	var all_ids = peers.keys()
	all_ids.append(local_player_id)
	all_ids.sort()
	
	for id in all_ids:
		if team_counts[Team.RED] <= team_counts[Team.BLUE]:
			assignments[id] = Team.RED
			team_counts[Team.RED] += 1
		else:
			assignments[id] = Team.BLUE
			team_counts[Team.BLUE] += 1
	
	return assignments
