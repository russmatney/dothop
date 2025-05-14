@tool
extends VBoxContainer
class_name ButtonList

@export var default_button_scene: PackedScene = preload("res://src/ui/components/MenuButton.tscn")

signal button_focused(btn: Button)
signal button_unfocused(btn: Button)

## config warnings #####################################################################

func _get_configuration_warnings() -> PackedStringArray:
	if default_button_scene == null:
		return ["No default_button_scene set"]
	return []

## ready #####################################################################

func _ready() -> void:
	if Engine.is_editor_hint():
		request_ready()

	set_focus()

func set_focus() -> void:
	# nice default... if nothing else has focus?
	# do parents still get to override this?
	var chs: Array = get_children()
	if len(chs) > 0:
		(chs[0] as Control).grab_focus()
	else:
		Log.pr(self, "no children, can't grab focus")

	var btns: Array = get_buttons()
	if len(btns) > 0:
		(btns[0] as Control).grab_focus()

## add_menu_item #####################################################################

func get_buttons() -> Array:
	return get_children()

func clear() -> void:
	for b: Node in get_buttons():
		if is_instance_valid(b):
			b.queue_free()

func add_menu_item(item: Dictionary) -> void:
	# read texts from buttons in scene
	var texts: Array = []
	for but: Button in get_buttons():
		if not but.is_queued_for_deletion():
			texts.append(but.text)

	var hide_fn: Variant = item.get("hide_fn")
	if hide_fn and hide_fn is Callable and (hide_fn as Callable).call():
		return

	var label: String = item.get("label")
	if not label:
		var label_fn: Callable = item.get("label_fn")
		if label_fn:
			label = label_fn.call()
		if not label:
			label = "Fallback Label"
	if label in texts:
		Log.pr("Found existing button with label, skipping add_menu_item", item)
		return
	var button_scene: PackedScene = item.get("button_scene", default_button_scene)
	var button: Button = button_scene.instantiate()

	button.focus_entered.connect(func() -> void: button_focused.emit(button, item))
	button.focus_exited.connect(func() -> void: button_unfocused.emit(button, item))
	button.text = label
	connect_pressed_to_action(button, item)
	add_child(button)

func set_menu_items(items: Array) -> void:
	clear()
	for it: Dictionary in items:
		add_menu_item(it)

func no_op() -> void:
	Log.pr("button created with no method")


func connect_pressed_to_action(button: Button, item: Dictionary) -> void:
	var nav_to: String = item.get("nav_to", "")

	var fn: Callable
	var arg: Variant
	var argv: Array
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
		@warning_ignore("unsafe_method_access")
		if item.is_disabled.call():
			button.set_disabled(true)
			return

	if arg:
		button.pressed.connect(fn.bind(arg))
	elif argv:
		button.pressed.connect(fn.bindv(argv))
	else:
		button.pressed.connect(fn)
