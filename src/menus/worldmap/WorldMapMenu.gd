@tool
extends CanvasLayer

## vars ################################################

@onready var puzzle_map = $%PuzzleMap
@onready var puzzle_list = $%PuzzleList
@onready var puzzle_set_icon = $%PuzzleSetIcon
@onready var start_game_button = $%StartGameButton
@onready var puzzle_set_label = $%PuzzleSetLabel

@onready var next_puzzle_set_button = $%NextPuzzleSetButton
@onready var previous_puzzle_set_button = $%PreviousPuzzleSetButton

var current_puzzle_set: PuzzleSet
var current_puzzle_set_idx = 0
var current_puzzle_index = 0
@onready var puzzle_sets = Store.get_puzzle_sets()

func set_focus():
	var ctrls = []
	ctrls.append_array(puzzle_list.get_children())
	ctrls.append_array([next_puzzle_set_button, previous_puzzle_set_button])
	var btn = ctrls[0]
	btn.grab_focus()

func is_something_focused():
	var ctrls = []
	ctrls.append_array(puzzle_list.get_children())
	ctrls.append_array([next_puzzle_set_button, previous_puzzle_set_button])

	for c in ctrls:
		if c.has_focus():
			return true

	return false

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

	start_game_button.pressed.connect(start_selected_puzzle)
	next_puzzle_set_button.pressed.connect(show_next_puzzle_set)
	previous_puzzle_set_button.pressed.connect(show_previous_puzzle_set)

	next_puzzle_set_button.focus_entered.connect(unfocus_puzzles)
	previous_puzzle_set_button.focus_entered.connect(unfocus_puzzles)
	next_puzzle_set_button.mouse_entered.connect(unfocus_puzzles)
	previous_puzzle_set_button.mouse_entered.connect(unfocus_puzzles)

	next_puzzle_set_button.mouse_exited.connect(refocus_puzzles)
	previous_puzzle_set_button.mouse_exited.connect(refocus_puzzles)

func unfocus_puzzles():
	hide_puzzle_cursor()
	fade_start_button()

func refocus_puzzles():
	if current_puzzle_set.is_unlocked():
		update_start_game_button()
		move_puzzle_cursor(last_puzzle_cursor)
	else:
		Log.pr("current puzzle not unlocked, not refocusing")

func show_next_puzzle_set():
	attempt_move_to_puzzle_set(1)

func show_previous_puzzle_set():
	attempt_move_to_puzzle_set(-1)

func attempt_move_to_puzzle_set(delta: int):
	var next_puzzle_set_idx = current_puzzle_set_idx + delta
	next_puzzle_set_idx = clamp(next_puzzle_set_idx, 0, len(puzzle_sets) - 1)
	var next_puzzle_set = puzzle_sets[next_puzzle_set_idx]

	current_puzzle_set_idx = next_puzzle_set_idx
	current_puzzle_set = next_puzzle_set
	show_puzzle_set(current_puzzle_set)

func next_puzzle_set_exists():
	var next_puzzle_set_idx = clamp(current_puzzle_set_idx + 1, 0, len(puzzle_sets) - 1)
	if next_puzzle_set_idx == current_puzzle_set_idx:
		return false
	return true

func previous_puzzle_set_exists():
	var prev_puzzle_set_idx = clamp(current_puzzle_set_idx - 1, 0, len(puzzle_sets) - 1)
	if prev_puzzle_set_idx == current_puzzle_set_idx:
		return false
	return true

@onready var game_scene = preload("res://src/puzzle/GameScene.tscn")

func start_selected_puzzle():
	var ps = current_puzzle_set
	var idx = current_puzzle_index
	Navi.nav_to(game_scene, {setup=func(g):
		g.puzzle_set = ps
		g.puzzle_num = idx
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

func show_puzzle_set(puzzle_set):
	# update puzzle map
	var markers = puzzle_map.get_markers()
	for m in markers:
		if m.puzzle_set.get_entity_id() == puzzle_set.get_entity_id():
			puzzle_map.current_marker = m
			break

	# title
	update_puzzle_label(puzzle_set.get_display_name())

	U.set_button_disabled(next_puzzle_set_button, !next_puzzle_set_exists())
	U.set_button_disabled(previous_puzzle_set_button, !previous_puzzle_set_exists())

	var theme = puzzle_set.get_theme()
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
		if not puzzle_set.is_unlocked():
			icon.set_texture(theme.get_dotted_icon())
			icon.set_modulate(Color(0.5, 0.5, 0.5, 0.5))
		else:
			icon.gui_input.connect(on_level_icon_gui_input)
			icon.focus_entered.connect(move_puzzle_cursor.bind(icon))
			if puzzle_set.completed_puzzle(i):
				icon.set_texture(theme.get_dot_icon())
				icon.set_focus_mode(Control.FOCUS_ALL)
			elif puzzle_set.skipped_puzzle(i):
				# TODO differentiate skipped puzzle!
				icon.set_texture(theme.get_dot_icon()) # TODO use skipped icon
				icon.set_focus_mode(Control.FOCUS_ALL)
				icon.set_modulate(Color(0.8, 0.8, 0.8, 0.8))
			elif puzzle_set.can_play_puzzle(i):
				icon.set_focus_mode(Control.FOCUS_ALL)
				icon.set_texture(theme.get_goal_icon())
				if not next_puzzle_icon:
					next_puzzle_icon = icon
			else:
				icon.set_texture(theme.get_dotted_icon())
				icon.set_modulate(Color(0.5, 0.5, 0.5, 0.5))
		puzzle_list.add_child(icon)

	# player icon
	puzzle_set_icon.set_texture(theme.get_player_icon())
	puzzle_set_icon.modulate.a = 0.0

	if next_puzzle_icon:
		U.call_in(0.4, self, func():
			if next_puzzle_icon:
				move_puzzle_cursor(next_puzzle_icon, {no_move=true})
			# if nothing has focus, grab it here
			if not is_something_focused():
				next_puzzle_icon.grab_focus.call_deferred())
		# wait a frame in an attempt to quickly grab focus
		await get_tree().process_frame
		next_puzzle_icon.grab_focus.call_deferred()
	else:
		if not next_puzzle_set_button.is_disabled():
			next_puzzle_set_button.grab_focus()
		elif not previous_puzzle_set_button.is_disabled():
			previous_puzzle_set_button.grab_focus()

## puzzle cursor ################################################

var last_puzzle_cursor
func move_puzzle_cursor(icon, opts={}):
	if not icon:
		return
	last_puzzle_cursor = icon
	var idx = puzzle_list.get_children().find(icon)
	current_puzzle_index = idx

	Sounds.play(Sounds.S.step)

	update_start_game_button("Start Puzzle %s" % str(idx + 1))

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

func hide_puzzle_cursor():
	var time = 0.4
	var t = create_tween()
	t.tween_property(puzzle_set_icon, "modulate:a", 0.0, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## update labels/buttons ################################################

func update_puzzle_label(text):
	puzzle_set_label.text = "[center]%s" % text
	puzzle_set_label.set_pivot_offset(puzzle_set_label.size/2)

	var time = 0.4
	var t = create_tween()
	t.tween_property(puzzle_set_label, "scale", 1.3*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(puzzle_set_label, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(puzzle_set_label, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

var button_scale_tween
var start_button_text

func update_start_game_button(text=null):
	if not text:
		if start_button_text:
			text = start_button_text
		else:
			text = ""
	start_button_text = text
	start_game_button.text = text
	start_game_button.set_pivot_offset(start_game_button.size/2)

	start_game_button.set_disabled(false)

	var time = 0.4
	if button_scale_tween and button_scale_tween.is_running():
		return
	button_scale_tween = create_tween()
	button_scale_tween.tween_property(start_game_button, "scale", 1.1*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button_scale_tween.tween_property(start_game_button, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button_scale_tween.tween_property(start_game_button, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func fade_start_button():
	start_game_button.set_disabled(true)

## reset map ################################################

# intended for 'zooming out' from a focal point on a map
func reset_map():
	puzzle_map.current_marker = null
	U.remove_children(puzzle_list)
