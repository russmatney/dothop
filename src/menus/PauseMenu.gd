@tool
extends CanvasLayer

## vars ###############################################3

@onready var resume_button = $%ResumeButton
@onready var main_menu_button = $%MainMenuButton
@onready var exit_conf = $%ExitToMainConfirmationDialog

@onready var controls_button = $%ControlsButton
@onready var theme_button = $%ThemeButton
@onready var sound_button = $%SoundButton

@onready var secondary_margin = $%SecondaryMenuMargin
@onready var controls_panel = $%ControlsPanel
@onready var theme_panel = $%ThemePanel
@onready var sound_panel = $%SoundPanel

@onready var all_panels = [controls_panel, theme_panel, sound_panel]

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

	exit_conf.confirmed.connect(func(): Navi.nav_to_main_menu())
	main_menu_button.pressed.connect(func(): exit_conf.show())

func on_visibility_changed():
	if not visible:
		# on hidden
		all_panels.map(func(p): p.hide())
		secondary_margin.hide()
		resume_button.release_focus()
	else:
		# on show
		pass # TODO grab focus?
