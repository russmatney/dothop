@tool
extends RichTextLabel

var default_ttl: float = 3.0
var ttl: float
var tween: Tween

func _ready() -> void:
	if not ttl:
		ttl = default_ttl

	if not Engine.is_editor_hint():
		kill_in_ttl.call_deferred()

func kill_in_ttl() -> void:
	if not is_inside_tree():
		return
	var time_to_kill: float = ttl
	if not time_to_kill:
		time_to_kill = 3.0

	tween = create_tween()
	if not tween:
		return # prevent weird crash
	tween.tween_property(self, "modulate:a", 0.0, 2.0).set_delay(time_to_kill)
	tween.tween_callback(queue_free)

func reset_ttl(t: Variant = null) -> void:
	if t != null:
		ttl = t
	if tween:
		tween.kill()
	modulate.a = 1.0
	kill_in_ttl.call_deferred()

func reemphasize() -> void:
	if not is_inside_tree():
		return
	var t: Tween = create_tween()
	if not t:
		return # prevent weird crash
	t.tween_property(self, "scale", Vector2.ONE*1.2, 0.1)
	t.tween_property(self, "scale", Vector2.ONE, 0.1)
