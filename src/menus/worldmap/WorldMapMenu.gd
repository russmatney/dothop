@tool
extends CanvasLayer

## vars ################################################

@onready var puzzle_map = $%PuzzleMap
@onready var puzzle_list = $%PuzzleList
@onready var puzzle_set_icon = $%PuzzleSetIcon
@onready var puzzle_set_title = $%PuzzleSetTitle
@onready var start_puzzle_set_button = $%StartPuzzleSetButton
@onready var start_puzzle_n_label = $%StartPuzzleNLabel

@onready var next_puzzle_set_button = $%NextPuzzleSetButton
@onready var previous_puzzle_set_button = $%PreviousPuzzleSetButton

var current_puzzle_set: PuzzleSet
var current_puzzle_set_idx = 0
var current_puzzle_index = 0
@onready var puzzle_sets = Store.get_puzzle_sets()

## ready ################################################

func _ready():
	if not Engine.is_editor_hint():
		SoundManager.play_music(Music.late_night_radio, 2.0)
		reset_map()

	var next_to_complete_puzzle_idx = 0
	for i in len(puzzle_sets):
		var ps = puzzle_sets[i]
		if not ps.is_completed():
			next_to_complete_puzzle_idx = i
			break

	attempt_move_to_puzzle_set(next_to_complete_puzzle_idx)

	start_puzzle_set_button.pressed.connect(start_selected_puzzle)
	next_puzzle_set_button.pressed.connect(show_next_puzzle_set)
	previous_puzzle_set_button.pressed.connect(show_previous_puzzle_set)

func show_next_puzzle_set():
	attempt_move_to_puzzle_set(1)

func show_previous_puzzle_set():
	attempt_move_to_puzzle_set(-1)

	# TODO resume music when naving back to here
# 	visibility_changed.connect(on_visibility_changed)

# func on_visibility_changed():
# 	if not Engine.is_editor_hint() and get_children()[0].is_visible_in_tree():
# 		SoundManager.play_music(Music.late_night_radio)

func attempt_move_to_puzzle_set(delta: int):
	var next_puzzle_set_idx = current_puzzle_set_idx + delta
	next_puzzle_set_idx = clamp(next_puzzle_set_idx, 0, len(puzzle_sets) - 1)
	var next_puzzle_set = puzzle_sets[next_puzzle_set_idx]

	if next_puzzle_set.is_unlocked():
		current_puzzle_set_idx = next_puzzle_set_idx
		current_puzzle_set = next_puzzle_set
		show_puzzle_set(current_puzzle_set)
	else:
		Log.pr("Cannot move to puzzle_set until it is unlocked")

func next_puzzle_set_unlocked():
	var next_puzzle_set_idx = clamp(current_puzzle_set_idx + 1, 0, len(puzzle_sets) - 1)
	if next_puzzle_set_idx == current_puzzle_set_idx:
		return false
	var next_puzzle_set = puzzle_sets[next_puzzle_set_idx]
	return next_puzzle_set.is_unlocked()

func previous_puzzle_set_unlocked():
	var prev_puzzle_set_idx = clamp(current_puzzle_set_idx - 1, 0, len(puzzle_sets) - 1)
	if prev_puzzle_set_idx == current_puzzle_set_idx:
		return false
	var prev_puzzle_set = puzzle_sets[prev_puzzle_set_idx]
	return prev_puzzle_set.is_unlocked()

@onready var game_scene = preload("res://src/puzzle/GameScene.tscn")

func start_selected_puzzle():
	Navi.nav_to(game_scene, {setup=func(g):
		g.puzzle_set = current_puzzle_set
		g.puzzle_num = current_puzzle_index
		})

## input ###################################################################

func _unhandled_input(event):
	if not Engine.is_editor_hint():
		if Trolls.is_pause(event):
			if not get_tree().paused:
				Navi.pause()
				get_viewport().set_input_as_handled()

func on_level_icon_gui_input(event: InputEvent):
	if Trolls.is_accept(event):
		start_selected_puzzle()

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

	U.set_button_disabled(next_puzzle_set_button, !next_puzzle_set_unlocked())
	U.set_button_disabled(previous_puzzle_set_button, !previous_puzzle_set_unlocked())

	var theme = puzzle_set.get_theme()

	# var label = puzzle_label.instantiate()
	# label.text = "[center]%s[/center]" % (puzzle.idx + 1)

	var next_puzzle_icon

	# list of puzzles
	U.remove_children(puzzle_list)
	for i in range(len(puzzle_set.get_puzzles())):
		var puzzle = puzzle_set.get_puzzle(i)
		if not puzzle:
			Log.warn("Unexpected missing puzzle index!", i, puzzle_set)
			continue
		var icon = TextureRect.new()
		icon.set_custom_minimum_size(64.0 * Vector2.ONE)
		icon.gui_input.connect(on_level_icon_gui_input)
		icon.focus_entered.connect(move_level_cursor.bind(icon))
		if puzzle_set.completed_puzzle(i):
			icon.set_texture(theme.get_dotted_icon())
			icon.set_focus_mode(Control.FOCUS_ALL)
			# should get overwritten if there's an incomplete, can-play puzzle
			next_puzzle_icon = icon
		elif puzzle_set.can_play_puzzle(i):
			icon.set_focus_mode(Control.FOCUS_ALL)
			icon.set_texture(theme.get_dot_icon())
			next_puzzle_icon = icon
		else:
			icon.set_texture(theme.get_dot_icon())
			icon.set_modulate(Color(0.5, 0.5, 0.5, 0.5))
		puzzle_list.add_child(icon)

	# player icon
	puzzle_set_icon.set_texture(theme.get_player_icon())
	puzzle_set_icon.modulate.a = 0.0

	if next_puzzle_icon:
		start_puzzle_set_button.focus_neighbor_bottom = next_puzzle_icon.get_path()
		U.call_in(0.4, self, func():
			move_level_cursor(next_puzzle_icon, {no_move=true})
			start_puzzle_set_button.grab_focus.call_deferred())

func move_level_cursor(icon, opts={}):
	var idx = puzzle_list.get_children().find(icon)
	current_puzzle_index = idx
	start_puzzle_n_label.text = "[center]Start Puzzle %s" % str(idx + 1)

	if opts.get("no_move", false):
		puzzle_set_icon.position = icon.global_position

	var time = 0.4
	var t = create_tween()
	t.tween_property(puzzle_set_icon, "modulate:a", 1.0, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(puzzle_set_icon, "position", icon.global_position, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var scale_tween = create_tween()
	scale_tween.tween_property(puzzle_set_icon, "scale", 1.3*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(puzzle_set_icon, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(puzzle_set_icon, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func reset_map():
	puzzle_map.current_marker = null
	U.remove_children(puzzle_list)
	start_puzzle_set_button.release_focus.call_deferred()
