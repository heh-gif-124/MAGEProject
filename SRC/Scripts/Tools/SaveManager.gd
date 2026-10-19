extends Node

var save_data: Dictionary = create_new_dictionary()

func get_save_path(slot: int) -> String:
	return "user://file%d.json" % slot

func has_save_file(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))

# Initialize a fresh save slot and write it to disk
func create_and_save(slot: int) -> void:
	save_data = create_new_dictionary()
	save_data["meta"]["slot_name"] = "Slot %d" % slot
	save_game(slot)

# Save current save_data to a specific slot
func save_game(slot: int) -> void:
	var path: String = get_save_path(slot)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	if not file:
		push_error("Failed to open file for writing: %s (Error: %d)" % [path, FileAccess.get_open_error()])
		return

	var json_string: String = JSON.stringify(save_data, "\t") # Tab indent makes JSON human-readable for debugging
	file.store_string(json_string)
	file.close()
	print("Saved successfully to ", path)

# Load data from a specific slot into save_data
func load_game(slot: int) -> void:
	var path: String = get_save_path(slot)
	if not FileAccess.file_exists(path):
		push_error("Save file does not exist: ", path)
		return

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open file for reading: ", path)
		return

	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	if json.parse(json_string) == OK and typeof(json.data) == TYPE_DICTIONARY:
		apply_loaded_save(json.data)
		print("Loaded ", path, " successfully!")
	else:
		push_error("Failed to parse JSON in ", path)

func apply_loaded_save(data: Dictionary) -> void:
	save_data = data
	var player_stats: Dictionary = save_data.get("player", {})
	print("Loaded player: ", player_stats.get("playername", "Unknown"))

func delete_save_slot(slot: int) -> void:
	var path: String = get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Deleted save file for slot ", slot)

func create_new_dictionary() -> Dictionary:
	return {
		"meta": {
			"version": "1.0.0",
			"timestamp": Time.get_datetime_string_from_system(true),
			"playtime_seconds": 0,
			"slot_name": "Slot 1"
		},
		"player": {
			"playername": "Starlight",
			"level": 1,
			"hp": 100,
			"max_hp": 100
		},
		"inventory": {
			"gold": 0,
			"equipment": {
				"weapon": "DevilsKnife",
				"armor": "Ja-Aura"
			}
		},
		"world": {
			"current_scene": "res://Scenes/MainMenu.tscn",
			"unlocked_zones": [],
			"flags": {}
		}
	}
