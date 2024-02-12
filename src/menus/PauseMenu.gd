@tool
extends CanvasLayer

## vars ###############################################3

@onready var resume_button = $%ResumeButton
@onready var worldmap_button = $%WorldmapButton
@onready var main_menu_button = $%MainMenuButton

@onready var controls_button = $%ControlsButton
@onready var theme_button = $%ThemeButton
@onready var sound_button = $%SoundButton

@onready var secondary_margin = $%SecondaryMenuMargin
@onready var controls_panel = $%ControlsPanel
@onready var theme_panel = $%ThemePanel
@onready var sound_panel = $%SoundPanel

@onready var all_panels = [controls_panel, theme_panel, sound_panel]

@onready var worldmap = preload("res://src/menus/worldmap/WorldMapMenu.tscn")

## ready ###############################################3

func _ready():
	visibility_changed.connect(on_visibility_changed)

	resume_button.pressed.connect(func(): Navi.resume())
	controls_button.pressed.connect(func():
		secondary_margin.show()
		all_panels.map(func(p): p.hide())
		controls_panel.show())
	theme_button.pressed.connect(func():
		secondary_margin.show()
		all_panels.map(func(p): p.hide())
		theme_panel.show())
	sound_button.pressed.connect(func():
		secondary_margin.show()
		all_panels.map(func(p): p.hide())
		sound_panel.show())

	main_menu_button.pressed.connect(func(): Navi.nav_to_main_menu())
	worldmap_button.pressed.connect(func(): Navi.nav_to(worldmap))

func on_visibility_changed():
	if not visible: # hide
		all_panels.map(func(p): p.hide())
		secondary_margin.hide()
		resume_button.release_focus()
	else: # show
		match get_tree().current_scene.name:
			"WorldMapMenu":
				worldmap_button.set_disabled(true)
				theme_button.set_disabled(true)
			"DotHopGameScene":
				worldmap_button.set_disabled(false)
				theme_button.set_disabled(false)
			_:
				worldmap_button.set_disabled(false)
				theme_button.set_disabled(false)
		resume_button.visibility_changed.connect(func(): resume_button.grab_focus())

## input ###################################################################

func _unhandled_input(event):
	if visible:
		if not Engine.is_editor_hint() and Trolls.is_pause(event):
			if get_tree().paused:
				Navi.resume()
				get_viewport().set_input_as_handled()
