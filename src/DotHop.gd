@tool
extends Node

## config ##########################################################################

var pause_menu_path: String = "res://src/menus/PauseMenu.tscn"

func _ready() -> void:
	Navi.set_pause_menu(pause_menu_path)

## focus ##########################################################################

## is the window focused?
# https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html#window-focus
var focused: bool = true

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focused = true

## notifications ##########################################################################

signal notification(notif: Dictionary)

func notif(text: Variant, opts: Dictionary = {}) -> void:
	if text is Dictionary:
		opts.merge(text as Dictionary)
		text = opts.get("text", opts.get("msg"))
	if typeof(opts) == TYPE_STRING or not opts is Dictionary:
		text += str(opts)
		opts = {}
	opts["text"] = text
	if not "ttl" in opts:
		opts["ttl"] = 3.0
	notification.emit(opts)
