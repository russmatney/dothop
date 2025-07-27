@tool
extends CanvasLayer

## vars ################################################

@onready var puzzle_map: WorldMap = $%PuzzleMap
@onready var puzzle_list: GridContainer = $%PuzzleList
@onready var world_icon: TextureRect = $%PuzzleSetIcon
@onready var start_game_button: Button = $%StartGameButton
@onready var world_label: RichTextLabel = $%PuzzleSetLabel
@onready var locked_puzzle_label: RichTextLabel = $%LockedPuzzleLabel

@onready var next_world_button: Button = $%NextPuzzleSetButton
@onready var previous_world_button: Button = $%PreviousPuzzleSetButton

var current_world: PuzzleWorld
var current_world_idx: int = 0
var current_puzzle_index: int = 0
@onready var worlds: Array = Store.get_worlds()
var stats: Dictionary

func set_focus() -> void:
	var ctrls: Array = []
	ctrls.append_array(puzzle_list.get_children())
	if len(ctrls) > 0:
		for c: Control in ctrls:
			if c is Button:
				(c as Button).grab_focus()
				return

	# hide puzzle cursor if we're not focusing a puzzle-list child
	hide_puzzle_cursor()

	ctrls.append_array([next_world_button, previous_world_button])
	if len(ctrls) > 0:
		for c: Control in ctrls:
			if c is Button:
				(c as Button).grab_focus()
				return

func is_something_focused() -> bool:
	var ctrls: Array = []
	ctrls.append_array(puzzle_list.get_children())
	ctrls.append_array([next_world_button, previous_world_button])

	for c: Control in ctrls:
		if c.has_focus():
			return true

	return false

## ready ################################################

func _ready() -> void:
	stats = DHData.calc_stats(worlds)
	if not Engine.is_editor_hint():
		SoundManager.play_music(Music.late_night_radio, 2.0)
		reset_map()

	hide_puzzle_cursor()

	var next_to_complete_puzzle_idx: int = 0
	for i: int in len(worlds):
		var ps: PuzzleWorld = worlds[i]
		if not ps.is_completed():
			next_to_complete_puzzle_idx = i
			break

	attempt_move_to_world(next_to_complete_puzzle_idx)

	start_game_button.pressed.connect(start_selected_puzzle)
	next_world_button.pressed.connect(show_next_world)
	previous_world_button.pressed.connect(show_previous_world)

	next_world_button.focus_entered.connect(unfocus_puzzles)
	previous_world_button.focus_entered.connect(unfocus_puzzles)
	next_world_button.mouse_entered.connect(unfocus_puzzles)
	previous_world_button.mouse_entered.connect(unfocus_puzzles)

	next_world_button.mouse_exited.connect(refocus_puzzles)
	previous_world_button.mouse_exited.connect(refocus_puzzles)

func unfocus_puzzles() -> void:
	hide_puzzle_cursor()
	fade_start_button()

func refocus_puzzles() -> void:
	if current_world.is_unlocked():
		update_start_game_button()
		move_puzzle_cursor(last_puzzle_cursor)
	else:
		Log.pr("current puzzle not unlocked, not refocusing")

func show_next_world() -> void:
	attempt_move_to_world(1)

func show_previous_world() -> void:
	attempt_move_to_world(-1)

func attempt_move_to_world(delta: int) -> void:
	var next_world_idx: int = current_world_idx + delta
	next_world_idx = clamp(next_world_idx, 0, len(worlds) - 1)
	if len(worlds) <= next_world_idx or next_world_idx == -1:
		Log.warn("Next Puzzle set index out of bounds! aborting attempted move.")
		return
	var next_world: PuzzleWorld = worlds[next_world_idx]

	current_world_idx = next_world_idx
	current_world = next_world
	show_world(current_world)

func next_world_exists() -> bool:
	var next_world_idx: int = clamp(current_world_idx + 1, 0, len(worlds) - 1)
	if next_world_idx == current_world_idx:
		return false
	return true

func previous_world_exists() -> bool:
	var prev_world_idx: int = clamp(current_world_idx - 1, 0, len(worlds) - 1)
	if prev_world_idx == current_world_idx:
		return false
	return true

@onready var world_scene: PackedScene = preload("res://src/dothop/WorldScene.tscn")

func start_selected_puzzle() -> void:
	var ps: PuzzleWorld = current_world
	var idx: int = current_puzzle_index
	Navi.nav_to(world_scene, {setup=func(scene: WorldScene) -> void:
		scene.world = ps
		scene.puzzle_num = idx
		})

	# TODO restore/reconsider whatever this feature does
	# var already_complete: bool = current_world.is_completed()
		# scene.already_complete = already_complete

## input ###################################################################

func _unhandled_input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		if Trolls.is_pause(event):
			if not get_tree().paused:
				Navi.pause()
				get_viewport().set_input_as_handled()

func on_level_icon_gui_input(event: InputEvent) -> void:
	if Trolls.is_accept(event):
		start_selected_puzzle()

## show puzzle set ################################################

func show_world(world: PuzzleWorld) -> void:
	# update puzzle map
	var markers: Array = puzzle_map.get_markers()
	for m: PuzzleMapMarker in markers:
		if m.world.get_entity_id() == world.get_entity_id():
			puzzle_map.current_marker = m
			break

	# title
	update_puzzle_label(world)

	U.set_button_disabled(next_world_button, !next_world_exists())
	U.set_button_disabled(previous_world_button, !previous_world_exists())

	if world.is_unlocked():
		Anim.fade_out(locked_puzzle_label)
	else:
		var to_unlock: int = world.get_puzzles_to_unlock()
		var completed: int = stats.puzzles_completed
		var remaining: int = to_unlock - completed
		locked_puzzle_label.text = "Complete [color=crimson]%s[/color]\nmore puzzles\nto unlock!" % str(remaining)
		Anim.fade_in(locked_puzzle_label)

	var theme_data: PuzzleThemeData = world.get_theme_data()
	var first_puzzle_icon: TextureRect = null
	var next_puzzle_icon: TextureRect = null

	# list of puzzles
	U.remove_children(puzzle_list)
	for i: int in range(len(world.get_puzzles())):
		var puzzle: PuzzleDef = world.get_puzzle(i)
		if not puzzle:
			Log.warn("Unexpected missing puzzle index!", i, world)
			continue
		var icon: TextureRect = TextureRect.new()
		icon.set_custom_minimum_size(64.0 * Vector2.ONE)
		if not world.is_unlocked():
			icon.set_texture(theme_data.dotted_icon)
			icon.set_modulate(Color(0.5, 0.5, 0.5, 0.5))
		else:
			icon.gui_input.connect(on_level_icon_gui_input)
			icon.focus_entered.connect(move_puzzle_cursor.bind(icon))
			if first_puzzle_icon == null:
				first_puzzle_icon = icon
			if world.completed_puzzle(i):
				icon.set_texture(theme_data.dot_icon)
				icon.set_focus_mode(Control.FOCUS_ALL)
			elif world.skipped_puzzle(i):
				# TODO differentiate skipped puzzles!
				icon.set_texture(theme_data.dot_icon) # TODO use skipped icon
				icon.set_focus_mode(Control.FOCUS_ALL)
				icon.set_modulate(Color(0.8, 0.8, 0.8, 0.8))
			elif world.can_play_puzzle(i):
				icon.set_focus_mode(Control.FOCUS_ALL)
				icon.set_texture(theme_data.goal_icon)
				if next_puzzle_icon == null:
					next_puzzle_icon = icon
			else:
				icon.set_texture(theme_data.dotted_icon)
				icon.set_modulate(Color(0.5, 0.5, 0.5, 0.5))
		puzzle_list.add_child(icon)

	# TODO if not unlocked, add 'N-more puzzles to unlock this world' label

	# player icon
	world_icon.set_texture(theme_data.player_icon)
	world_icon.modulate.a = 0.0

	if next_puzzle_icon:
		U.call_in(self, func() -> void:
			if next_puzzle_icon:
				move_puzzle_cursor(next_puzzle_icon, {no_move=true})
			# if nothing has focus, grab it here
			if not is_something_focused():
				next_puzzle_icon.grab_focus.call_deferred(),
			0.4)
		# wait a frame in an attempt to quickly grab focus
		await get_tree().process_frame
		next_puzzle_icon.grab_focus.call_deferred()
	else:
		if not next_world_button.is_disabled():
			next_world_button.grab_focus()
		elif not previous_world_button.is_disabled():
			previous_world_button.grab_focus()

		U.call_in(self, func() -> void:
			move_puzzle_cursor(first_puzzle_icon),
			0.4)

## puzzle cursor ################################################

var last_puzzle_cursor: TextureRect
func move_puzzle_cursor(icon: Variant, opts: Dictionary = {}) -> void:
	if icon == null:
		return
	icon = icon as TextureRect
	last_puzzle_cursor = icon
	var idx: int = puzzle_list.get_children().find(icon)
	current_puzzle_index = idx
	var puzzle: PuzzleDef = current_world.get_puzzles()[idx]

	Sounds.play(Sounds.S.step)

	update_start_game_button("%s Puzzle %s" % ["Start" if not puzzle.is_completed else "Replay", str(idx + 1)])

	if opts.get("no_move", false):
		world_icon.position = icon.global_position

	if icon.global_position == Vector2.ZERO:
		# TODO defer? call again after icon has animated in? icon is going to 0, 0 :/
		return

	var time: float = 0.4
	var t: Tween = create_tween()
	t.tween_property(world_icon, "modulate:a", 1.0, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(world_icon, "position", icon.global_position, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(world_icon, "scale", 1.3*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(world_icon, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(world_icon, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func hide_puzzle_cursor() -> void:
	var time: float = 0.4
	var t: Tween = create_tween()
	t.tween_property(world_icon, "modulate:a", 0.0, time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## update labels/buttons ################################################

func update_puzzle_label(world: PuzzleWorld) -> void:
	var puzzles: Array = world.get_puzzles()
	var total: int = len(puzzles)
	var complete: int = len(puzzles.filter(func(p: PuzzleDef) -> bool: return p.is_completed))
	world_label.text = "[center]%s (%s/%s)" % [
		world.get_display_name(), complete, total
		]
	world_label.set_pivot_offset(world_label.size/2)

	var time: float = 0.4
	var t: Tween = create_tween()
	t.tween_property(world_label, "scale", 1.3*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(world_label, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.tween_property(world_label, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

var button_scale_tween: Tween
var start_button_text: String

func update_start_game_button(text: String = "") -> void:
	if text == "":
		if start_button_text:
			text = start_button_text
	start_button_text = text
	start_game_button.text = text
	start_game_button.set_pivot_offset(start_game_button.size/2)

	start_game_button.set_disabled(false)

	var time: float = 0.4
	if button_scale_tween and button_scale_tween.is_running():
		return
	button_scale_tween = create_tween()
	button_scale_tween.tween_property(start_game_button, "scale", 1.1*Vector2.ONE, time/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button_scale_tween.tween_property(start_game_button, "scale", 0.8*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	button_scale_tween.tween_property(start_game_button, "scale", 1.0*Vector2.ONE, time/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func fade_start_button() -> void:
	start_game_button.set_disabled(true)

## reset map ################################################

# intended for 'zooming out' from a focal point on a map
func reset_map() -> void:
	puzzle_map.current_marker = null
	U.remove_children(puzzle_list)
