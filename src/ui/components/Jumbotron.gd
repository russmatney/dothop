@tool
extends CanvasLayer
class_name Jumbotron

## static ##########################################################################

static var jumbotron_scene_path: String = "res://src/ui/components/Jumbotron.tscn"

static func jumbo_notif(opts: Dictionary) -> Signal:
	var scene: PackedScene = opts.get("scene", load(jumbotron_scene_path))
	var jumbotron: Jumbotron = opts.get("instance", scene.instantiate())
	Navi.add_child(jumbotron)

	# TODO clean up!
	# this opt-in pattern might make more sense than 'Navi.menus'
	# what happened to this?
	# Navi.navigating.connect(jumbotron.on_navigate)

	var hd: String = opts.get("header", "")
	var bd: String = opts.get("body", "")
	var on_close: Variant = opts.get("on_close")
	var pause: bool = opts.get("pause", true)

	# reset data
	if hd:
		jumbotron.header_text = hd
	if bd:
		jumbotron.body_text = bd
	jumbotron.handle_panel_click()

	jumbotron.jumbo_closed.connect(func() -> void:
		if on_close and on_close is Callable and is_instance_valid((on_close as Callable).get_object()):
			(on_close as Callable).call()
		if pause:
			Navi.get_tree().paused = false
		jumbotron.queue_free())

	if pause:
		Navi.get_tree().paused = true

	# maybe pause the game? probably? optionally?
	jumbotron.fade_in()

	return jumbotron.jumbo_closed

######################################################################################
## instance ##########################################################################

signal jumbo_closed

var header: RichTextLabel
var body: RichTextLabel
var panel_container: PanelContainer

@export var header_text: String :
	set(v):
		header_text = v
		if not header:
			header = get_node_or_null("%Header")

		if header:
			if len(v) == 0:
				header.text = ""
			else:
				header.text = "[center]%s[/center]" % v

@export var body_text: String :
	set(v):
		body_text = v
		if not body:
			body = get_node_or_null("%Body")

		if body:
			if len(v) == 0:
				body.text = ""
			else:
				body.text = "[center]%s[/center]" % v

## ready ##########################################################################

func _ready() -> void:
	U.set_optional_nodes(self, {
			header="%Header",
			body="%Body",
			panel_container="%JumboPanelContainer",
			})
	handle_panel_click()

func handle_panel_click() -> void:
	if panel_container:
		panel_container.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
				fade_out()
				return
			if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
				fade_out()
				return
			)

# TODO restore or clean this up?
func on_navigate() -> void:
	# when navi is used to navigate elsewhere, kill the jumbotron
	# NOTE that we skip the on_close, which usually navigates away anyway
	queue_free()

## input ##########################################################################

func _unhandled_input(event: InputEvent) -> void:
	if Trolls.is_close(event) or Trolls.is_accept(event):
		fade_out()

## fade ##########################################################################

func fade_in() -> void:
	panel_container.modulate.a = 0
	set_visible(true)
	var t: Tween = create_tween()
	t.tween_property(panel_container, "modulate:a", 1, 0.4)

func fade_out() -> void:
	var t: Tween = create_tween()
	t.tween_property(panel_container, "modulate:a", 0, 0.4)
	t.tween_callback(set_visible.bind(false))
	t.tween_callback(func() -> void: jumbo_closed.emit())
