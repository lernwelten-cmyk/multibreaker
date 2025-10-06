extends Node
## Utility for JSON serialization
##
## Provides static helper functions for saving/loading arbitrary data to/from JSON files.
## Used for game settings, level progress, and other persistent data.

## Save a dictionary to a JSON file
## Returns true on success, false on failure
static func save_data(data: Dictionary, path: String) -> bool:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s (Error: %s)" % [path, FileAccess.get_open_error()])
		return false

	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()

	print("Data saved to: %s" % path)
	return true


## Load a dictionary from a JSON file
## Returns the loaded dictionary, or an empty dictionary on failure
static func load_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("File does not exist: %s" % path)
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: %s (Error: %s)" % [path, FileAccess.get_open_error()])
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		push_error("Failed to parse JSON from %s: %s (Line %d)" % [path, json.get_error_message(), json.get_error_line()])
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("JSON data in %s is not a dictionary" % path)
		return {}

	print("Data loaded from: %s" % path)
	return json.data


## Delete a save file
## Returns true if file was deleted, false if file didn't exist or deletion failed
static func delete_save_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		push_warning("Cannot delete non-existent file: %s" % path)
		return false

	var dir = DirAccess.open("user://")
	if dir == null:
		push_error("Failed to access user directory")
		return false

	var error = dir.remove(path)
	if error != OK:
		push_error("Failed to delete file %s: Error code %d" % [path, error])
		return false

	print("Deleted save file: %s" % path)
	return true


## Check if a save file exists
static func save_file_exists(path: String) -> bool:
	return FileAccess.file_exists(path)


## Get the user data directory path
## This is where Godot stores user:// files
static func get_user_data_path() -> String:
	return OS.get_user_data_dir()
