extends Area3D

class_name FlagBase

@export var team : int = 0
@export var return_capture_time := 2.5

var own_flag : CTFFlag = null
var enemy_flag : CTFFlag = null
var capture_progress := 0.0
var is_capturing := false

@onready var capture_timer_label : Label3D = null

func _ready() -> void:
	if has_node("CaptureTimer"):
		capture_timer_label = $CaptureTimer
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta: float) -> void:
	if is_capturing and enemy_flag and enemy_flag.state == CTFFlag.FlagState.CARRIED:
		capture_progress += delta / return_capture_time
		if capture_timer_label:
			capture_timer_label.text = str(ceil(return_capture_time * (1.0 - capture_progress)))
			capture_timer_label.visible = true
		
		if capture_progress >= 1.0:
			complete_capture()
	else:
		capture_progress = 0.0
		if capture_timer_label:
			capture_timer_label.visible = false

func _on_area_entered(area: Area3D) -> void:
	if area is CTFFlag:
		var flag = area as CTFFlag
		
		if flag.team != team:
			enemy_flag = flag
			if flag.state == CTFFlag.FlagState.CARRIED:
				is_capturing = true
		elif flag.team == team:
			own_flag = flag
			if flag.state == CTFFlag.FlagState.DROPPED:
				flag.start_return()
			elif flag.state == CTFFlag.FlagState.AT_BASE:
				pass

func _on_area_exited(area: Area3D) -> void:
	if area is CTFFlag:
		var flag = area as CTFFlag
		
		if flag.team != team:
			enemy_flag = null
			is_capturing = false
		elif flag.team == team:
			own_flag = null
			is_capturing = false

func complete_capture() -> void:
	if enemy_flag:
		enemy_flag.capture_flag()
		GameManager.add_score(team)
		SoundEffects.play_flag_capture()
	
	is_capturing = false
	capture_progress = 0.0
	if capture_timer_label:
		capture_timer_label.visible = false
