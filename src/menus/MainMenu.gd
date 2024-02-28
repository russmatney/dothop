@tool
extends CanvasLayer

@onready var start_button = $%StartButton
@onready var options_button = $%OptionsButton
@onready var credits_button = $%CreditsButton
@onready var quit_button = $%QuitButton
@onready var puzzle_stats_label = $%PuzzleStatsLabel

@onready var world_map = preload("res://src/menus/worldmap/WorldMapMenu.tscn")
@onready var options_menu = preload("res://src/menus/OptionsPanel.tscn")
@onready var credits_menu = preload("res://src/menus/Credits.tscn")

func _ready():
	if not Engine.is_editor_hint():
		SoundManager.play_music(Music.late_night_radio)
		U.call_in(1.4, self, func(): GodotSteam.set_first_hop())

	start_button.grab_focus.call_deferred()
	start_button.visibility_changed.connect(func(): start_button.grab_focus())

	start_button.pressed.connect(func(): Navi.nav_to(world_map))
	options_button.pressed.connect(func(): Navi.nav_to(options_menu))
	credits_button.pressed.connect(func(): Navi.nav_to(credits_menu))
	quit_button.pressed.connect(func(): get_tree().quit())

	render_puzzle_stats()

func render_puzzle_stats():
	var puzzles_completed = 0
	var puzzles_skipped = 0
	var total_puzzles = 0
	var total_dots = 0
	var dots_collected = 0

	for ps in Store.get_puzzle_sets():
		for p in ps.get_puzzles():
			total_puzzles += 1
			total_dots += p.dot_count()
			if p.is_completed:
				puzzles_completed += 1
				dots_collected += p.dot_count()
			if p.is_skipped:
				puzzles_skipped += 1

	Log.pr("Puzzle stats!", {
		events=len(Store.get_events()),
		puzzle_sets=len(Store.get_puzzle_sets()),
		puzzles_completed=puzzles_completed,
		puzzles_skipped=puzzles_skipped,
		total_puzzles=total_puzzles,
		dots_collected=dots_collected,
		total_dots=total_dots,
		})

	puzzle_stats_label.text = (
		"[center][color=forest_green]%s[/color] " +
		"/ [color=dark_slate_blue]%s[/color] puzzles complete" +
		"\n" +
		"[color=forest_green]%s[/color] " +
		"/ [color=dark_slate_blue]%s[/color] dots collected"
		) % [puzzles_completed, total_puzzles, dots_collected, total_dots]
