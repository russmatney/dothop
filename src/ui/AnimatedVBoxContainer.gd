@tool
extends VBoxContainer
class_name AnimatedVBoxContainer

@export var child_size: Vector2 = Vector2(200, 64)
@export var anim_duration: float = 0.3

@export var disable_animations: bool = false

@export var margin: Vector2 = Vector2()
@export var ignored_children: Array[Node] = []

var og_size: Vector2
var chs: Array = []

func _ready() -> void:
	visibility_changed.connect(on_visibility_changed)
	og_size = custom_minimum_size
	chs = get_children()
	for ch: CanvasItem in ignored_children:
		chs.erase(ch)

	if not disable_animations:
		hide_and_animate_in()

func on_visibility_changed() -> void:
	if is_visible_in_tree() and not disable_animations:
		hide_and_animate_in()

func hide_and_animate_in() -> void:
	if Engine.is_editor_hint():
		return
	for c: CanvasItem in chs:
		if c.visible:
			c.modulate.a = 0.0
			c.set_visible(false)
	animate_opening.call_deferred()

func animate_opening() -> void:
	if Engine.is_editor_hint():
		return
	set_custom_minimum_size(Vector2.ZERO)
	var t: Tween = create_tween()
	var custom_size: Vector2 = (
		Vector2.RIGHT * (max(og_size.x, child_size.x) + margin.x)
		) + (Vector2.DOWN * (child_size.y * len(chs) + margin.y))

	t.tween_property(self, "custom_minimum_size",
		custom_size, anim_duration)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT_IN)
	await get_tree().create_timer(anim_duration).timeout

	for c: CanvasItem in chs:
		c.set_visible(true)
		var tw: Tween = c.create_tween()
		tw.tween_property(c, "modulate:a", 1.0, anim_duration)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(anim_duration).timeout
