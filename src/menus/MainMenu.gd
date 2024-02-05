extends CanvasLayer

@onready var start_button = $%StartButton
@onready var options_button = $%OptionsButton
@onready var quit_button = $%QuitButton

@onready var world_map = preload("res://src/menus/worldmap/WorldMapMenu.tscn")
@onready var options_menu = preload("res://src/menus/OptionsPanel.tscn")

func _ready():
	# a bit flaky? grabs focus back from the pause menu...
	start_button.call_deferred("grab_focus")

	start_button.pressed.connect(func(): Navi.nav_to(world_map))
	options_button.pressed.connect(func(): Navi.nav_to(options_menu))
	quit_button.pressed.connect(func(): get_tree().quit())
