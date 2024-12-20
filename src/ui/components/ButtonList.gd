@tool
extends VBoxContainer
class_name ButtonList

@export var default_button_scene: PackedScene = preload("res://src/ui/components/MenuButton.tscn")

signal button_focused(btn)
signal button_unfocused(btn)

## config warnings #####################################################################

func _get_configuration_warnings():
	if default_button_scene == null:
		return ["No default_button_scene set"]
	return []

## ready #####################################################################

func _ready():
	if Engine.is_editor_hint():
		request_ready()

	set_focus()

func set_focus():
	# nice default... if nothing else has focus?
	# do parents still get to override this?
	var chs = get_children()
	if len(chs) > 0:
		chs[0].grab_focus()
	else:
		Log.pr(self, "no children, can't grab focus")

	var btns = get_buttons()
	if len(btns) > 0:
		btns[0].grab_focus()

## add_menu_item #####################################################################

func get_buttons():
	return get_children()

func clear():
	for b in get_buttons():
		if is_instance_valid(b):
			b.queue_free()

func add_menu_item(item):
	# read texts from buttons in scene
	var texts = []
	for but in get_buttons():
		if not but.is_queued_for_deletion():
			texts.append(but.text)

	var hide_fn = item.get("hide_fn")
	if hide_fn and hide_fn.call():
		return

	var label = item.get("label")
	if not label:
		var label_fn = item.get("label_fn")
		if label_fn:
			label = label_fn.call()
		if not label:
			label = "Fallback Label"
	if label in texts:
		Log.pr("Found existing button with label, skipping add_menu_item", item)
		return
	var button_scene = item.get("button_scene", default_button_scene)
	var button = button_scene.instantiate()

	button.focus_entered.connect(func(): button_focused.emit(button, item))
	button.focus_exited.connect(func(): button_unfocused.emit(button, item))
	button.text = label
	connect_pressed_to_action(button, item)
	add_child(button)

func set_menu_items(items):
	clear()
	for it in items:
		add_menu_item(it)

func no_op():
	Log.pr("button created with no method")


func connect_pressed_to_action(button, item):
	var nav_to = item.get("nav_to", false)

	var fn
	var arg
	var argv
	if nav_to:
		fn = Navi.nav_to
		arg = nav_to
	else:
		arg = item.get("arg")
		argv = item.get("argv")
		fn = item.get("fn")

	if nav_to == null and fn == null:
		button.set_disabled(true)
		Log.pr("Menu item missing handler", item)
		return
	elif nav_to:
		if not ResourceLoader.exists(nav_to):
			button.set_disabled(true)
			Log.pr("Menu item with non-existent nav-to", item)
			return

	if fn == null:
		button.set_disabled(true)
		Log.pr("Menu item handler invalid", item)
		return

	if item.get("is_disabled"):
		if item.is_disabled.call():
			button.set_disabled(true)
			return

	if arg:
		button.pressed.connect(fn.bind(arg))
	elif argv:
		button.pressed.connect(fn.bindv(argv))
	else:
		button.pressed.connect(fn)
