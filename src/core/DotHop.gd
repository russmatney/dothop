@tool
extends Node

## config ##########################################################################

var pause_menu_path: String = "res://src/menus/PauseMenu.tscn"
var main_menu_path: String = "res://src/menus/MainMenu.tscn"
var world_map_menu_path: String = "res://src/menus/worldmap/WorldMapMenu.tscn"
var credits_path: String = "res://src/menus/Credits.tscn"
var changelog_url: String = "https://russmatney.github.io/dothop/#/changelog"

func _ready() -> void:
	Navi.set_main_menu(main_menu_path)
	Navi.set_pause_menu(pause_menu_path)

## global pause helper ##########################################################################

func maybe_pause() -> void:
	if not get_tree().paused:
		Navi.pause()
		get_viewport().set_input_as_handled()

## mobile predicate ##########################################################################

func is_mobile() -> bool:
	# return OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("web_ios") or OS.has_feature("web_android")
	return OS.has_feature("mobile") or OS.has_feature("web_ios") or OS.has_feature("web_android")

## navigation ##########################################################################

func nav_to_world_map() -> void:
	Navi.nav_to(world_map_menu_path)

func nav_to_credits() -> void:
	Navi.nav_to(credits_path)

func open_changelog_url() -> void:
	OS.shell_open(changelog_url)

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
