@tool
class_name SaveGame

# referenced:
# https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
# https://github.com/bitbrain/godot-gamejam/blob/5667a7c797e13e335ab0380d52492fa04bfc78f4/godot/savegame/save_game.gd

const DATA_PATH: String = "user://savegame.save"
const data_dict_key: String = "datadict"

static func delete_save() -> void:
	Log.pr("Deleting save data....")
	DirAccess.remove_absolute(DATA_PATH)
	Log.pr("Deleted save data.")

static func has_save() -> bool:
	return FileAccess.file_exists(DATA_PATH)

static func save_game(_tree: SceneTree, data: Dictionary) -> void:
	# TODO consider encryption

	Log.pr("Saving game....")
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.WRITE)

	for key: String in data.keys():
		var val: Array = [data_dict_key, key, data.get(key)]
		file.store_line(JSON.stringify(val))
	Log.pr("Game saved.")

static func load_game(_tree: SceneTree) -> Dictionary:
	if not has_save():
		Log.pr("No save game found")
		return {}

	Log.pr("Loading saved data....")

	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)

	var data: Dictionary = {}

	while file.get_position() < file.get_length():
		var json: JSON = JSON.new()
		var err: int = json.parse(file.get_line())
		if err != OK:
			Log.error("JSON.parse error while loading save game", json.get_error_message())
			# How best to handle mangled save games?
			return {}
		var line: Array = json.get_data()

		if line is Array and len(line) == 3 and line[0] == data_dict_key:
			var key: Variant = line[1]
			var val: Variant = line[2]

			if key in data:
				Log.err("Found duplicate key in savegame data", key)
				# Probably want to reset data at this point
				return {}

			data[key] = val
		else:
			Log.warn("Some other save-game shape found, ignoring.")

	Log.info("Data loaded.", data)
	return data
