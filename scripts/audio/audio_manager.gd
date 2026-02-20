extends Node

var music_bus_index : int = 0
var sfx_bus_index : int = 1

var music_volume : float = 0.0
var sfx_volume : float = 0.0

var current_music : AudioStreamPlayer
var music_fade_tween : Tween

func _ready() -> void:
	setup_audio_buses()
	setup_music_player()

func setup_audio_buses() -> void:
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	if music_bus_index == -1:
		music_bus_index = 0
	if sfx_bus_index == -1:
		sfx_bus_index = 0

func setup_music_player() -> void:
	current_music = AudioStreamPlayer.new()
	current_music.bus = "Music"
	add_child(current_music)

func play_music(stream: AudioStream, fade_duration: float = 1.0) -> void:
	if not stream:
		return
	
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(self, "music_volume", -40.0, fade_duration)
	
	await music_fade_tween.finished
	
	current_music.stream = stream
	current_music.play()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(self, "music_volume", 0.0, fade_duration)

func stop_music(fade_duration: float = 1.0) -> void:
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(self, "music_volume", -40.0, fade_duration)

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		return
	
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	player.play()
	
	player.finished.connect(player.queue_free)

func set_music_volume(value: float) -> void:
	music_volume = value
	AudioServer.set_bus_volume_db(music_bus_index, value)

func set_sfx_volume(value: float) -> void:
	sfx_volume = value
	AudioServer.set_bus_volume_db(sfx_bus_index, value)
