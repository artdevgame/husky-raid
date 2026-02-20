extends Control

@onready var winner_label = $WinnerLabel
@onready var score_label = $ScoreLabel

func _ready() -> void:
	var red_score = GameManager.red_score
	var blue_score = GameManager.blue_score
	
	score_label.text = "%d - %d" % [red_score, blue_score]
	
	if red_score > blue_score:
		winner_label.text = "RED TEAM WINS!"
		winner_label.add_theme_color_override("font_color", Color.RED)
	elif blue_score > red_score:
		winner_label.text = "BLUE TEAM WINS!"
		winner_label.add_theme_color_override("font_color", Color.BLUE)
	else:
		winner_label.text = "IT'S A DRAW!"
		winner_label.add_theme_color_override("font_color", Color.WHITE)

func _on_return_button_pressed() -> void:
	GameManager.return_to_menu()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
