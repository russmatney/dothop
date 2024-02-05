@tool
extends CanvasLayer

## vars ################################################

@onready var world_list = $%WorldList
@onready var puzzle_map = $%PuzzleMap
@onready var world_map = $%WorldMap
@onready var puzzle_list_container = $%PuzzleListContainer
@onready var puzzle_list = $%PuzzleList
@onready var puzzle_set_icon = $%PuzzleSetIcon

## ready ################################################

func _ready():
	world_list.button_focused.connect(on_button_focused)
	world_list.button_unfocused.connect(on_button_unfocused)

	if not Engine.is_editor_hint():
		reset_map()
		set_focus()

func set_focus():
	world_list.set_focus()

## input ###################################################################

func _unhandled_input(event):
	if not Engine.is_editor_hint() and Trolls.is_pause(event):
		if not get_tree().paused:
			Navi.pause()
			get_viewport().set_input_as_handled()

## button focus/unfocus ################################################

func on_button_focused(_button, item):
	show_puzzle_set(item.puzzle_set)

func on_button_unfocused(_button, _item):
	reset_map()

## show puzzle set ################################################

var puzzle_label = preload("res://src/menus/worldmap/PuzzleLabel.tscn")

func show_puzzle_set(puzzle_set):
	# update world map
	var markers = world_map.get_markers()
	for m in markers:
		if m.puzzle_set.get_entity_id() == puzzle_set.get_entity_id():
			world_map.current_marker = m
			break

	# update puzzle map
	markers = puzzle_map.get_markers()
	for m in markers:
		if m.puzzle_set.get_entity_id() == puzzle_set.get_entity_id():
			puzzle_map.current_marker = m
			break

	# update puzzle_set popup container
	puzzle_list_container.set_visible(true)

	# icon
	puzzle_set_icon.set_texture(puzzle_set.get_icon_texture())

	# list of puzzles
	U.remove_children(puzzle_list)
	for puzzle in puzzle_set.get_puzzles():
		var label = puzzle_label.instantiate()
		label.text = "[center]%s[/center]" % (puzzle.idx + 1)
		puzzle_list.add_child(label)

func reset_map():
	world_map.current_marker = null
	puzzle_map.current_marker = null
	puzzle_list_container.set_visible(false)
	U.remove_children(puzzle_list)
