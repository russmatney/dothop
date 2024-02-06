@tool
extends CanvasLayer

## vars ###############################################3

@onready var main_menu_button = $%MainMenuButton
@onready var reset_save_data_button = $%ResetSaveDataButton
@onready var unlock_all_button = $%UnlockAllButton

@onready var data_reset_conf = $%DataResetConfirmationDialog
@onready var data_unlock_conf = $%DataUnlockConfirmationDialog

## ready ###############################################3

func _ready():
	reset_save_data_button.pressed.connect(func(): data_reset_conf.show())
	unlock_all_button.pressed.connect(func(): data_unlock_conf.show())
	data_reset_conf.confirmed.connect(func():
		Store.reset_game_data())
	data_unlock_conf.confirmed.connect(func():
		Store.unlock_all_puzzle_sets())

	main_menu_button.pressed.connect(func():
		Navi.nav_to_main_menu())

	main_menu_button.grab_focus.call_deferred()
	main_menu_button.visibility_changed.connect(func(): main_menu_button.grab_focus())
