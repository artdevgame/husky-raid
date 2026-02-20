extends CanvasLayer

@onready var score_label = $ScorePanel/ScoreLabel
@onready var timer_label = $TimerLabel
@onready var health_label = $HealthPanel/HealthLabel
@onready var weapon_label = $WeaponPanel/WeaponLabel
@onready var kill_feed = $KillFeed
@onready var radar_label = $RadarPanel/RadarLabel

func update_score(red: int, blue: int) -> void:
	score_label.text = "RED: %d   BLUE: %d" % [red, blue]

func update_timer(seconds: int) -> void:
	var mins = seconds / 60
	var secs = seconds % 60
	timer_label.text = "%d:%02d" % [mins, secs]

func update_health(health: int, shields: int) -> void:
	health_label.text = "Health: %d/%d" % [health, shields]

func update_weapon(weapon_name: String, ammo: int, reserve: int) -> void:
	weapon_label.text = "%s: %d/%d" % [weapon_name, ammo, reserve]

func add_kill_feed_entry(killer: String, victim: String, weapon: String) -> void:
	var label = Label.new()
	label.text = "%s killed %s with %s" % [killer, victim, weapon]
	kill_feed.add_child(label)
	
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(label):
		label.queue_free()

func update_radar(teammates: Array, enemies: Array, flags: Array) -> void:
	radar_label.text = "Radar\n%d teammates\n%d enemies" % [teammates.size(), enemies.size()]
