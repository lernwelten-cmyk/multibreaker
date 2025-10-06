extends Node
## Global game state manager
##
## Singleton that tracks score, level progression, attempts, and overall game status.
## Accessible globally via GameManager.property_name

# Game state variables
var current_level: int = 1
var attempts: int = 0
var score: int = 0
var game_status: String = "idle"  # idle, playing, paused, complete, game_over

# Level configuration
const MAX_LEVELS: int = 5
const LEVEL_PATH_TEMPLATE: String = "res://scenes/levels/Level%02d.tscn"

# Signals
## Emitted when score changes
signal score_changed(new_score: int)
## Emitted when attempts counter increases
signal attempts_incremented(new_attempts: int)
## Emitted when current level is completed (used in M3+)
@warning_ignore("unused_signal")
signal level_completed
## Emitted when game over condition is met (used in M4+)
@warning_ignore("unused_signal")
signal game_over
## Emitted when game status changes
signal status_changed(new_status: String)


func _ready() -> void:
	print("GameManager initialized")


## Add points to the current score
func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)


## Increment the attempts counter
func increment_attempts() -> void:
	attempts += 1
	attempts_incremented.emit(attempts)


## Reset score and attempts for the current level
func reset_level() -> void:
	score = 0
	attempts = 0
	set_status("idle")


## Load a specific level by number
func load_level(level_num: int) -> void:
	if level_num < 1 or level_num > MAX_LEVELS:
		push_error("Invalid level number: %d" % level_num)
		return

	current_level = level_num
	reset_level()

	var level_path = LEVEL_PATH_TEMPLATE % level_num
	if not ResourceLoader.exists(level_path):
		push_error("Level file not found: %s" % level_path)
		return

	get_tree().change_scene_to_file(level_path)


## Load the next level in sequence
func load_next_level() -> void:
	if current_level >= MAX_LEVELS:
		print("All levels completed!")
		set_status("complete")
		return

	load_level(current_level + 1)


## Restart the current level
func restart_current_level() -> void:
	load_level(current_level)


## Set game status and emit signal
func set_status(new_status: String) -> void:
	if game_status != new_status:
		game_status = new_status
		status_changed.emit(new_status)


## Check if a level exists
func level_exists(level_num: int) -> bool:
	if level_num < 1 or level_num > MAX_LEVELS:
		return false
	var level_path = LEVEL_PATH_TEMPLATE % level_num
	return ResourceLoader.exists(level_path)
