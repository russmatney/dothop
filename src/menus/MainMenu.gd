@tool
extends CanvasLayer

@onready var start_button: Button = $%StartButton
@onready var options_button: Button = $%OptionsButton
@onready var credits_button: Button = $%CreditsButton
@onready var quit_button: Button = $%QuitButton
@onready var puzzle_stats_label: RichTextLabel = $%PuzzleStatsLabel
@onready var version_label: RichTextLabel = $%VersionLabel

@onready var world_map: PackedScene = preload("res://src/menus/worldmap/WorldMapMenu.tscn")
@onready var options_menu: PackedScene = preload("res://src/menus/OptionsPanel.tscn")
@onready var credits_menu: PackedScene = preload("res://src/menus/Credits.tscn")

func _ready() -> void:
	if not Engine.is_editor_hint():
		SoundManager.play_music(Music.late_night_radio)
		U.call_in(self, func() -> void: GodotSteam.set_first_hop(), 0.8)

	start_button.grab_focus.call_deferred()
	start_button.visibility_changed.connect(func() -> void: start_button.grab_focus())

	start_button.pressed.connect(func() -> void: Navi.nav_to(world_map))
	options_button.pressed.connect(func() -> void: Navi.nav_to(options_menu))
	credits_button.pressed.connect(func() -> void: Navi.nav_to(credits_menu))
	quit_button.pressed.connect(func() -> void: get_tree().quit())

	render_puzzle_stats()
	render_version()

func render_puzzle_stats() -> void:
	var stats := DHData.calc_stats(Store.get_puzzle_sets())

	Log.pr("Puzzle stats!", {
		events=len(Store.get_events()),
		puzzle_sets=len(Store.get_puzzle_sets()),
		puzzles_completed=stats.puzzles_completed,
		total_puzzles=stats.total_puzzles,
		dots_hopped=stats.dots_hopped,
		total_dots=stats.total_dots,
		})

	puzzle_stats_label.text = (
		"[center][color=forest_green]%s[/color] " +
		"/ [color=dark_slate_blue]%s[/color] puzzles complete" +
		"\n" +
		"[color=forest_green]%s[/color] " +
		"/ [color=dark_slate_blue]%s[/color] dots hopped"
		) % [stats.puzzles_completed, stats.total_puzzles,
			stats.dots_hopped, stats.total_dots]

func render_version() -> void:
	version_label.text = str("v", ProjectSettings.get_setting("application/config/version"))
