@tool
extends EditorPlugin


var export_puzzle_data_btn: Button = Button.new()

var puzzle_import_plugin

func _enter_tree() -> void:
	export_puzzle_data_btn.pressed.connect(export_puzzle_data)
	export_puzzle_data_btn.text = "D"
	add_control_to_container(CONTAINER_TOOLBAR, export_puzzle_data_btn)
	export_puzzle_data_btn.get_parent().move_child(export_puzzle_data_btn, export_puzzle_data_btn.get_index() - 2)

	puzzle_import_plugin = preload("puzzle_import.gd").new()
	add_import_plugin(puzzle_import_plugin)


func _exit_tree() -> void:
	remove_control_from_container(CONTAINER_TOOLBAR, export_puzzle_data_btn)
	remove_import_plugin(puzzle_import_plugin)
	puzzle_import_plugin = null


func export_puzzle_data() -> void:
	print("-------------------------------------------------")
	Log.info("[PrintPuzzleData]", Time.get_time_string_from_system())
	var edited_scene := EditorInterface.get_edited_scene_root()
	StatLogger.export_puzzle_data()
	print("-------------------------------------------------")
