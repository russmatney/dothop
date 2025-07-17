@tool
extends EditorPlugin


var puzzle_data_btn: Button = Button.new()

func _enter_tree() -> void:
	puzzle_data_btn.pressed.connect(log_puzzle_data)
	puzzle_data_btn.text = "D"
	add_control_to_container(CONTAINER_TOOLBAR, puzzle_data_btn)
	puzzle_data_btn.get_parent().move_child(puzzle_data_btn, puzzle_data_btn.get_index() - 2)


func _exit_tree() -> void:
	remove_control_from_container(CONTAINER_TOOLBAR, puzzle_data_btn)


func log_puzzle_data() -> void:
	print("-------------------------------------------------")
	Log.info("[PrintPuzzleData]", Time.get_time_string_from_system())
	var edited_scene := EditorInterface.get_edited_scene_root()
	StatLogger.log_puzzle_data()
	print("-------------------------------------------------")
