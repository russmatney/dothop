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

@onready var button_to_main: Button = $%ButtonToMain

## ready ######################################################

func _ready() -> void:
	render_world_list()

	if len(worlds) > 0:
		select_world(worlds[0])

	button_to_main.pressed.connect(Navi.nav_to_main_menu)

## render_world_list ######################################################

func render_world_list() -> void:
	U.remove_children(world_grid)
	for world in worlds:
		Log.pr("rendering puzzle set", world.get_display_name())

		var icon: TextureButton = build_world_icon(world)
		icon.pressed.connect(on_world_button_pressed.bind(world))
		world_grid.add_child(icon)

func build_world_icon(world: PuzzleWorld) -> TextureButton:
	var button := TextureButton.new()
	button.custom_minimum_size = Vector2(64, 64)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT

	var td := world.get_theme_data()
	button.set_texture_normal(td.player_icon)
	button.set_texture_hover(td.dot_icon)
	button.set_texture_disabled(td.dotted_icon)

	# button.text = world.get_display_name()
	return button

## on ######################################################

func on_world_button_pressed(world: PuzzleWorld) -> void:
	# Log.pr("world button pressed", world)
	select_world(world)

func on_puzzle_button_pressed(world: PuzzleWorld, p: PuzzleDef) -> void:
	select_puzzle(world, p)

## select ######################################################

func select_world(world: PuzzleWorld) -> void:
	U.remove_children(puzzles_grid)

	var first: Variant = null
	for puzzle_def in world.get_puzzles():
		if not first:
			first = puzzle_def

		var icon: TextureButton = build_puzzle_icon(world, puzzle_def)

		# connections
		icon.pressed.connect(on_puzzle_button_pressed.bind(world, puzzle_def))

		Events.stats.analysis_complete.connect(func(evt: Events.Evt) -> void:
			# only handle the event for THIS icon
			if evt.puzzle_def.get_id() == puzzle_def.get_id():
				Anim.scale_up_down_up(icon, 0.8)
				if puzzle_node:
					if evt.puzzle_def.get_id() == puzzle_node.puzzle_def.get_id():
						update_puzzle_detail(world, evt.puzzle_def))

		# add child
		puzzles_grid.add_child(icon)

	if first:
		select_puzzle(world, first as PuzzleDef)

# careful, called for every icon!
func build_puzzle_icon(world: PuzzleWorld, puzzle_def: PuzzleDef) -> TextureButton:
	# var bg_music = world.get_theme_data().background_music

	var texture_b := TextureButton.new()
	texture_b.custom_minimum_size = Vector2(96, 96)
	texture_b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT

	var td := world.get_theme_data()
	texture_b.set_texture_hover(td.player_icon)
	texture_b.set_texture_normal(td.dot_icon)
	texture_b.set_texture_disabled(td.dotted_icon)

	var label := Label.new()
	label.text = str("#", puzzle_def.idx)

	texture_b.add_child(label)

	return texture_b


func select_puzzle(world: PuzzleWorld, puzzle_def: PuzzleDef) -> void:
	Log.pr("Puzzle selected", puzzle_def)

	if PuzzleAnalyzer.get_analysis(puzzle_def) == null:
		PuzzleAnalyzer.analyze_puzzle(puzzle_def)

	update_puzzle_detail(world, puzzle_def)
	DotHopPuzzle.rebuild_puzzle({container=puzzle_container, puzzle_def=puzzle_def, world=world})

func update_puzzle_detail(world: PuzzleWorld, puzzle_def: PuzzleDef) -> void:
	var w := puzzle_def.width
	var h := puzzle_def.height
	var msg := puzzle_def.message
	var idx := puzzle_def.idx # not necessarily the order, which puzzle-sets can overwrite
	var analysis := PuzzleAnalyzer.get_analysis(puzzle_def)
	# or this?
	# var analysis := puzzle_def.analysis

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
