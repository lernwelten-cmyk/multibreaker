extends Node
## Global score manager
##
## Singleton that handles highscore persistence via JSON file storage.
## Accessible globally via ScoreManager.get_highscore(level_num)

const SAVE_PATH: String = "user://highscores.json"

# Highscore dictionary: { "1": 250, "2": 180, ... }
# Lower score = better (fewer attempts)
var highscores: Dictionary = {}

# Signals
## Emitted when a new highscore is set
signal highscore_updated(level: int, score: int)


func _ready() -> void:
	load_highscores()
	print("ScoreManager initialized")
	print("Highscores loaded from: %s" % SAVE_PATH)


## Save a highscore for a specific level
## Only saves if it's a new highscore (lower score = better)
func save_highscore(level: int, score: int) -> bool:
	var level_key = str(level)

	# Check if this is a new highscore (lower is better, or first score for this level)
	if not highscores.has(level_key) or score < highscores[level_key]:
		highscores[level_key] = score
		save_highscores()
		highscore_updated.emit(level, score)
		print("New highscore for level %d: %d" % [level, score])
		return true

	return false


## Get the highscore for a specific level
## Returns 0 if no highscore exists yet
func get_highscore(level: int) -> int:
	var level_key = str(level)
	return highscores.get(level_key, 0)


## Check if a score is a new highscore
func is_new_highscore(level: int, score: int) -> bool:
	var level_key = str(level)
	return not highscores.has(level_key) or score < highscores[level_key]


## Load highscores from disk
func load_highscores() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found, starting with empty highscores")
		highscores = {}
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open highscores file: %s" % FileAccess.get_open_error())
		highscores = {}
		return

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		push_error("Failed to parse highscores JSON: %s" % json.get_error_message())
		highscores = {}
		return

	highscores = json.data
	print("Loaded %d highscores" % highscores.size())


## Save highscores to disk
func save_highscores() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save highscores file: %s" % FileAccess.get_open_error())
		return

	var json_string = JSON.stringify(highscores, "\t")
	file.store_string(json_string)
	file.close()
	print("Highscores saved to: %s" % SAVE_PATH)


## Clear all highscores
func clear_all_highscores() -> void:
	highscores.clear()
	save_highscores()
	print("All highscores cleared")


## Get all highscores as a sorted array
## Returns array of dictionaries: [{"level": 1, "score": 250}, ...]
func get_all_highscores_sorted() -> Array:
	var scores_array: Array = []

	for level_key in highscores.keys():
		scores_array.append({
			"level": int(level_key),
			"score": highscores[level_key]
		})

	# Sort by level number
	scores_array.sort_custom(func(a, b): return a["level"] < b["level"])

	return scores_array
