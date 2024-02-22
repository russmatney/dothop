@tool
extends CanvasLayer
class_name Jumbotron

## static ##########################################################################

static var jumbotron_scene_path = "res://addons/core/ui/Jumbotron.tscn"

static func jumbo_notif(opts):
	var scene = opts.get("scene", load(jumbotron_scene_path))
	var jumbotron = opts.get("instance", scene.instantiate())
	Navi.add_child(jumbotron)
	# this opt-in pattern might make more sense than 'Navi.menus'
	Navi.navigating.connect(jumbotron.on_navigate)

	var header = opts.get("header")
	var body = opts.get("body", "")
	var action_label_text = opts.get("action_label_text")
	var on_close = opts.get("on_close")
	var pause = opts.get("pause", true)

	# reset data
	jumbotron.header_text = header
	jumbotron.body_text = body
	jumbotron.set_control_icon()

	jumbotron.jumbo_closed.connect(func():
		if on_close and is_instance_valid(on_close.get_object()):
			on_close.call()
		if pause:
			Navi.get_tree().paused = false
		jumbotron.queue_free())

	if pause:
		Navi.get_tree().paused = true

	# maybe pause the game? probably? optionally?
	jumbotron.fade_in()

	return jumbotron.jumbo_closed

## instance ##########################################################################

signal jumbo_closed

@onready var header = $%Header
@onready var body = $%Body
@onready var dismiss_input_icon = $%DismissInputIcon

@export var header_text: String :
	set(v):
		header_text = v
		if header:
			if len(v) == 0:
				header.text = ""
			else:
				header.text = "[center]%s[/center]" % v

@export var body_text: String :
	set(v):
		body_text = v
		if body:
			if len(v) == 0:
				body.text = ""
			else:
				body.text = "[center]%s[/center]" % v

func _ready():
	set_control_icon()
	if not Engine.is_editor_hint():
		InputHelper.device_changed.connect(func(device, _idx):
			Log.pr("jumbotron detected device change")
			set_control_icon(device))

func set_control_icon(device=null):
	dismiss_input_icon.set_icon_for_action("ui_accept", device)

func _unhandled_input(event):
	if Trolls.is_close(event) or Trolls.is_accept(event):
		fade_out()

func fade_in():
	$PanelContainer.modulate.a = 0
	set_visible(true)
	var t = create_tween()
	t.tween_property($PanelContainer, "modulate:a", 1, 0.4)

func fade_out():
	var t = create_tween()
	t.tween_property($PanelContainer, "modulate:a", 0, 0.4)
	t.tween_callback(set_visible.bind(false))
	t.tween_callback(func(): jumbo_closed.emit())

func on_navigate():
	# when navi is used to navigate elsewhere, kill the jumbotron
	# NOTE that we skip the on_close, which usually navigates away anyway
	queue_free()
