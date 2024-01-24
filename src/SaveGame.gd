@tool
class_name SaveGame

# referenced: https://github.com/bitbrain/godot-gamejam/blob/5667a7c797e13e335ab0380d52492fa04bfc78f4/godot/savegame/save_game.gd

const DATA_PATH = "user://savegame.save"

static func delete_save():
	Log.pr("Deleting save data....")
	DirAccess.remove_absolute(DATA_PATH)
	Log.pr("Deleted save data.")

static func has_save():
	return FileAccess.file_exists(DATA_PATH)

static func save_game(_tree, data):
	# TODO consider encryption

	Log.pr("Saving game....")
	var file = FileAccess.open(DATA_PATH, FileAccess.WRITE)

	# TODO do we need to clear the file first?
	for key in data.keys():
		var val = [key, data.get(key)]
		file.store_line(JSON.stringify(val))
	Log.pr("Game saved.")

static func load_game(_tree) -> Dictionary:
	if not has_save():
		Log.pr("No save game found")
		return {}

	Log.pr("Loading saved data....")

	var file = FileAccess.open(DATA_PATH, FileAccess.READ)

	var data = {}

	while file.get_position() < file.get_length():
		var json_conv = JSON.new()
		json_conv.parse(file.get_line())
		var line = json_conv.get_data()

		# TODO validation/error handling
		var key = line[0]
		var val = line[1]

		if key in data:
			Log.err("Found duplicate key in savegame data", key)
			# Probably want to reset data at this point
			return {}

		data[key] = val

	Log.pr("Data loaded.")
	return data
