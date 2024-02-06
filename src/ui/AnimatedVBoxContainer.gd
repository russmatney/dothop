@tool
extends VBoxContainer
class_name AnimatedVBoxContainer

@export var child_size = Vector2(200, 64)
@export var anim_duration: float = 0.3

var og_size
var chs = []

func _ready():
	visibility_changed.connect(on_visibility_changed)
	og_size = custom_minimum_size
	chs = get_children()

	hide_and_animate_in()

func on_visibility_changed():
	if is_visible_in_tree():
		hide_and_animate_in()

func hide_and_animate_in():
	for c in chs:
		if c.visible:
			c.modulate.a = 0.0
			c.set_visible(false)
	animate_opening.call_deferred()

func animate_opening():
	set_custom_minimum_size(Vector2.ZERO)
	var t = create_tween()
	t.tween_property(self, "custom_minimum_size",
		Vector2.RIGHT*(max(og_size.x, child_size.x))
		+ (Vector2.DOWN * child_size.y * len(chs)),
		anim_duration).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(anim_duration).timeout

	for c in chs:
		c.set_visible(true)
		var tw = c.create_tween()
		tw.tween_property(c, "modulate:a", 1.0, anim_duration)\
			.set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(anim_duration).timeout
