@tool
extends EditorPlugin


var export_puzzle_data_btn: Button = Button.new()

var puzzle_import_plugin

func _enter_tree() -> void:
	export_puzzle_data_btn.pressed.connect(export_puzzle_data_in_background)
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
	Log.info("[ExportPuzzleData]", Time.get_time_string_from_system())
	StatLogger.export_puzzle_data()
	print("-------------------------------------------------")

var data_export_thread: Thread

func export_puzzle_data_in_background() -> void:
	print("-------------------------------------------------")
	Log.info("[ExportPuzzleData] (in background)", Time.get_time_string_from_system())
	data_export_thread = StatLogger.export_puzzle_data_in_background()
	print("-------------------------------------------------")

func _process(_delta) -> void:
	if data_export_thread != null \
		# has started
		and data_export_thread.is_started() \
		# and has finished
		and not data_export_thread.is_alive():
		# join thread to prevent it leaking
		data_export_thread.wait_to_finish()
