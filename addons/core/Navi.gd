@tool
extends Node

## vars ###################################################################

var first_scene
var current_scene
var last_scene_stack = []

signal pause_toggled(paused)
signal navigating()

## ready ###################################################################

func _ready():
	if not ResourceLoader.exists(main_menu_path):
		Log.prn("No scene at path: ", main_menu_path, ", nav_to_main_menu will no-op.")

	process_mode = PROCESS_MODE_ALWAYS

	var root = get_tree().get_root()
	var first = root.get_child(root.get_child_count() - 1)
	var main_scene_path = ProjectSettings.get_setting("application/run/main_scene")
	if first.scene_file_path == main_scene_path:
		first_scene = first

	pause_menu = add_menu(load(pause_menu_path))

	ensure_current_scene.call_deferred()

func ensure_current_scene(wait_a_frame=true):
	if wait_a_frame:
		await get_tree().process_frame
	if current_scene == null:
		var root = get_tree().get_root()
		current_scene = root.get_children()[-1]
		get_tree().set_current_scene(current_scene)

	Log.pr("Current scene:", current_scene)

## process ###################################################################

var focused_node
var attempted_focus_for_scene
func _process(_delta):
	# PERF could only run this when in a menu/control/ui screen
	var new_focused_node = get_viewport().gui_get_focus_owner()
	if new_focused_node == null and attempted_focus_for_scene != current_scene:
		find_focus()
	elif new_focused_node != focused_node:
		focused_node = new_focused_node
		_on_focus_changed(focused_node)

## focus changes ###################################################################

func _on_focus_changed(control: Control) -> void:
	if control == null:
		find_focus()

# this might compete with grab_focus, should only be called if there is nothing in focus
func find_focus(scene=null):
	if scene == null:
		scene = current_scene
	if scene == null:
		return
	attempted_focus_for_scene = scene
	if scene.has_method("set_focus"):
		scene.set_focus()
	else:
		# there are things besides buttons to focus on...
		var btns = scene.find_children("*", "BaseButton", true, false)
		btns = btns.filter(func(b): return not b.is_disabled())
		if len(btns) > 0:
			Log.pr("btn grabbing focus", btns[0])
			btns[0].grab_focus()

## nav_to ###################################################################

# Supports a path, packed_scene, or instance of a scene
func nav_to(scene, opts={}):
	Log.prn("nav_to: ", scene, opts)
	# NOTE this scene stack grows forever!
	last_scene_stack.push_back(scene)
	hide_menus()
	_deferred_goto_scene.call_deferred(scene, opts)
	# ensure unpaused
	resume()
	# emit to any listeners
	navigating.emit()

func _deferred_goto_scene(scene, opts={}):
	if first_scene != null and is_instance_valid(first_scene):
		first_scene.queue_free()
	if current_scene != null and is_instance_valid(current_scene):
		current_scene.queue_free()

	var next_scene
	if scene is String:
		var s = ResourceLoader.load(scene)
		if s == null:
			Log.warn("Cannot instantiate passed scene, failed to load", scene)
			return
		next_scene = s.instantiate()
	elif scene is PackedScene:
		next_scene = scene.instantiate()
	else:
		# assuming it is already instantiated
		next_scene = scene

	if "setup" in opts:
		if opts.setup != null:
			opts.setup.call(next_scene)

	current_scene = next_scene

	# Add it as a child of root
	get_tree().get_root().add_child(current_scene)
	# compatibility with SceneTree.change_scene_to_file()
	get_tree().set_current_scene(current_scene)

	# set the focus for the current scene
	find_focus()

## current_scene_path ###################################################################

func current_scene_path():
	if current_scene == null:
		ensure_current_scene(false)
	return current_scene.scene_file_path

## add child ###################################################################

# helper for adding a child to the current scene
func add_child_to_current(child, deferred=true):
	# could use the scene_tree's current_scene directly
	if current_scene == null:
		var root = get_tree().get_root()
		current_scene = root.get_children()[-1]
		get_tree().set_current_scene(current_scene)

	if deferred:
		current_scene.add_child.call_deferred(child)
	else:
		current_scene.add_child(child)

## pause ###################################################################

func toggle_pause():
	if get_tree().paused:
		resume()
	else:
		pause()

func pause():
	get_tree().paused = true
	if pause_menu and is_instance_valid(pause_menu):
		pause_menu.show()
		find_focus(pause_menu)
	pause_toggled.emit(true)

func resume():
	get_tree().paused = false
	hide_menus()
	pause_toggled.emit(false)

## menus ###################################################################

var menus = []

func add_menu(scene):
	for c in get_children():
		var sfp = scene.resource_path
		if c.scene_file_path == sfp:
			c.hide()
			return c

	var menu = scene.instantiate()
	menu.hide()
	menus.append(menu)
	add_child.call_deferred(menu)
	return menu

func hide_menus():
	menus = menus.filter(func(m): return is_instance_valid(m))
	menus.map(func(m): m.hide())

	var other_menus = get_tree().get_nodes_in_group("menus")
	other_menus.map(func(m): m.hide())

	find_focus()

func show_menu(menu):
	menus = menus.filter(func(m): return is_instance_valid(m))
	if not menu in menus:
		add_menu(menu)
	menu.show()
	find_focus(menu)

func clear_menus():
	menus = menus.filter(func(m): return is_instance_valid(m))
	for m in menus:
		m.queue_free()

## main menu ###################################################################

var main_menu_path = "res://src/menus/MainMenu.tscn"

func set_main_menu(path):
	if ResourceLoader.exists(path):
		Log.prn("Updating main_menu_path: ", path)
		main_menu_path = path
	else:
		Log.prn("No scene at path: ", main_menu_path, ", can't set main menu.")

func nav_to_main_menu():
	if ResourceLoader.exists(main_menu_path):
		hide_menus()
		nav_to(main_menu_path)
	else:
		Log.prn("No scene at path: ", main_menu_path, ", can't navigate.")

## pause menu ###################################################################

var pause_menu_path = "res://src/menus/PauseMenu.tscn"
var pause_menu

func set_pause_menu(path_or_scene):
	if path_or_scene == null:
		Log.warn("Null passed to set_pause_menu, returning")
		return
	var path = U.to_scene_path(path_or_scene)
	if ResourceLoader.exists(path):
		if pause_menu and is_instance_valid(pause_menu):
			if pause_menu.scene_file_path == path:
				return
			pause_menu.queue_free()
		pause_menu = add_menu(load(path))
	else:
		Log.prn("No scene at path: ", path, ", can't set pause menu.")
