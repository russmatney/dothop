@tool
extends EditorImportPlugin

enum Presets { DEFAULT }

func _get_importer_name() -> String:
	return "dothop.puzzle_set"

func _get_visible_name() -> String:
	return "Puzzle Set"

func _get_recognized_extensions() -> PackedStringArray:
	return ["puzz"]

func _get_save_extension() -> String:
	return "res"

func _get_resource_type() -> String:
	return "Resource"

func _get_preset_count() -> int:
	return Presets.size()

func _get_preset_name(preset_index: int) -> String:
	match preset_index:
		Presets.DEFAULT:
			return "Default"
		_:
			return "Unknown"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	match preset_index:
		Presets.DEFAULT:
			return []
		_:
			return []

func _get_option_visibility(s: String, sn: StringName, d: Dictionary) -> bool:
	return true

func _get_priority() -> float:
	return 1.0

func _can_import_threaded() -> bool:
	return true

func _get_import_order() -> int:
	return 1


##############################################################
## import

func _import(source_file: String, save_path: String, options: Dictionary, r_platform_variants: Array[String], r_gen_files: Array[String]) -> int:
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var psd := PuzzleSetData.from_path(source_file)
	Log.info("Imported Puzzle Set Data", psd)
	return ResourceSaver.save(psd, "%s.%s" % [save_path, _get_save_extension()])
