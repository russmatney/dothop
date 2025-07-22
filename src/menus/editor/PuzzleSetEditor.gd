@tool
extends CanvasLayer

## vars ######################################################

@onready var worlds: Array[PuzzleWorld] = Store.get_worlds()

@onready var world_grid: GridContainer = $%PuzzleSetGrid
@onready var puzzles_grid: GridContainer = $%PuzzlesGrid
@onready var current_puzzle_label: RichTextLabel = $%CurrentPuzzleLabel
@onready var current_puzzle_analysis_label: RichTextLabel = $%CurrentPuzzleAnalysisLabel
@onready var puzzle_container: Node2D = $%PuzzleContainer
var puzzle_node: DotHopPuzzle

## ready ######################################################

func _ready() -> void:
	render()
	if len(worlds) > 0:
		select_world(worlds[0])

## render ######################################################

func render() -> void:
	U.remove_children(world_grid)
	for world in worlds:
		Log.pr("rendering puzzle set", world.get_display_name())

		var button := TextureButton.new()
		button.custom_minimum_size = Vector2(64, 64)
		button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT

		var td := world.get_theme_data()
		button.set_texture_normal(td.player_icon)
		button.set_texture_hover(td.dot_icon)
		button.set_texture_disabled(td.dotted_icon)

		# button.text = world.get_display_name()
		button.pressed.connect(on_world_button_pressed.bind(world))
		world_grid.add_child(button)

## process ###################################################

var analysis_threads: Array[Thread] = []

func _process(_delta: float) -> void:
	for th: Thread in analysis_threads:
		if th != null \
			# has started
			and th.is_started() \
			# and has finished
			and not th.is_alive():
			# join thread to prevent it leaking
			th.wait_to_finish()
			analysis_threads.erase(th)

## on ######################################################

func on_world_button_pressed(world: PuzzleWorld) -> void:
	# Log.pr("world button pressed", world)
	select_world(world)

func on_puzzle_button_pressed(world: PuzzleWorld, p: PuzzleDef) -> void:
	select_puzzle(world, p)

## select ######################################################

func select_world(world: PuzzleWorld) -> void:
	# TODO run in the background
	var th: Thread = world.analyze_puzzles_in_bg() # trigger solver analysis for whole puzzle set
	analysis_threads.append(th)

	U.remove_children(puzzles_grid)
	var first: Variant = null
	for puzzle_def in world.get_puzzles():
		if not first:
			first = puzzle_def

		# var bg_music = world.get_theme_data().background_music

		var texture := TextureButton.new()
		texture.custom_minimum_size = Vector2(96, 96)
		texture.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT

		var td := world.get_theme_data()
		texture.set_texture_hover(td.player_icon)
		texture.set_texture_normal(td.dot_icon)
		texture.set_texture_disabled(td.dotted_icon)

		texture.pressed.connect(on_puzzle_button_pressed.bind(world, puzzle_def))

		puzzles_grid.add_child(texture)
	if first:
		select_puzzle(world, first as PuzzleDef)

func select_puzzle(world: PuzzleWorld, puzzle_def: PuzzleDef) -> void:
	Log.pr("Puzzle selected", puzzle_def)
	var w := puzzle_def.width
	var h := puzzle_def.height
	var msg := puzzle_def.message
	var idx := puzzle_def.idx # not necessarily the order, which puzzle-sets can overwrite
	var analysis := puzzle_def.analysis

	current_puzzle_label.text = "[center]%s # %s" % [world.get_display_name(), idx + 1]
	var detail := "w: %s, h: %s" % [w, h]
	if msg:
		detail += " msg: %s" % msg

	if analysis:
		detail += "\ndots: [color=dark_blue]%s[/color]" % analysis.dot_count
		detail += " paths: [color=forest_green]%s win[/color]/[color=crimson]%s stuck_dot[/color]/[color=crimson]%s stuck_goal[/color]/[color=peru]%s all[/color]" % [
			analysis.winning_path_count,
			analysis.stuck_dot_path_count,
			analysis.stuck_goal_path_count,
			analysis.path_count,
			]

	current_puzzle_analysis_label.text = detail

	if puzzle_node != null:
		var outro_complete := Anim.puzzle_animate_outro_to_point(puzzle_node)
		await outro_complete
		puzzle_node.queue_free()

	puzzle_node = DotHopPuzzle.build_puzzle_node({
		world=world, puzzle_def=puzzle_def,
		})
	puzzle_node.ready.connect(func() -> void: Anim.puzzle_animate_intro_from_point(puzzle_node))

	puzzle_container.add_child(puzzle_node)
