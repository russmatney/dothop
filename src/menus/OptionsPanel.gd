@tool
extends CanvasLayer

## vars ###############################################3

@onready var main_menu_button = $%MainMenuButton
@onready var reset_save_data_button = $%ResetSaveDataButton
@onready var unlock_all_button = $%UnlockAllButton
@onready var clear_achievements_button = $%ClearAchievementsButton

@onready var data_reset_conf = $%DataResetConfirmationDialog
@onready var data_unlock_conf = $%DataUnlockConfirmationDialog
@onready var clear_achievements_conf = $%ClearAchievementsConfirmationDialog

## ready ###############################################3

func _ready():
	reset_save_data_button.pressed.connect(func(): data_reset_conf.show())
	unlock_all_button.pressed.connect(func(): data_unlock_conf.show())
	clear_achievements_button.pressed.connect(func(): clear_achievements_conf.show())
	data_reset_conf.confirmed.connect(func():
		Store.reset_game_data()
		GodotSteam.set_from_the_top())
	data_unlock_conf.confirmed.connect(func():
		Store.unlock_all_puzzle_sets()
		GodotSteam.set_cheater_cheater_pumpkin_eater())
	clear_achievements_conf.confirmed.connect(func():
		GodotSteam.clear_all_achievements())

	main_menu_button.pressed.connect(func():
		Navi.nav_to_main_menu())

	main_menu_button.grab_focus.call_deferred()
	main_menu_button.visibility_changed.connect(func(): main_menu_button.grab_focus())
