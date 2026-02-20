extends Node3D

func _ready() -> void:
	setup_bases()

func setup_bases() -> void:
	var red_base = $RedBase
	var blue_base = $BlueBase
	var red_flag = $RedFlag
	var blue_flag = $BlueFlag
	
	red_base.team = 0
	blue_base.team = 1
	
	if red_flag and red_flag.has_method("pickup_flag"):
		red_flag.team = 0
		red_flag.home_base = red_base
	
	if blue_flag and blue_flag.has_method("pickup_flag"):
		blue_flag.team = 1
		blue_flag.home_base = blue_base
