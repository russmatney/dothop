@tool
extends CanvasLayer

## vars ################################################

@onready var puzzle_map = $%PuzzleMap
@onready var puzzle_list = $%PuzzleList
@onready var puzzle_set_icon = $%PuzzleSetIcon
@onready var puzzle_set_title = $%PuzzleSetTitle
@onready var start_puzzle_set_button = $%StartPuzzleSetButton

var current_puzzle_set = 0
var current_puzzle_set_idx = 0
@onready var puzzle_sets = Store.get_puzzle_sets()

## ready ################################################

func _ready():
	if not Engine.is_editor_hint():
		SoundManager.play_music(Music.late_night_radio)
		reset_map()

	set_puzzle_set()

	start_puzzle_set_button.pressed.connect(on_start_button_pressed)

	# TODO resume music when naving back to here
# 	visibility_changed.connect(on_visibility_changed)

# func on_visibility_changed():
# 	if not Engine.is_editor_hint() and get_children()[0].is_visible_in_tree():
# 		SoundManager.play_music(Music.late_night_radio)

func set_puzzle_set():
	current_puzzle_set_idx = clamp(current_puzzle_set_idx, 0, len(puzzle_sets) - 1)
	current_puzzle_set = puzzle_sets[current_puzzle_set_idx]
	show_puzzle_set(current_puzzle_set)

@onready var game_scene = preload("res://src/puzzle/GameScene.tscn")

func on_start_button_pressed():
	Navi.nav_to(game_scene, {setup=func(g):
		g.puzzle_set = current_puzzle_set,
		# TODO set puzzle_num to next puzzle num
		})

## input ###################################################################

func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if Trolls.is_pause(event):
			if not get_tree().paused:
				Navi.pause()
				get_viewport().set_input_as_handled()

		# handle moving around the UI

		if Trolls.is_move_right(event):
			current_puzzle_set_idx += 1
			set_puzzle_set()
		if Trolls.is_move_left(event):
			current_puzzle_set_idx -= 1
			set_puzzle_set()

## show puzzle set ################################################

var puzzle_label = preload("res://src/menus/worldmap/PuzzleLabel.tscn")

func show_puzzle_set(puzzle_set):
	# update puzzle map
	var markers = puzzle_map.get_markers()
	for m in markers:
		if m.puzzle_set.get_entity_id() == puzzle_set.get_entity_id():
			puzzle_map.current_marker = m
			break

	# title
	puzzle_set_title.text = "[center]%s[/center]" % puzzle_set.get_display_name()
	start_puzzle_set_button.text = puzzle_set.get_display_name()
	start_puzzle_set_button.grab_focus.call_deferred()

	var theme = puzzle_set.get_theme()

	# icon
	puzzle_set_icon.set_texture(theme.get_player_icon())

	# var label = puzzle_label.instantiate()
	# label.text = "[center]%s[/center]" % (puzzle.idx + 1)

	# TODO support moving the player icon among the levels
	# (maybe show a level-shape preview/popup?)

	# list of puzzles
	U.remove_children(puzzle_list)
	for puzzle in puzzle_set.get_puzzles():
		var icon = TextureRect.new()
		icon.set_custom_minimum_size(64.0 * Vector2.ONE)
		# TODO if complete/incomple, use get_dotted_icon()
		if puzzle_set.is_completed():
			icon.set_texture(theme.get_dotted_icon())
		else:
			icon.set_texture(theme.get_dot_icon())
		puzzle_list.add_child(icon)

func reset_map():
	puzzle_map.current_marker = null
	U.remove_children(puzzle_list)
	start_puzzle_set_button.release_focus.call_deferred()
