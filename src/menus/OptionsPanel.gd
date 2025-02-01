@tool
extends CanvasLayer

## vars ###############################################3

@onready var main_menu_button: Button = $%MainMenuButton
@onready var reset_save_data_button: Button = $%ResetSaveDataButton
@onready var unlock_all_button: Button = $%UnlockAllButton
@onready var clear_achievements_button: Button = $%ClearAchievementsButton

@onready var data_reset_conf: ConfirmationDialog = $%DataResetConfirmationDialog
@onready var data_unlock_conf: ConfirmationDialog = $%DataUnlockConfirmationDialog
@onready var clear_achievements_conf: ConfirmationDialog = $%ClearAchievementsConfirmationDialog

## ready ###############################################3

func _ready() -> void:
	reset_save_data_button.pressed.connect(func() -> void: data_reset_conf.show())
	unlock_all_button.pressed.connect(func() -> void: data_unlock_conf.show())
	clear_achievements_button.pressed.connect(func() -> void: clear_achievements_conf.show())
	data_reset_conf.confirmed.connect(func() -> void:
		Store.reset_game_data()
		GodotSteam.set_from_the_top())
	data_unlock_conf.confirmed.connect(func() -> void:
		Store.unlock_all_puzzle_sets()
		GodotSteam.set_cheater_cheater_pumpkin_eater())
	clear_achievements_conf.confirmed.connect(func() -> void:
		GodotSteam.clear_all_achievements())

	main_menu_button.pressed.connect(func() -> void:
		Navi.nav_to_main_menu())

	main_menu_button.grab_focus.call_deferred()
	main_menu_button.visibility_changed.connect(func() -> void: main_menu_button.grab_focus())
