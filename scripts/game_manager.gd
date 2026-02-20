extends Node

const WIN_SCORE = 3
const MATCH_TIME = 480

enum GameState { MENU, LOBBY, PLAYING, SCOREBARD }

var current_state := GameState.MENU
var red_score := 0
var blue_score := 0
var match_timer := MATCH_TIME
var is_paused := false

var local_team : int = 0

signal state_changed(new_state)
signal score_updated(red, blue)
signal timer_updated(seconds)
signal match_ended(winner_team)

func start_match() -> void:
	current_state = GameState.PLAYING
	red_score = 0
	blue_score = 0
	match_timer = MATCH_TIME
	emit_signal("score_updated", red_score, blue_score)
	emit_signal("state_changed", current_state)
	
	if NetworkManager.is_host:
		start_match_timer()

func start_match_timer() -> void:
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_match_timer_tick)
	add_child(timer)
	timer.start()

func _on_match_timer_tick() -> void:
	if current_state != GameState.PLAYING:
		return
	
	match_timer -= 1
	emit_signal("timer_updated", match_timer)
	
	if red_score >= WIN_SCORE:
		end_match(0)
	elif blue_score >= WIN_SCORE:
		end_match(1)
	elif match_timer <= 0:
		if red_score > blue_score:
			end_match(0)
		elif blue_score > red_score:
			end_match(1)
		else:
			end_match(-1)

func add_score(team: int) -> void:
	if team == 0:
		red_score += 1
	else:
		blue_score += 1
	
	emit_signal("score_updated", red_score, blue_score)
	
	if red_score >= WIN_SCORE:
		end_match(0)
	elif blue_score >= WIN_SCORE:
		end_match(1)

func end_match(winner: int) -> void:
	current_state = GameState.SCOREBARD
	emit_signal("match_ended", winner)
	emit_signal("state_changed", current_state)

func return_to_menu() -> void:
	current_state = GameState.MENU
	red_score = 0
	blue_score = 0
	match_timer = MATCH_TIME
	emit_signal("state_changed", current_state)
