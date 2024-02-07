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
		Music.play_song(Music.M.late_night_radio)

	start_button.grab_focus.call_deferred()
	start_button.visibility_changed.connect(func(): start_button.grab_focus())

	start_button.pressed.connect(func(): Navi.nav_to(world_map))
	options_button.pressed.connect(func(): Navi.nav_to(options_menu))
	credits_button.pressed.connect(func(): Navi.nav_to(credits_menu))
	quit_button.pressed.connect(func(): get_tree().quit())
