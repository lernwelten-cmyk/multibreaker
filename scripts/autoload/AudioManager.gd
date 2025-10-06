extends Node
## Global audio manager
##
## Singleton that handles all sound effects and background music.
## Accessible globally via AudioManager.play_sfx("sound_name")

# Audio players
var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

# SFX dictionary (will be populated when sound files are added)
var sfx: Dictionary = {
	# "ball_bounce": preload("res://assets/sounds/ball_bounce.ogg"),
	# "brick_break": preload("res://assets/sounds/brick_break.ogg"),
	# "shoot": preload("res://assets/sounds/shoot.ogg"),
	# "level_complete": preload("res://assets/sounds/level_complete.ogg"),
	# "game_over": preload("res://assets/sounds/game_over.ogg"),
}

# Volume settings (0.0 to 1.0)
var sfx_volume: float = 1.0
var music_volume: float = 0.7


func _ready() -> void:
	_setup_audio_players()
	_setup_audio_buses()
	print("AudioManager initialized")


## Setup audio player nodes
func _setup_audio_players() -> void:
	# SFX Player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	add_child(sfx_player)

	# Music Player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)


## Setup audio buses (SFX and Music)
func _setup_audio_buses() -> void:
	# Create SFX bus if it doesn't exist
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")

	# Create Music bus if it doesn't exist
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")

	# Set initial volumes
	set_sfx_volume(sfx_volume)
	set_music_volume(music_volume)


## Play a sound effect by name
func play_sfx(sound_name: String) -> void:
	if not sfx.has(sound_name):
		push_warning("Sound effect not found: %s" % sound_name)
		return

	if sfx_player.playing:
		# Create a temporary player for overlapping sounds
		var temp_player = AudioStreamPlayer.new()
		temp_player.stream = sfx[sound_name]
		temp_player.bus = "SFX"
		add_child(temp_player)
		temp_player.play()
		# Auto-cleanup after playback
		temp_player.finished.connect(func(): temp_player.queue_free())
	else:
		sfx_player.stream = sfx[sound_name]
		sfx_player.play()


## Play background music
func play_music(music_stream: AudioStream, loop: bool = true) -> void:
	music_player.stream = music_stream
	if music_stream is AudioStreamOggVorbis or music_stream is AudioStreamMP3:
		# Enable looping for supported formats
		if loop:
			music_stream.loop = true
	music_player.play()


## Stop background music
func stop_music() -> void:
	music_player.stop()


## Pause background music
func pause_music() -> void:
	music_player.stream_paused = true


## Resume background music
func resume_music() -> void:
	music_player.stream_paused = false


## Set SFX volume (0.0 to 1.0)
func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))


## Set music volume (0.0 to 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))


## Mute all audio
func mute_all() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)


## Unmute all audio
func unmute_all() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)


## Check if audio is muted
func is_muted() -> bool:
	return AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))
