@tool
extends CanvasLayer

@onready var start_button = $%StartButton
@onready var options_button = $%OptionsButton
@onready var credits_button = $%CreditsButton
@onready var quit_button = $%QuitButton

@onready var world_map = preload("res://src/menus/worldmap/WorldMapMenu.tscn")
@onready var options_menu = preload("res://src/menus/OptionsPanel.tscn")
@onready var credits_menu = preload("res://src/menus/Credits.tscn")

func _ready():
	if not Engine.is_editor_hint():
		SoundManager.play_music(Music.late_night_radio)

	start_button.grab_focus.call_deferred()
	start_button.visibility_changed.connect(func(): start_button.grab_focus())

	start_button.pressed.connect(func(): Navi.nav_to(world_map))
	options_button.pressed.connect(func(): Navi.nav_to(options_menu))
	credits_button.pressed.connect(func(): Navi.nav_to(credits_menu))
	quit_button.pressed.connect(func(): get_tree().quit())

	var puzzles_completed = 0
	var puzzles_skipped = 0
	var puzzles_available = 0

	for ps in Store.get_puzzle_sets():
		for p in ps.get_puzzles():
			if p.is_completed:
				puzzles_completed += 1
			if p.is_skipped:
				puzzles_skipped += 1
			# TODO check the puzzle, not the puzzle set
			if ps.is_unlocked():
				puzzles_available += 1

	Log.pr("Puzzle stats!", {
		events=len(Store.get_events()),
		puzzle_sets=len(Store.get_puzzle_sets()),
		puzzles_completed=puzzles_completed,
		puzzles_skipped=puzzles_skipped,
		puzzles_available=puzzles_available,
		themes=len(Store.get_themes()),
		})
